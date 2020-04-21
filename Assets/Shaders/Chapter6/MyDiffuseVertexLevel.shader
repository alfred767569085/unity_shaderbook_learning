// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "My Unity Shaders Book/Chapter6/Diffuse Vertex Level" {
    Properties {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader {
        pass {
            Tags {"LightMode" = "ForwardBase"}

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
                fixed3 color : COLOR;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // get ambient light
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //translate the NORMAL and the LIGHT into a common space( world space), then compute the dot product
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
                
                o.color = ambient + diffuse;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                return fixed4(i.color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Deffuse"
}