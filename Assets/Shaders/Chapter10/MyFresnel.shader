Shader "My Unity Shaders Book/Chapter10/FresnelRefraction"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _FresnelScale("Fresnel Scale", Range(0,1)) = 0.5
        _Cubemap ("Refraction Cubemap", Cube) = "_Skybox"{}
    }
    SubShader
    {
        pass {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert 
            #pragma fragment frag 
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            float _FresnelScale;
            samplerCUBE _Cubemap;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldView : TEXCOORD2;
                float3 worldRefl : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldView = normalize(UnityWorldSpaceViewDir(o.worldPos));
                o.worldRefl = reflect(-o.worldView, o.worldNormal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldView = normalize(i.worldView);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLight));
                fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;
                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(i.worldNormal, i.worldView), 5);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(ambient + lerp(diffuse, reflection, fresnel), 1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
