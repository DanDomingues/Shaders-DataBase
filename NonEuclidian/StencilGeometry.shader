Shader "Modules/NonEuclidian/StencilGeometry" {
	Properties 
	{
		_StencilMask("Stencil Mask", Int) = 0

		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_LightFactor("Light Multiplier", Range(0, 10)) = 1.0
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Stencil
		{
			Ref[_StencilMask]
			Comp equal
			Pass keep
			Fail keep
		}

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf SimpleLambert

		sampler2D _MainTex;
		float _LightFactor;
		float4 _Color;

		struct Input 
		{
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o)
		 {
			// Albedo comes from a texture tinted by color

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		half4 LightingSimpleLambert(SurfaceOutput s, half3 lightDir , half atten)
		{
			half NdotL = dot(s.Normal, lightDir) ;
			half4 c;

			c.rgb = s.Albedo * (_LightColor0.rgb * _LightFactor ) * (NdotL * atten * 1);
			c.a = s.Alpha;

			return c;
		}

		ENDCG
	}
	FallBack "Diffuse"

}