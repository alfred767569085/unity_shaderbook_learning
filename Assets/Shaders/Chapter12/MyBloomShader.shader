Shader "My Unity Shaders Book/Chapter 12/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _Bloom;  
        float _LuminanceThreshold;
        float _BlurSize;
        
        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        fixed4 fragExtractBright(v2f i) : SV_TARGET
        {
            fixed4 c = tex2D(_MainTex, i.uv);
            fixed val = clamp(Luminance(c.rgb) - _LuminanceThreshold, 0.0, 1.0);
            return c * val;
        }

        fixed4 fragBloom(v2f i) : SV_TARGET
        {
            return tex2D(_MainTex, i.uv) + tex2D(_Bloom, i.uv);
        }
        
        ENDCG
        
        ZTest Always Cull Off ZWrite Off

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragExtractBright
            ENDCG
        }

        UsePass "My Unity Shaders Book/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_VERTICAL"

        UsePass "My Unity Shaders Book/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_HORIZONTAL"

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragBloom
            ENDCG
        }
    }

    Fallback off
}
