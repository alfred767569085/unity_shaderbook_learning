Shader "My Unity Shaders Book/Chapter6/Specular Vertex Level" {
    Properties {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0,256)) = 20
    }
    SubShader {
        pass {
            Tags {"LightModel" = "ForwardBase"}

            CGPROGRAM
            
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

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
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldLight,worldNormal));
                fixed3 worldReflect = normalize(reflect(-worldLight,worldNormal));
                fixed3 worldView = normalize(WorldSpaceViewDir(v.vertex));
                fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(worldReflect,worldView)),_Gloss);
                o.color = ambient + diffuse + specular; 
                return o;
            }
            fixed4 frag(v2f i) : SV_TARGET {
                return fixed4(i.color,1.0);
            }
            
            ENDCG
        }
    }
    Fallback "Specular"
}