Shader "Modules/VertexLit" 
{
	Properties
	{
		_EdgeColor ("Edge Color", Color) = (1,1,1,1)
		_Atten ("Edge Attenuation", Range(1.0, 3.0)) = 1.5
	}

	SubShader
	{
		Pass
		{
			Tags
			{
				"Queue" = "Transparent"
				"RenderType" = "Opaque"
			}

			ZWrite Off
			ZTest Always
			//Blend One One

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD1;
			};

			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = v.uv;

				o.normal = UnityObjectToWorldNormal(v.normal);

				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				
				return o;
			}

			float4 _EdgeColor;
			fixed _Atten;

			fixed4 frag (v2f v) : SV_Target
			{
				float NdotV = 1 - dot(v.normal, v.viewDir) * _Atten;
				return _EdgeColor * NdotV;
			}

			ENDCG

		}
		
	}

}
