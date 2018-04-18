// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Modules/CellShaderOutline" 
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RampTex ("Toon Ramp", 2D) = "white" {}
		_Color ("Tint Color", Color) = (1,1,1,1)
		_LightFactor("Lighting Factor", Range(0.5,5.0)) = 1.0

		[Space(10)]
		[Header(Base Outline)]

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
		//Color Pass
		Pass
		{
			Stencil
			{
				Ref 1
				Comp Always
				Pass Replace
				//ZFail Keep
			}

			Cull Off Zwrite On ZTest On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToClipPos(v.normal);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _RampTex;

			float4 _Color;
			float _LightFactor;

			float4 frag (v2f input) : SV_Target
			{
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				float ramp = clamp(dot(input.normal, lightDir), 0, 1.0);
				float3 lighting = tex2D(_RampTex, float2(ramp, 0.5)).rgb * _LightFactor;

				float4 albedo = tex2D(_MainTex, input.uv);

				float3 rgb = albedo.rgb * lighting * _Color.rgb;
				return float4(rgb, 1.0);
			}
			ENDCG
		}

		//Outline Pass
		Pass
		{
			Zwrite Off// ZTest Always
			ZTest Always

			Stencil
			{
				Ref 1
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

				//Position extrusion
				float4 newPos = v.position;
				newPos += float4(normalize(v.normal), 0.0) * _OutlineWidth;
				output.position = UnityObjectToClipPos(newPos);

				output.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.position).xyz);

				//Normal Passing
				output.normal = UnityObjectToWorldNormal(v.normal);
				output.uv = v.uv;
				
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
	}
}