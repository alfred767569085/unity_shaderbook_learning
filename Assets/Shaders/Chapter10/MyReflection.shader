Shader "My Unity Shaders Book/Chapter10/Reflection"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _ReflectColor ("Reflection Color", Color) = (1,1,1,1)
        _ReflectAmount ("Reflect Amount", Range(0,1)) = 1
        _Cubemap ("Reflection Cubemap", Cube) = "_Skybox"{}
    }
    SubShader
    {
        pass {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert 
            #pragma fragment frag 
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _ReflectColor;
            float _ReflectAmount;
            samplerCUBE _Cubemap;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldView : TEXCOORD2;
                float3 worldRefl : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldView = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefl = reflect(-o.worldView, o.worldNormal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldView = normalize(i.worldView);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLight));
                fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(ambient + atten * lerp(diffuse, reflection, _ReflectAmount), 1.0);
                // return fixed4(ambient + (diffuse + reflection * _ReflectAmount) * atten, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}

/*
v1 = (x1,y1,z1), v2 = (x2,y2,z2), v3 = (x3,y3,z3)

x1^2 + y1^2 + z1^2 = 1
a + b + c = 1
a,b,c > 0 

M = (ax1+bx2+cx3)^2 + (ay1+by2+cy3)^2 + (az1+bz2+cz3)^2

M = a2x12 + b2x22 + c2x32 + 2abx1x2 + 2acx1x3 + 2bcx2x3
+ a2y12 + b2y22 + c2y32 + 2aby1y2 + 2acy1y3 + 2bcy2y3
+ a2z12 + b2z22 + c2z32 + 2abz1z2 + 2acz1z3 + 2bcz2z3

M = a2 + b2 + c2 + 2ab(x1x2+y1y2+z1z2) + 2ac(x1x3+y1y3+z1z3) + 2bc(x2x3+y2y3+z2z3)
M - 1 = 2ab(x1x2+y1y2+z1z2 - 1) + 2ac(x1x3+y1y3+z1z3 - 1) + 2bc(x2x3+y2y3+z2z3 - 1)

2 * (x1x2+y1y2+z1z2 - 1) = -(x12+y12+z12+x22+y22+z22 -2x1x2-2y1y2-2z1z1)
2 * (x1x2+y1y2+z1z2 - 1) = -((x1-x2)2 + (y1-y2)2 + (z1-z2)2) <= 0

M <= 1
(when v1 = v2 = v3)

*/