Shader "Modules/Voronoi/VoronoiPlaneUnit"
{
	SubShader 
	{

		

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				//o.worldPos = v.vertex;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			uniform int _Length;
			uniform half2 _Points[100];
			uniform fixed3 _Colors[100];

			half4 frag (v2f output) : COLOR
			{
				half minDist = 1000000;
				half dist = 0;
				int minI = 0;
				fixed4 o = fixed4(1.0,1.0,0.0,1.0);
				int inRange = 0;

				for (int i = 0; i < _Length;i++)
				{
					
					half dist = distance(output.pos.xy, _Points[i].xy);
					if(dist < minDist)
					{
						minDist = dist;
						minI = i;
						inRange = 1;
					}
				}

				if(dist < 1) o = fixed4(1.0,1.0,1.0,1.0);
				else
				{
					o = fixed4(_Colors[minI], 1);

				}



				return o;
			}
			ENDCG
		}	

	}
}
