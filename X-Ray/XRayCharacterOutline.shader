﻿Shader "Custom/XRayCharacterOutline" 
{
		Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Tint Color", Color) = (1,1,1,1)
		_LightFactor("Lighting Factor", Range(0.5,5.0)) = 1.0
		_StencilID("Stencil ID", Int) = 1

		[Space(10)]
		[Header(Base Outline)]

		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		_OutlineWidth("Outline Width", Range(0, 0.1)) = 1.0
		[Toggle] _UseOutline ("Outline Active", Float) = 1.0
		
		[Space(10)]
		[Header(Outline Texture Blend)]
		[Toggle] _UseBaseColor ("Use Texture's Color", Float) = 0.0
		_BaseColorMod("Base Color Modifier", Color) = (1,1,1,1)
		_ColorBlendFactor("Color Blend Factor", Range(0.0,1.0)) = 0.5

		[Space(10)]
		[Header(Vertex Lighting Module)]
		[Toggle] _UseOutlineLighting("Use Lighting on Outline", Float) = 0.5
		_Atten ("Edge Lighting Atten", Range(0.0,10.0)) = 1.5

		[Space(10)]
		[Header(Outline Animation)]
		[Toggle]_AnimateOutline("Animate Outline", Float) = 0.0
		_StripColor ("Strip Color", Color) = (1,1,1,1)

		_OutlineSpeed("Outline Speed", Float) = 1.0
		_OutlineDot("Base Strip Width", Float) = 1.0
		_OutlineDot2("Colored Strip Width", Float) = 1.0

		[Space(10)]
		[Header(XRay)]
		_XRayColor ("XRay Color", Color) = (1,1,1,1)
		[Toggle] _UseXRay ("XRay Active", Float) = 1.0
		[Toggle] _UseXRayLighting("Use Lighting on XRay", Float) = 0.5
		[Toggle]_AnimateXRay("Animate XRay", Float) = 0.0

	}
	SubShader
	{
		Zwrite Off// ZTest Always

		//XRay Outline Pass
		Pass
		{
			ZTest Always
			ZWrite Off

			Stencil
			{
				Ref [_StencilID]
				Comp notequal
				Pass replace
				Fail keep
			}

			Tags
			{
				"Queue" = "Transparent"
				"RenderType" = "Opaque"
			}


			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD1;
				float4 color : COLOR;
			};
			
			float _UseXRay;
			float _UseOutline;
			float _UseBaseColor;
			float _OutlineWidth;
			fixed4 _OutlineColor;
			fixed4 _BaseColorMod;

			sampler2D _MainTex;
			float4 _Color;

			v2f vert(appdata v) 
			{
				v2f output;
				output.uv = v.uv;
				//Position extrusion

				output.position = UnityObjectToClipPos(v.position);

				// if(_UseOutline > 0.5)
				// {
				// 	float4 newPos = v.position;
				// 	newPos += float4(normalize(v.normal), 0.0) * _OutlineWidth;
				// 	output.position = UnityObjectToClipPos(newPos);
				// }

				output.normal = UnityObjectToWorldNormal(v.normal);

				output.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.position).xyz);	
				output.color = tex2Dlod(_MainTex, float4(output.uv, 0, 0)) * _Color;

				return output;
			}

			float _ColorBlendFactor;

			float _AnimateXRay;
			float _OutlineSpeed;
			float _OutlineDot;
			float _OutlineDot2;

			fixed4 _XRayColor;
			fixed4 _StripColor;

			float _UseXRayLighting;
			float _Atten;

			float4 frag (v2f input) : SV_TARGET
			{
				//discard;
				if(_UseXRay < 0.5f) discard;

				fixed4 color = _XRayColor;
				if(_UseBaseColor > 0.5)
				{
					color = lerp(input.color, _BaseColorMod, _ColorBlendFactor);
				}

				if(_AnimateXRay > 0.5)
				{
					float2 pos = input.position.xy + _Time * _OutlineSpeed;
					float rest = abs((pos.x + pos.y) % _OutlineDot);				

					if(rest < _OutlineDot2 * 0.5)
					{
						color = _StripColor;
						if(_StripColor.a < 0.1) discard;

					}
				}

				if(_UseXRayLighting > 0.5)
				{
					float NdotV = 1 - dot(input.normal, input.viewDir) * _Atten;
					color *= NdotV;
				}

				return color;
			}

			ENDCG

		}

		//Outline Pass
		Pass
		{
			ZWrite Off

			Tags
			{
				"Queue" = "Transparent"
				"RenderType" = "Opaque"
			}


			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD1;
				float4 color : COLOR;
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
				v2f output;
				output.uv = v.uv;
				//Position extrusion
				float4 newPos = v.position;
				newPos += float4(normalize(v.normal), 0.0) * _OutlineWidth;
				output.position = UnityObjectToClipPos(newPos);
				output.normal = UnityObjectToWorldNormal(v.normal);

				output.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.position).xyz);	
				output.color = tex2Dlod(_MainTex, float4(output.uv, 0, 0)) * _Color;

				return output;
			}

			float _ColorBlendFactor;

			float _AnimateOutline;
			float _OutlineSpeed;
			float _OutlineDot;
			float _OutlineDot2;

			float _UseOutlineLighting;
			float _Atten;

			float4 frag (v2f input) : SV_TARGET
			{

				if(_UseOutline < 0.5f) discard;

				if(_UseOutlineLighting > 0.5)
				{
					float NdotV = 1 - dot(input.normal, input.viewDir) * _Atten;

					return _OutlineColor * NdotV;
				}

				fixed4 color = _OutlineColor;
				if(_UseBaseColor > 0.5)
				{
					color = lerp(input.color, _BaseColorMod, _ColorBlendFactor);
				}

				if(_AnimateOutline > 0.5)
				{
					float2 pos = input.position.xy + _Time * _OutlineSpeed;
					float rest = abs((pos.x + pos.y) % _OutlineDot);				

					if(rest < _OutlineDot2 * 0.5) discard;
				}

				return color;
			}

			ENDCG

		}
			
		Stencil
		{
			Ref [_StencilID]
			Comp always
			Pass replace
		}

		CGPROGRAM

		#pragma surface surf Lambert
		#pragma target 4.0

		sampler2D _MainTex;
		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 color = tex2D(_MainTex, IN.uv_MainTex) * _Color;

			//discard;
			o.Albedo = color.rgb;
			o.Alpha = 0;
		}

		ENDCG
	}

	Fallback "Diffuse"	
}
