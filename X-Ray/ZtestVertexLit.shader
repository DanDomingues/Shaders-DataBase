Shader "Modules/ZTestVertexLit" 
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_EdgeColor ("Edge Color", Color) = (1,1,1,1)
		_StencilID ("Stencil ID", Int) = 3

	}

	SubShader
	{

		ZWrite Off
		//ZTest Always
		Blend One One

		//Pass sucessful when mask and masked are equal
		
		Pass
		{

			ZWrite Off
			//ZTest Always
			Blend One One

			Stencil
			{
				Ref 10
				Comp equal
				Pass keep
				Fail keep
			}

			Tags
			{
				"Queue" = "Transparent"
				"RenderType" = "Transparent"
				"XRay" = "ColoredOutline"
			}


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

			fixed4 frag (v2f v) : SV_Target
			{
				float NdotV =  1 - dot(v.normal, v.viewDir) * 1.5;
				return _EdgeColor * NdotV;
			}

			ENDCG

		}
		
	}

}
