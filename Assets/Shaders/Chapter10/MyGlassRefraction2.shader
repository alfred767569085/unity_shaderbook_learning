Shader "My Unity Shaders Book/Chapter10/GlassRefraction2"
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

        GrabPass { "_RefractionTex" }

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
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 tangentView : TEXCOORD2;
            };

            v2f vert(appdata_tan v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeGrabScreenPos(o.pos);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TANGENT_SPACE_ROTATION;
                o.tangentView.xyz = mul(rotation, ObjSpaceViewDir(v.vertex));

                // o.uv.xy = worldPos.xy;
                // o.tangentView.w = worldPos.z;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                // float3 worldPos = float3(i.uv.xy, i.tangentView.w);
                fixed3 tangentView = normalize(i.tangentView.xyz);

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));   
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize;
                fixed3 refrColor = tex2D(_RefractionTex, offset + i.scrPos.xy/i.scrPos.w).rgb;

                fixed3 reflDir = reflect(-tangentView, bump);
                // ! TtoW
                fixed3 reflColor = texCUBE(_Cubemap, reflDir).rgb;
                
                // return fixed4(reflColor * (1 - _RefractAmount) + refrColor * _RefractAmount, 1.0);

                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(tangentView, bump), 5);
                return fixed4(lerp(refrColor, reflColor, fresnel), 1.0);
            }

            ENDCG
        }
    }
}
