Shader "My Unity Shaders Book/Chapter6/Difffuse Pixel Level" {
    Properties {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader {
        pass {
            Tags {"LightModel" = "ForwardBase"}

            CGPROGRAM
            
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Diffuse;
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;                
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldNormal = i.worldNormal;
                fixed3 halfLambert = dot(worldNormal, worldLight) * 0.5 + 0.25;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;
                return fixed4(diffuse + ambient,1.0);
            }
            
            ENDCG
        }
    }
}