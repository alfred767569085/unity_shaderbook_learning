Shader "My Unity Shaders Book/Chapter10/GlassRefraction"
{
    Properties
    {
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}
        _FresnelScale("Fresnel Scale", Range(0, 1)) = 0.5
        _Distortion ("Distortion", Range(0, 100)) = 10
        // _RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0
    }
    SubShader {
        Tags { "Queue"="Transparent" "RenderType"="Opaque" }

        GrabPass { }

        Pass {
            CGPROGRAM
            
            // sampler2D _MainTex;
            // float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _Cubemap;
            fixed _FresnelScale;
            float _Distortion;
            // fixed _RefractAmount;
            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;
            };

            v2f vert(appdata_tan v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeGrabScreenPos(o.pos);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));   
                float2 offset = bump.xy * _Distortion * _GrabTexture_TexelSize;
                fixed3 refrColor = tex2D(_GrabTexture, offset + i.scrPos.xy/i.scrPos.w).rgb;

                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                fixed3 reflDir = reflect(-worldView, bump);
                fixed3 reflColor = texCUBE(_Cubemap, reflDir).rgb;
                
                // return fixed4(reflColor * (1 - _RefractAmount) + refrColor * _RefractAmount, 1.0);

                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldView, bump), 5);
                return fixed4(lerp(refrColor, reflColor, fresnel), 1.0);
            }

            ENDCG
        }
    }
}
