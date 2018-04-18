Shader "ShaderCookbook/Chapter 8/GrayscaleEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LuminosityAmount ("GrayScale Amount", Range(0.0,1 )) = 1.0
		_LumR ("Luminosity (RED)", Range(0.0,1.0)) = 1.0
		_LumG ("Luminosity (GREEN)", Range(0.0,1.0)) = 1.0
		_LumB ("Luminosity (BLUE)", Range(0.0,1.0)) = 1.0

	}
	SubShader
	{
		// No culling or depth
		//Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			

			uniform sampler2D _MainTex;
			fixed _LuminosityAmount;
			fixed _LumR;
			fixed _LumG;
			fixed _LumB;

			fixed4 frag (v2f_img i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				// just invert the colors

				float luminosity = (0.299 * col.r) + (0.597 * col.g) + (0.114 * col.b);
				fixed4 gray = lerp(col, luminosity, 1);

				fixed4 finalColor = gray;

				finalColor.r = lerp(col.r,gray.r, 1 - (_LumR * _LuminosityAmount));
				finalColor.g = lerp(col.g,gray.g, 1 - (_LumG * _LuminosityAmount));
				finalColor.b = lerp(col.b,gray.b, 1 - (_LumB * _LuminosityAmount));

				//fixed4 finalColor = fixed4( lerp(col.r,gray.r, _LumR), gray.g, gray.b, gray.alpha);

				return finalColor;
			}
			ENDCG
		}
	}
}
