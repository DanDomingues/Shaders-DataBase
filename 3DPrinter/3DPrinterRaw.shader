Shader "Modules/3DPrinter/3DPrinterRaw" {
	Properties 
	{
		_PrinterY ("Printer Y Pos", Float) = 5.0
		_PrinterHeight("Printer Height", Range(0.0,5.0)) = 0.5
		_PrinterFadeHeight("Printer Fade Height", Range(0.0,5.0)) = 0.5
		_PrinterColor ("Printer Color", Color) = (1,1,1,1)
		_WhiteMixture("White Misture Ratio", Range(0.1,0.9)) = 0.5
		_PrinterWobbleX("Printer Wobble X", Range(0,200)) = 120
		_PrinterWobbleZ("Printer Wobble Z", Range(0,200)) = 60

		_BuildLinesTex("Build Lines (RGB)", 2D) = "white"{}
		ongoing("Build Ongoing", int) = 1

		_BuildLinesTimeScale("Build Lines Time Scale", Range(0.0,10.0)) = 0.5
		_BuildLinesTiling("Build Lines Vertical Tiling", Range(0.1,10.0)) = 1.0

		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader 
	{
		Cull off
		Tags { "RenderType"="Transparent" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Custom fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		#include "UnityPBSLighting.cginc"

		sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
			float3 worldPos;
			float3 viewDir;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		int building = 0;
		float blend = 0.0;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		float _PrinterY;
		float _PrinterHeight;
		fixed4 _PrinterColor;
		fixed _PrinterWobbleX;
		fixed _PrinterWobbleZ;

		float3 viewDir;

		inline half4 LightingCustom(SurfaceOutputStandard s, half3 lightDir, UnityGI gi)
		{
			half4 pbr = LightingStandard(s, lightDir, gi);
			if(dot(s.Normal, viewDir) < -.5) return _PrinterColor;

			if(building == 1)
			{
				return _PrinterColor;
			}


			return lerp(_PrinterColor, pbr, blend);	

			


		}

		inline void LightingCustom_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi);		
		}

		int ongoing;
		fixed _WhiteMixture;
		sampler2D _BuildLinesTex;
		fixed _BuildLinesTimeScale;
		int _BuildLinesTiling;
		fixed _PrinterFadeHeight;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Albedo comes from a texture tinted by color
			viewDir = IN.viewDir;
			float s = sin((IN.worldPos.x * IN.worldPos.z) * _PrinterWobbleZ + _Time[3] + o.Normal) / _PrinterWobbleX;

			if(IN.worldPos.y > _PrinterY + s)
			{
				discard;

				building = 0;
			}
			
			else if(IN.worldPos.y > _PrinterY + s - _PrinterHeight)
			{
				o.Albedo = _PrinterColor.rgb;
				o.Alpha = _PrinterColor.a;

				building = 1;
			}

			else
			{
				fixed4 mixture = fixed4(1,1,1,1);
				fixed4 ongoingMod = mixture;

				ongoingMod = lerp(mixture, _PrinterColor, _WhiteMixture);
				fixed4 c = tex2D (_MainTex, IN.uv_MainTex);// * _Color;

				fixed startPos = _PrinterY - _PrinterHeight;
				blend = clamp((startPos - IN.worldPos.y)/_PrinterFadeHeight, 0, 1);					

				if(ongoing == 1)
				{
					fixed2 uv = IN.uv_MainTex / _BuildLinesTiling - fixed2(0, _Time.x * _BuildLinesTimeScale / 5);
					fixed3 lines = tex2D(_BuildLinesTex, uv).rgb;
					c.rgb += lines.rgb;
					c *= ongoingMod;
				} 

				o.Albedo = c.rgb;
				o.Alpha = c.a;

				building = 2;
			}
		}

		ENDCG
	}
	FallBack "Diffuse"
}
