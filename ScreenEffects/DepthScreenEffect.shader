Shader "ShaderCookbook/Chapter 8/DepthScreenEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DepthPower ("Depth Power", Range(1, 5)) = 1.0
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
			fixed _DepthPower;
			sampler2D _CameraDepthTexture;

			fixed4 frag (v2f_img i) : COLOR
			{
				//fixed4 col = tex2D(_MainTex, i.uv);
				// just invert the colors

				//float luminosity = (0.299 * col.r) + (0.597 * col.g) + (0.114 * col.g);
				//fixed4 finalColor = lerp(col, luminosity, _LuminosityAmount);

				float4 d = UNITY_SAMPLE_DEPTH ( tex2D (_CameraDepthTexture, i.uv.xy));
				d = pow(Linear01Depth(d), _DepthPower);

				return d;
			}
			ENDCG
		}
	}
}
