Shader "My Unity Shaders Book/Chapter 11/MyImageSequenceAnimaion"
{
    Properties
    {
        _MainTex ("Image Sequence", 2D) = "white" {}
        _HorizontalAmount("Horizontal Amount", Float) = 8
        _VerticalAmount("Vertical Amount", Float) = 8
        _Speed("Speed", Range(0, 100)) = 30
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = floor(_Time.y * _Speed);
                float row = floor(time / _HorizontalAmount);
                float column = time - row * _HorizontalAmount;

                half2 uv = (i.uv + half2(column, -row)) / half2(_HorizontalAmount, _VerticalAmount);

                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
