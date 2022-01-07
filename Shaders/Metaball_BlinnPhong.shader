// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Pixel Theory/Metaball/BlinnPhong"
{
Properties
	{
		// ******************************************************************************************** //
		// VARIABLE NAME		NAME IN PROPERTY WINDOW			EDITOR BOX			DEFAULT VALUE		//
		// ******************************************************************************************** //

		// Diffuse
		_Color 					("Tint", 						Color)			= 	(0.2, 0.3, 0.4, 1)
		_DiffusePower 			("Diffuse Power", 				Float) 			= 	3
		// Specular
		_SpecStrength   		("Specular Strength",           Float) 			=	1.0
		_SpecPower 				("Specular Remap", 				Vector)         =	(0, 1, 0, 1)
		_SpecAtten 				("Specular Attenuation", 		Range(0,3)) 	= 	1
		_Roughness				("Roughness", 					Float)			= 	7.0
		// Fresnel
		_FresnelBias 			("Fresnel Bias", 				Range(0,1)) 	= 	1
		_FresnelScale 			("Fresnel Scale", 				Range(0,2)) 	= 	1
		_FresnelPower 			("Fresnel Power", 				Range(1,10)) 	=	3
		// Radial Basis Function
		_K 						("RadialBasis Constant", 		Float) 			= 	7
		_Threshold 				("Isosurface Threshold",		Range(0,1)) 	= 	0.5
		_Epsilon 				("Normal Epsilon", 				Range(0,1)) 	= 	0.1
		_GradientTex			("Gradient", 					2D)				= "white" {}
		_LightDir				("Light Direction",             Vector)			=  (0,0,0,0)			
		_Size                   ("Size",                        Float)			= 1.0
		_MatcapTexture			("Matcap Texture", 				2D)				= "white" {}
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" "LightMode"="ForwardBase" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off		// Draw all faces
		ZWrite Off 		// Don't write on the Zbuffer
		Lighting Off	// Don't let unity do lighting calculations.

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
			// StructuredBuffer<float4> particlePositions;

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color  : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex        : SV_POSITION;
				float2 uv		     : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				float4 color         : TEXCOORD2;
				float4 screenPos	 : TEXCOORD3;
			};

			// uniform float4 _ParticlesPos[100];	// The world position of all particles, feeded with c# script.
			uniform sampler2D _DataTexture;
			uniform float _DataTexelSize;
			uniform int _Particles;
			float4 _LightDir	;

			float4 _Color;						// Diffuse Color.
			float  _DiffusePower;				// Diffuse Power.
			float  _Roughness;

			float  _SpecStrength;					// Specular Color.
			float4 _SpecPower;					// Specular Power.
			fixed _SpecAtten;					// Specular Scale.

			fixed _FresnelBias;					// Fresnel Bias (shift).
			fixed _FresnelScale;				// Fresnel Scale.
			float _FresnelPower;				// Fresnel Power.

			float _K;							// Radial basis function constant.
			fixed _Threshold;					// Isosurface threshold.
			fixed _Epsilon;						// Epsilon to approximate normal on isosurface.
			float _Size;
	
			sampler2D _MatcapTexture;

			sampler2D _GradientTex;
			float4    _GradientTex_ST;

			float remap(float value, float low1, float high1, float low2, float high2)
			{
				return low2 + (value - low1) * (high2 - low2) / (high1 - low1); 
			}

			float3 remap(float3 value, float3 low1, float3 high1, float3 low2, float3 high2)
			{
				return low2 + (value - low1) * (high2 - low2) / (high1 - low1); 
			}

			float scalarField(float3 pos){
				float density = 0;
				//for(int i = 0; i < _Particles; i++){
				for(int i = 0; i < 20; i++){
					float2 dataUV = float2(_DataTexelSize * (i + 0.5), 0.5);
					float4 data = tex2Dlod(_DataTexture, float4(dataUV, 0.0, 0.0));


					float dis = distance(pos, data.rgb);
					
					// float factor = -lerp(100, 7, saturate(_ParticlesPos[i].w));

					density += exp(-_K * dis) * data.w;
				}
				return density;
			}

			float scalarField(float x, float y, float z){
				float3 pos = float3(x,y,z);
				return scalarField(pos);
			}

			float3 calcNormal(float3 p){
				float3 N;
				N.x = scalarField(p.x + _Epsilon, p.y, p.z) - scalarField(p.x - _Epsilon, p.y, p.z);
				N.y = scalarField(p.x, p.y + _Epsilon, p.z) - scalarField(p.x, p.y - _Epsilon, p.z);
				N.z = scalarField(p.x, p.y, p.z + _Epsilon) - scalarField(p.x, p.y, p.z - _Epsilon);
//				N /= 2 * _Epsilon;
				return -N;
			}

			float3 reflectionColor(float3 viewDir, float3 normal)
			{
				// float3 reflectDir = reflect(-viewDir, normal);
				// float4 color = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, _Roughness);
				//
				// float4 HDR;
				// HDR.rgb = DecodeHDR(color, unity_SpecCube0_HDR);
				// HDR.w = 1.0;

				// ELLIS TEMP
				return normalize(float4(sin(_Time / 2.0))).rgb;

				//return HDR;
			}

			float3 blinnPhong(float3 V, float3 N, float3 L, float3 baseColor){
				float3 H = normalize(V + L);
				float NdotH = dot(reflect(1.0-L, N), V); // for specular.
				float NdotV = dot(N, V); // for fresnel.
				float LdotN = (0.5 * dot(H,N) + 1.5) * _DiffusePower; // for diffuse.

				// float3 reflections = reflectionColor(V, N);

				float3 diffuseTerm =   _Color * baseColor * LdotN;
				float3 fresnel = _FresnelBias + _FresnelScale * pow(1 - NdotV, _FresnelPower);
				float3 specularTerm = saturate(remap(NdotH, 
													_SpecPower.x, 
													_SpecPower.y + _SpecPower.x,
													_SpecPower.z, 
													_SpecPower.w)) * _SpecAtten * _SpecStrength;

				return diffuseTerm + ((fresnel + specularTerm) * baseColor);
			}

			fixed3 matcap(sampler2D tex, half3 normal)
			{
				fixed3 col;
				float2 uv = mul(UNITY_MATRIX_V, normal).xy * 0.5 + 0.5;
				
				col.rgb = tex2D(tex, uv);

				return col;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				o.color = v.color;
				o.uv = v.texcoord;
				return o;
			}


			float4 frag (v2f i) : SV_Target
			{
				// initial color of the fragment.
				float4 col = _Color;
				col.a = 0;
				float2 screenUV = i.screenPos.xy / i.screenPos.w;
				// float  cameraDistance = distance(_WorldSpaceCameraPos, i.worldPosition);
				float3 gradient = tex2D(_GradientTex, screenUV * _GradientTex_ST.xy + _GradientTex_ST.zw + float2(_Time.x * 2.0, 0.0));
				// float2 uv = i.uv;
				
				// prepare to raycast.
				float3 viewDir = normalize(i.worldPosition - _WorldSpaceCameraPos.xyz); // World space direction from cam to fragment.
				float3 start = i.worldPosition - 2.0 * viewDir; // Start sampling two unit before the fragment along the viewDir.
				float3 p; // The sample point.

				// We now start sampling on the ray. We will be sampling each 0.2 points along the ray for a maximum length of 3 units.
				// And once we find an intersection with the isosurface, we sample again with a smaller step till we can pinpoint the
				// exact point of intersection.
				for(float i = 0; i < 3.0; i+=0.2){
					p = start + i * viewDir;

					if(scalarField(p) > _Threshold){
						// now, sample each 0.05 from (p - 0.2, p + 0.2)
						float3 start2 = p - 0.2 * viewDir;
						for(float i = 0.05; i < 0.4; i+=0.05){
							p = start2 + i * viewDir;

							if(scalarField(p) > _Threshold){
								// finally, sample each 0.01 from (p - 0.05, p + 0.05)
								float3 start3 = p - 0.05 * viewDir;
								for(float i = 0.01; i < 0.1; i+=0.01){
									p = start3 + i * viewDir;
									if(scalarField(p) > _Threshold){
										break;
									}
								}
								break;
							}
						}

						// ... calculate its normal.
						float3 N = normalize(calcNormal(p));
						// ... calculate the lightDir.
						float3 L = _LightDir.xyz;
						// ... illuminate with blinnPhong
						col.xyz = blinnPhong(-viewDir, N, L, saturate(gradient));
						// col.rgb = L;
						// ... make it visible.
						col.a = 1;
						break;
					}
				}
				
				// col.rgb = gradient;
				// col.rgb = tex2D(_DataTexture, uv);
				// col.a = 1.0;
				return col;
			}

			ENDCG
		}
	}
}