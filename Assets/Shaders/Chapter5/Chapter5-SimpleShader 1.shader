// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "My Unity Shaders Book/Chapter5/Simple Shader" {
	Properties{
		_Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader{
		Pass {
			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "UnityCG.cginc"

			struct v2f {
				float4 pos : SV_POSITION;
				fixed4 color : COLOR0;
			};

			v2f vert(appdata_full v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
				// o.color = v.tangent * 0.5 + fixed4(0.5,0.5,0.5,0.5);
				// o.color = v.texcoord;
				// o.color = frac(v.texcoord);
				// if(any(saturate(v.texcoord) - v.texcoord)) {
					// 	o.color.b = 0.5;
				// }
				// o.color = frac(v.texcoord1);
				// if(any(saturate(v.texcoord1) - v.texcoord1)) {
					// 	o.color.b = 0.5;
				// }
				// o.color = v.color;

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET {
				return i.color;
			}

			ENDCG
		}
	}
}
