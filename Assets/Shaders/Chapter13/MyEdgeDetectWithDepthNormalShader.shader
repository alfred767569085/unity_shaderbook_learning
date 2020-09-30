Shader "My Unity Shaders Book/Chapter 13/Edge Detect With Depth Normal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        CGINCLUDE
        #include "UnityCG.cginc"
        #include "HLSLSupport.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthNormalsTexture;
        fixed4 _EdgeColor;
        fixed4 _BackgroundColor;
        float _EdgeOnly;
        float _SampleDistance;
        float4 _Sensitivity;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv[9] : TEXCOORD0;
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.vertex;
            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                uv.y = 1-uv.y;
            #endif

            o.uv[0] = uv + _MainTex_TexelSize * _SampleDistance * half2(-1, -1);
            o.uv[1] = uv + _MainTex_TexelSize * _SampleDistance * half2(0, -1);
            o.uv[2] = uv + _MainTex_TexelSize * _SampleDistance * half2(1, -1);
            o.uv[3] = uv + _MainTex_TexelSize * _SampleDistance * half2(-1, 0);
            o.uv[4] = uv + _MainTex_TexelSize * _SampleDistance * half2(0, 0);
            o.uv[5] = uv + _MainTex_TexelSize * _SampleDistance * half2(1, 0);
            o.uv[6] = uv + _MainTex_TexelSize * _SampleDistance * half2(-1, 1);
            o.uv[7] = uv + _MainTex_TexelSize * _SampleDistance * half2(0, 1);
            o.uv[8] = uv + _MainTex_TexelSize * _SampleDistance * half2(1, 1);

            return o;
        }

        fixed sobel(v2f i)
        {
            fixed sobelX[9] = 
            {
                -1, 0, 1,
                -2, 0, 2,
                -1, 0, 1
            };
            fixed sobelY[9] =
            {
                -1, -2, -1,
                0, 0, 0,
                1, 2, 1
            };

            half2 GDepth = half2(0, 0);
            half2 GNormal = half2(0, 0);
            for(int it = 0; it < 9; ++it)
            {
                float4 enc = tex2D(_CameraDepthNormalsTexture, i.uv[it]);
                float depth = EncodeFloatRG(enc.zw);
                float normal = enc.x + enc.y;
                GDepth += half2(sobelX[it], sobelY[it]) * depth;
                GNormal += half2(sobelX[it], sobelY[it]) * normal;
            }

            half depth = abs(GDepth.x) + abs(GDepth.y),
            normal = abs(GNormal.x) + abs(GNormal.y);

            return _Sensitivity.x * depth > 0.1 || _Sensitivity.y * normal > 0.1;
        }

        fixed4 frag(v2f i) : SV_TARGET
        {
            fixed3 backgroundColor = lerp(tex2D(_MainTex, i.uv[5]).rgb, _BackgroundColor.rgb, _EdgeOnly);
            return fixed4(lerp(backgroundColor,_EdgeColor, sobel(i)), 1.0);
        }

        ENDCG

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
