Shader "Custom/DynamicColors" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		[Space(10)]
		[Header(Dynamic Colors)]
		_PrimaryReadColor("Primary TEX Color", Color) = (1,1,1,1)
		_SecondaryReadColor("Secondary TEX Color", Color) = (1,1,1,1)
		_TertiaryReadColor("Tertiary TEX Color", Color) = (1,1,1,1)

		[Space(10)]
		_PrimaryWriteColor("Primary Color", Color) = (1,1,1,1)
		_SecondaryWriteColor("Secondary Color", Color) = (1,1,1,1)
		_TertiaryWriteColor("Tertiary Color", Color) = (1,1,1,1)

		[Space(10)]
		_CompareFactor("Compare Factor", Range(0.0,1.0)) = 0.1
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		float _CompareFactor;

		bool CompareColors(fixed4 a, fixed4 b)
		{
			return distance(a, b) < _CompareFactor; 
			//(a.r == b.r) && (a.g == b.g) && (a.b == b.b);// && (a.a && b.a);
		}

		fixed4 _PrimaryReadColor;
		fixed4 _SecondaryReadColor;
		fixed4 _TertiaryReadColor;

		fixed4 _PrimaryWriteColor;
		fixed4 _SecondaryWriteColor;
		fixed4 _TertiaryWriteColor;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			if(CompareColors(c, _PrimaryReadColor))
			{
				c.rgb = _PrimaryWriteColor;
			}

			if(CompareColors(c, _SecondaryReadColor))
			{
				c.rgb = _SecondaryWriteColor;
			}

			if(CompareColors(c, _TertiaryReadColor))
			{
				c.rgb = _TertiaryWriteColor;
			}

			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
