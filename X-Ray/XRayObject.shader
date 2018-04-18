﻿Shader "Custom/XRayObject" 
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Color ("Main Color", Color) = (1,1,1,1)
		_StencilID("Stencil ID", Int) = 0
	}

	Subshader
	{

		Tags 
		{
			"RenderType" = "Opaque"
			//"Queve" = "Geometry - 100"
		}
		//LOD 200

		ZWrite off
		//ZTest Always

		Stencil
		{
			Ref 10
			Comp always
			Pass replace
			Fail keep
		}

		CGPROGRAM

		#pragma surface surf Lambert

		sampler2D _MainTex;
		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}

	Fallback "Diffuse"
}