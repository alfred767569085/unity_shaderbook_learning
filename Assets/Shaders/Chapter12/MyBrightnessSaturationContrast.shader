Shader "My Unity Shaders Book/Chapter 12/BrightnessSaturationContrast"
{
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        pass
        {
            ZTest always
            Cull off 
            ZWrite off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Brightness;
            half _Saturation;
            half _Contrast;

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv: TEXCOORD0;
            };

            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 finalColor = tex2D(_MainTex, i.uv);

                finalColor.rgb = finalColor.rgb * _Brightness;

                fixed luminance = Luminance(finalColor.rgb);
                finalColor.rgb = lerp(fixed3(luminance, luminance, luminance), finalColor, _Saturation);

                finalColor.rgb = lerp(fixed3(0.5, 0.5, 0.5), finalColor, _Contrast);

                return finalColor;
            }

            ENDCG
        }
    }
}
