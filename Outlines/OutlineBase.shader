// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Modules/Outline/Outline Base" 
{
	Properties
	{

		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		_OutlineWidth("Outline Width", Range(0, 0.5)) = 1.0
		[Toggle] _UseOutline ("Outline Active", Float) = 1.0
		
		[Space(10)]
		[Header(Outline Texture Blend)]
		[Toggle] _UseBaseColor ("Use Texture's Color", Float) = 0.0
		_BaseColorMod("Base Color Modifier", Color) = (1,1,1,1)
		_ColorBlendFactor("Color Blend Factor", Range(0.0,1.0)) = 0.5

		[Space(10)]
		[Header(Vertex Lighting Module)]
		[Toggle] _UseOutlineLighting("Use Outline Lighting", Float) = 0.5
		_Atten ("Edge Lighting Atten", Range(0.0,10.0)) = 1.5

		[Space(10)]
		[Header(Outline Animation)]
		[Toggle]_AnimateOutline("Animate Outline", Float) = 0.0

		_OutlineSpeed("Outline Speed", Float) = 1.0
		_OutlineDot("Colored Strip Width", Float) = 1.0
		_OutlineDot2("Skipped Strip Width", Float) = 1.0

	}
	SubShader
	{

		//Outline Pass
		Pass
		{

			Tags
			{
				"Queue" = "Transparent"
				"RenderType" = "Opaque"
			}

			Zwrite Off// ZTest Always
			ZTest Always
			Blend One One

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
				//float4 color : COLOR;
			};
			
			float _UseOutline;
			float _UseBaseColor;
			float _OutlineWidth;
			fixed4 _OutlineColor;
			fixed4 _BaseColorMod;

			sampler2D _MainTex;
			float4 _Color;

			v2f vert(appdata v) 
			{
				v2f o;

				//Position extrusion
				float4 newPos = v.vertex;
				newPos += float4(normalize(v.normal), 0.0) * _OutlineWidth;
				o.vertex = UnityObjectToClipPos(newPos);

				o.uv = v.uv;
								//Normal Passing
				o.normal = UnityObjectToClipPos(v.normal);

				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);


				return o;
			}

			fixed _ColorBlendFactor;

			fixed _AnimateOutline;
			fixed _OutlineSpeed;
			fixed _OutlineDot;
			fixed _OutlineDot2;

			fixed _UseOutlineLighting;
			fixed _Atten;

			float4 frag (v2f input) : SV_TARGET
			{
				if(_UseOutline < 0.5f) discard;

				if(_UseOutlineLighting > 0.5)
				{
					float NdotV = 1 - dot(input.normal, input.viewDir) * _Atten;

					return _OutlineColor * NdotV;
				}

				fixed4 color = _OutlineColor;

				if(_AnimateOutline > 0.5)
				{
					float2 pos = input.vertex.xy + _Time * _OutlineSpeed;
					float rest = abs((pos.x + pos.y) % _OutlineDot);				

					if(rest < _OutlineDot2 * 0.5) discard;
				}

				return color;
			}

			ENDCG

		}
	}
}