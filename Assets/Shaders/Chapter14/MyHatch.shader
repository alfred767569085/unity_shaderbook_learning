Shader "Ny Unity Shaders Book Learning/Chapter 14/Hatch"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _TileFactor("Tile Factor", Float) = 8
        _Outline("Outline", Range(0, 1)) = 0.005
        _Hatch0("Hatch 0", 2D) = "white" {}
        _Hatch1("Hatch 1", 2D) = "white" {}
        _Hatch2("Hatch 2", 2D) = "white" {}
        _Hatch3("Hatch 3", 2D) = "white" {}
        _Hatch4("Hatch 4", 2D) = "white" {}
        _Hatch5("Hatch 5", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        UsePass "My Unity Shaders Book/Chapter 14/Toon/OUTLINE"

        pass
        {
            Tags { "RenderMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            float _TileFactor;
            sampler2D _Hatch0;
            sampler2D _Hatch1;
            sampler2D _Hatch2;
            sampler2D _Hatch3;
            sampler2D _Hatch4;
            sampler2D _Hatch5;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord * _TileFactor;

                float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal)),
                worldLight = normalize(WorldSpaceLightDir(v.vertex));

                float hatchFactor = 7 * saturate(dot(worldNormal, worldLight));

                o.uv.z = clamp(floor(hatchFactor), 0, 6);
                o.uv.w = frac(hatchFactor);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                if(i.uv.z >= 6)
                return _Color;
                if(i.uv.z >= 5)
                return i.uv.w * _Color + (1 - i.uv.w) * tex2D(_Hatch5, i.uv.xy);
                if(i.uv.z >= 4)
                return i.uv.w * tex2D(_Hatch5, i.uv.xy) + (1 - i.uv.w) * tex2D(_Hatch4, i.uv.xy);
                if(i.uv.z >= 3)
                return i.uv.w * tex2D(_Hatch4, i.uv.xy) + (1 - i.uv.w) * tex2D(_Hatch3, i.uv.xy);
                if(i.uv.z >= 2)
                return i.uv.w * tex2D(_Hatch3, i.uv.xy) + (1 - i.uv.w) * tex2D(_Hatch2, i.uv.xy);
                if(i.uv.z >= 1)
                return i.uv.w * tex2D(_Hatch2, i.uv.xy) + (1 - i.uv.w) * tex2D(_Hatch1, i.uv.xy);
                return i.uv.w * tex2D(_Hatch1, i.uv.xy) + (1 - i.uv.w) * tex2D(_Hatch0, i.uv.xy);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
