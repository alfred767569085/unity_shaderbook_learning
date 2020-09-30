Shader "My Unity Shaders Book/Chapter 12/EdgeDetect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;

            struct v2f
            {
                half2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                half2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] =    uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] =   uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] =    uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] =  uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] =   uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] =  uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] =  uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] =  uv + _MainTex_TexelSize.xy * half2(1, 1);

                return o;
            }

            half Sobel(v2f i)
            {
                const half sobelX[9] = 
                {
                    -1, 0, 1,
                    -2, 0, 2,
                    -1, 0, 1
                };
                const half sobelY[9] = 
                {
                    -1, -2, -1,
                    0, 0, 0,
                    1, 2, 1
                };

                half luminance;
                half Gx = 0;
                half Gy = 0;

                for(int it = 0; it < 9; ++it)
                {
                    luminance = Luminance(tex2D(_MainTex, i.uv[it]));
                    Gx += luminance * sobelX[it];
                    Gy += luminance * sobelY[it];
                }

                return (abs(Gx) + abs(Gy)) > 0.2 ? 1 : 0;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 background = lerp(tex2D(_MainTex, i.uv[4]), _BackgroundColor, _EdgeOnly);
                return lerp(background, _EdgeColor, Sobel(i));
            }
            ENDCG
        }
    }
}
