Shader "My Unity Shaders Book/Chapter9/Forward Rendering"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            struct a2v {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD2;
                fixed3 unimportantLight : TEXCOORD3;
            };
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                
                o.unimportantLight = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, o.worldPos, o.worldNormal);

                return o;
            }
            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = UnityWorldSpaceLightDir(i.worldPos);
                fixed3 worldView = UnityWorldSpaceViewDir(i.worldPos);
                fixed3 worldHalf = normalize(worldLight + worldView);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Gloss);
                fixed atten = 1.0;
                return fixed4(ambient + (diffuse + specular) * atten + i.unimportantLight, 1.0);
            }
            ENDCG
        }

        pass
        {
            Tags { "LightMode"="ForwardAdd" }
            Blend one one
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert 
            #pragma fragment frag 
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            struct a2v {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 worldNormal = normalize(i.worldNormal);
                // fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                    fixed atten = 1.0;
                #else
                    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                    float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos.xyz, 1)).xyz;
                    fixed atten = tex2D(_LightTexture0, dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #endif
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                fixed3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 worldHalf = normalize(worldView + worldLight);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Gloss);

                return fixed4((diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}