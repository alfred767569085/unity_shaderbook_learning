Shader "My Unity Shaders Book/Chapter 11/MyScrollingBackground"
{
    Properties
    {
        _MainTex ("Base Layer", 2D) = "white"{}
        _DetailTex("Detail Layer", 2D) = "white"{}
        _ShiftX("Base Layer Shift", Float) = 1.0
        _Shift2X("Detail Layer Shift", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            float _ShiftX;
            float _Shift2X;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + float2(_ShiftX, 0.0);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + float2(_Shift2X, 0.0);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);
                return lerp(firstLayer, secondLayer, secondLayer.a);
            }
            ENDCG
        }
    }
}
