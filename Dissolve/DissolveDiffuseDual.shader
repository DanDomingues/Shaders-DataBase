Shader "Dissolve/DissolveDual" 
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Color ("Main Color", Color) = (1,1,1,1)

		_NoiseTex("Dissolve Noise", 2D) = "white" {}
		_NScale("Noise Scale", Range(0, 10)) = 1
		_DisAmount("Dissolve Amount", Range(0, 1)) = 0

		_DisLineWidth("Dissolve Width", Range(0, 2)) = 0
		_DisLineColor ("Dissolve Color", Color) = (1,1,1,1)
		_DisLineColorEx ("Dissolve Color Extra", Color) = (1,1,1,1)

		[Toggle(ALPHA)] _ALPHA("Show facing parts inside alpha?", Float) = 0
		[Toggle(LIGHTMAP)] _LIGHTMAP("Use 2nd/Lightmap UV", Float) = 0


	}

	Subshader
	{
		CGPROGRAM

		#pragma shader_feature LIGHTMAP
		#pragma surface surf Lambert alphatest:_ALPHA

		struct Input
		{
			float2 uv_MainTex : TEXCOORD0;
			float3 worldPos;
		};

		sampler2D _MainTex;
		fixed4 _Color;

		sampler2D _NoiseTex;
		fixed _NScale;
		fixed _DisLineWidth;

		float _DisAmount;
		fixed4 _DisLineColor;
		fixed4 _DisLineColorEx;

		void surf (Input IN, inout SurfaceOutput OUT)
		{
			half4 color = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			half4 m_noise = tex2D(_NoiseTex, IN.worldPos.xy * _NScale);

			#if LIGHTMAP
			m_noise = tex2D(_NoiseTex, IN.uv_MainTex * _NScale);
			#endif

			//[RESEARCH]: 'step' command
			float3 dissolveLineIn = step(m_noise.r - _DisLineWidth, _DisAmount);
			float3 dissolveLineInExtra = step(m_noise - (_DisLineWidth + 0.2), _DisAmount) - dissolveLineIn;

			float3 noDissolve = float3(1,1,1) - (dissolveLineIn - dissolveLineInExtra);
			color.rgb = (dissolveLineIn * _DisLineColor) + (dissolveLineInExtra * _DisLineColorEx) + (noDissolve * color.rgb);
			OUT.Emission = (dissolveLineInExtra * _DisLineColorEx) + (dissolveLineIn * _DisLineColor);
			color.a = step(_DisAmount, m_noise.r);

			OUT.Albedo = color.rgb;
			OUT.Alpha = color.a;

		}

		ENDCG
	}

	Fallback "Diffuse"


}
