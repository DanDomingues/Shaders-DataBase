Shader "ShaderCookbook/Chapter 8/BSCEffect"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BrightnessAmount ("Brightness Amount", Range(0.0, 1.0)) = 1.0
		_SaturationAmount ("Saturation Amount", Range(0.0, 1.0)) = 1.0
		_ContrastAmount ("Contrast Amount", Range(0.0,1.0)) = 1.0

	}

	SubShader

	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _BrightnessAmount;
			float _SaturationAmount;
			float _ContrastAmount;


			float3 ContrastSaturationBrightness(float3 color, float brt, float sat, float con)
			{
				float AvgLumR = 0.5;
				float AvgLumG = 0.5;
				float AvgLumB = 0.5;

				float3 LuminanceCoeff = float3 (0.2125, 0.7154, 0.0721);

				float3 AvgLumin = float3 (AvgLumR, AvgLumG, AvgLumB);
				float3 brtColor = color * brt;
				float intensityf = dot (brtColor, LuminanceCoeff);
				float3 intensity = float3(intensityf, intensityf, intensityf);

				float3 satColor = lerp(intensity, brtColor, sat);

				float3  conColor = lerp(AvgLumin, satColor, con);
				return conColor;
			}

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
			
			fixed4 frag (v2f_img i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				// just invert the colors

				col.rgb = ContrastSaturationBrightness(col.rgb, _BrightnessAmount, _SaturationAmount, _ContrastAmount);
				return col;
			}
			ENDCG
		}
	}
}
