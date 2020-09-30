Shader "My Unity Shaders Book Learning/Chapter 14/Toon"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "white" {}
        _Ramp ("Ramp Texture", 2D) = "white" {}
        _Outline ("Outline", Range(0, 1)) = 0.1
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _SpecularScale("Specular Scale", Range(0, 0.1)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
        pass
        {
            Name "OUTLINE"
            Cull front
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag   
            #include "UnityCG.cginc"        
            
            float _Outline;
            fixed4 _OutlineColor;

            float4 vert(appdata_base v) : SV_POSITION
            {
                float4 pos = float4(UnityObjectToViewPos(v.vertex), v.vertex.w);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                viewNormal.z = -0.5;
                viewNormal = normalize(viewNormal);
                pos.xyz += _Outline * viewNormal;
                return mul(UNITY_MATRIX_P, pos);
            }

            fixed4 frag(float4 i : SV_POSITION) : SV_TARGET
            {
                return fixed4(_OutlineColor.rgb, 1.0);
            } 

            ENDCG
        }

        pass
        {
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            sampler2D _Ramp;
            fixed4 _Specular;
            float _SpecularScale;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_SHADOW(o)
                return o;
            }
            
            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 worldHalf = normalize(worldLight + worldView);

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)

                fixed diff = dot(worldNormal, worldLight);
                diff = (diff * 0.5 + 0.5) * atten;

                fixed3 diffuse = _LightColor0.rgb * tex2D(_Ramp, float2(diff, diff)).rgb;

                fixed spec = dot(worldNormal, worldHalf);
                fixed w = fwidth(spec) * 2.0;
                fixed3 specular = _Specular.rgb * smoothstep(-w , w, spec + _SpecularScale - 1);
                // fixed3 specular = _Specular.rgb * pow(saturate(spec), 20);

                return fixed4(albedo * (ambient + diffuse) + specular, 1.0);
            }
            
            ENDCG
        }

    }
    FallBack "Diffuse"
}
