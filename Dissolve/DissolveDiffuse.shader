Shader "Dissolve/Dissolve Simple" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}

		[Header(Dissolve Noise)]
		_NoiseTex("Dissolve Noise", 2D) = "white"{} // Texture the dissolve is based on
		_NoiseScale("Noise Scale", Range(0.0, 10.0)) = 1.0
		_NoiseAlphaOffset("Noise Alpha Offset", Range(0.0, 1.0)) = 0.0

		[Header(Dissolve Settings)]
		_DisAmount("Dissolve Amount", Range(0, 1)) = 0 // amount of dissolving going on
		_DisIgnore("Dissolve Ignore", Range(0, 1)) = 0
		_DisLineWidth("Dissolve Width", Range(0, 2)) = 0 // width of the line around the dissolve
		_DisLineColor("Dissolve Color", Color) = (1,1,1,1) // Color of the dissolve Line
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha // transparency
		CGPROGRAM
		#pragma surface surf Lambert keepalpha // transparency

		sampler2D _MainTex;
		float4 _Color;
		
		sampler2D _NoiseTex;// 
		fixed _NoiseScale;
		fixed _NoiseAlphaOffset;

		float _DisIgnore;
		float _DisAmount;//
		float _DisLineWidth;//
		float4 _DisLineColor;//

		struct Input 
		{
			float2 uv_MainTex : TEXCOORD0;
			float3 worldPos;// built in value to use the world space position
			
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			half4 n = tex2D(_NoiseTex, IN.worldPos.xy / _NoiseScale); // turn the noise texture into a value we can compare to. worldPos.xy projects from one side, xz from other side, yz from top

			float cap = 1.0 - _DisIgnore;
			float value = (_DisAmount - _DisIgnore) / cap;

			float alphaCompare = n.r + _NoiseAlphaOffset;

			if (clamp(alphaCompare - _DisLineWidth, 0, 1) < value) 
			{ //if the noise value minus the width of the line is lower than the dissolve amount
				c = _DisLineColor; // that part is the dissolve line color
			}

			if (alphaCompare < value) 
			{ // if the noise value is under the dissolve amount
				c.a = 0.0; // it's transparent, the alpha is set to 0
				discard;
			}
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG

	} 

	Fallback "Diffuse"
}