Shader "My Unity Shaders Book/Chapter 12/Gaussian Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        float _BlurSize;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv[5] : TEXCOORD0;
        };

        v2f vertBlurHorizontal(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.texcoord;
            o.uv[0] = uv;
            o.uv[1] = uv + half2(_MainTex_TexelSize.x * 1 * _BlurSize, 0);
            o.uv[2] = uv + half2(_MainTex_TexelSize.x * -1 * _BlurSize, 0);
            o.uv[3] = uv + half2(_MainTex_TexelSize.x * 2 * _BlurSize, 0);
            o.uv[4] = uv + half2(_MainTex_TexelSize.x * -2 * _BlurSize, 0);

            return o;
        }

        v2f vertBlurVertical(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.texcoord;
            o.uv[0] = uv;
            o.uv[1] = uv + half2(0, _MainTex_TexelSize.y * 1 * _BlurSize);
            o.uv[2] = uv + half2(0, _MainTex_TexelSize.y * -1 * _BlurSize);
            o.uv[3] = uv + half2(0, _MainTex_TexelSize.y * 2 * _BlurSize);
            o.uv[4] = uv + half2(0, _MainTex_TexelSize.y * -2 * _BlurSize);

            return o;
        }

        fixed4 frag(v2f i) : SV_TARGET
        {
            float GaussianWeight[3] = {0.4026, 0.2442, 0.0545};

            fixed3 blured = tex2D(_MainTex, i.uv[0]).rgb * GaussianWeight[0];
            for(int it = 1; it <= 2; ++it)
            {
                blured += tex2D(_MainTex, i.uv[2 * it - 1]).rgb * GaussianWeight[it];
                blured += tex2D(_MainTex, i.uv[2 * it]).rgb * GaussianWeight[it];
            }

            return fixed4(blured, 1.0);
        }

        ENDCG

        Pass
        {
            Name "GAUSSIAN_BLUR_VERTICAL"
            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment frag
            ENDCG
        }

        pass
        {
            Name "GAUSSIAN_BLUR_HORIZONTAL"
            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment frag
            ENDCG
        }
    }
}
