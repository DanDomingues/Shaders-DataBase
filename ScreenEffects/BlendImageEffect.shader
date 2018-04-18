Shader "ShaderCookbook/Chapter 8/BlendImageEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlendTex ("Blend Texture", 2D) = "white"  {}
		_Opacity ("Blend Opacity", Range(0.0,1 )) = 1.0
		_BlendMode("Mode", Float) = 0.0

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
			uniform sampler2D _BlendTex;
			fixed _Opacity;
			fixed _BlendMode;


			fixed OverlayBlendMode(fixed basePixel, fixed blendPixel)
			{
				if(basePixel < 0.5)
				{
					return (2.0  * basePixel * blendPixel);
				}
				else
				{
					return (1.0 - (2.0 * (1.0 - basePixel) * (1.0 - blendPixel)));
				}
			}

			fixed4 frag (v2f_img i) : COLOR
			{
				fixed4 renderTex = tex2D(_MainTex, i.uv);
				fixed4 blendTex = tex2D(_BlendTex, i.uv);

				fixed4 blend = blendTex;

				//Multiply
				if(_BlendMode < 0.5)
				{
					blend = renderTex * blendTex;
				}

				//Add
				else if(_BlendMode < 1.5)
				{
					blend = renderTex + blendTex;
				}

				//Blend
				else if (_BlendMode < 2.5)
				{
					blend = (1.0 - ((1.0 - renderTex) * (1.0 - blendTex)));
				}

				//Overlay
				else if (_BlendMode < 3.5)
				{
					 blend.r = OverlayBlendMode(renderTex.r, blendTex.r);
					 blend.g = OverlayBlendMode(renderTex.g, blendTex.g);
					 blend.b = OverlayBlendMode(renderTex.b, blendTex.b);

				}

				renderTex = lerp(renderTex, blend, _Opacity);

				//fixed4 finalColor = fixed4( lerp(col.r,gray.r, _LumR), gray.g, gray.b, gray.alpha);

				return renderTex;
			}
			ENDCG
		}
	}
}
