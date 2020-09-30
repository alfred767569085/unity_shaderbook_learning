Shader "My Unity Shaders Book Learning/Chapter 13/Fog with Depth"
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

        float4x4 _FrustumCornersRay;
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        half _FogDensity;
        fixed4 _FogColor;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            float4 scrPos : TEXCOORD1;
            float4 interpolatedRay : TEXCOORD2;
        };
        
        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.scrPos = ComputeScreenPos(o.pos);

            int index = v.texcoord.x < 0.5 ? 0 : 1;
            index += v.texcoord.y < 0.5 ? 0 : 2;
            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                index = 3 - index;
            #endif

            o.interpolatedRay = _FrustumCornersRay[index];
            return o;
        }

        fixed4 frag(v2f i) : SV_TARGET
        {
            float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.scrPos));
            float3 worldPos = _WorldSpaceCameraPos + i.interpolatedRay * depth;
            
            float fogDensity = saturate(exp(-0.5 / _FogDensity * worldPos.y));

            return lerp(tex2D(_MainTex, i.uv), _FogColor, fogDensity);
        }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
