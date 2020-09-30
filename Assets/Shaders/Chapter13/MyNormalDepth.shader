Shader "Ny Unity Shaders Book Learning/Chapter13/Normal Depth"
{
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        CGINCLUDE
        #include "UnityCG.cginc"
        #include "HLSLSupport.cginc"

        sampler2D _CameraDepthNormalsTexture;

        struct v2f 
        {
            float4 pos : SV_POSITION;
            float4 scrPos : TEXCOORD0;
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.scrPos = ComputeScreenPos(o.pos);
            return o;
        }

        fixed4 fragDepth(v2f i) : SV_TARGET
        {
            float4 enc = tex2Dproj(_CameraDepthNormalsTexture, i.scrPos);
            float3 normal = DecodeViewNormalStereo(enc);
            return fixed4(normal, 1.0);
        }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragDepth
            ENDCG
        }
    }
}
