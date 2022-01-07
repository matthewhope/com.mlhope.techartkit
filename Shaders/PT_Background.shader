// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pixel Theory/Background"
{
	Properties
	{
		_Rotate("Rotate", Range( 0 , 1)) = 0
		[KeywordEnum(Cube,Reflection)] _CubemapProjection("Cubemap Projection", Float) = 0
		_Interpolate("Mural <--> Skybox", Range( 0 , 1)) = 1
		_Mip("Mip", Range( 0 , 10)) = 0
		[Toggle(_VERTEXCOLOR_ON)] _VertexColor("Vertex Color", Float) = 0
		[KeywordEnum(UV,Skybox)] _Coordinates("Coordinates", Float) = 1
		_Cube("_Cube", CUBE) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Background" "Queue"="Background" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define ASE_USING_SAMPLING_MACROS 1


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _COORDINATES_UV _COORDINATES_SKYBOX
			#pragma shader_feature_local _CUBEMAPPROJECTION_CUBE _CUBEMAPPROJECTION_REFLECTION
			#pragma shader_feature_local _VERTEXCOLOR_ON
			#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
			#define SAMPLE_TEXTURECUBE_LOD(tex,samplerTex,coord,lod) tex.SampleLevel(samplerTex,coord, lod)
			#else//ASE Sampling Macros
			#define SAMPLE_TEXTURECUBE_LOD(tex,samplertex,coord,lod) texCUBElod (tex,half4(coord,lod))
			#endif//ASE Sampling Macros
			


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			UNITY_DECLARE_TEXCUBE_NOSAMPLER(_Cube);
			uniform float _Rotate;
			uniform float _Interpolate;
			uniform float _Mip;
			SamplerState sampler_Cube;
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			inline float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max( 0.001f , dot( inVec , inVec ) );
				return inVec* rsqrt( dp3);
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord1 = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord5.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 _Origin = float3(0,1.5,0);
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				#if defined(_CUBEMAPPROJECTION_CUBE)
				float3 staticSwitch80_g47 = ( ase_worldViewDir * float3( 1,-1,-1 ) );
				#elif defined(_CUBEMAPPROJECTION_REFLECTION)
				float3 staticSwitch80_g47 = ase_worldViewDir;
				#else
				float3 staticSwitch80_g47 = ( ase_worldViewDir * float3( 1,-1,-1 ) );
				#endif
				float3 lerpResult83_g47 = lerp( ( ( mul( UNITY_MATRIX_M, float4( i.ase_texcoord1.xyz , 0.0 ) ).xyz * float3(-1,1,1) ) - _Origin ) , staticSwitch80_g47 , _Interpolate);
				float3 rotatedValue94_g47 = RotateAroundAxis( _Origin, lerpResult83_g47, normalize( float3( 0,1,0 ) ), ( ( _Rotate * 2.0 ) * UNITY_PI ) );
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3x3 ase_worldToTangent = float3x3(ase_worldTangent,ase_worldBitangent,ase_worldNormal);
				float3 objectToTangentDir93_g47 = ASESafeNormalize( mul( ase_worldToTangent, mul( unity_ObjectToWorld, float4( i.ase_normal, 0 ) ).xyz) );
				#if defined(_COORDINATES_UV)
				float3 staticSwitch130_g47 = float3( i.ase_texcoord5.xy ,  0.0 );
				#elif defined(_COORDINATES_SKYBOX)
				float3 staticSwitch130_g47 = reflect( rotatedValue94_g47 , objectToTangentDir93_g47 );
				#else
				float3 staticSwitch130_g47 = reflect( rotatedValue94_g47 , objectToTangentDir93_g47 );
				#endif
				float4 temp_cast_3 = (1.0).xxxx;
				#ifdef _VERTEXCOLOR_ON
				float4 staticSwitch109_g47 = i.ase_color;
				#else
				float4 staticSwitch109_g47 = temp_cast_3;
				#endif
				
				
				finalColor = saturate( ( SAMPLE_TEXTURECUBE_LOD( _Cube, sampler_Cube, staticSwitch130_g47, _Mip ) * staticSwitch109_g47 ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18933
0;895.2;3072;744;-173.6307;1847.863;1.640807;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;376;-4698.053,-2216.61;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;533;1813.87,-769.9286;Inherit;False;Cubemap;0;;47;9474fe2122d524140a97a11a4d373be2;0;2;121;FLOAT;0;False;131;SAMPLERCUBE;;False;2;COLOR;0;COLOR;136
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;3374.223,-718.4839;Float;False;True;-1;2;ASEMaterialInspector;100;1;Pixel Theory/Background;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Background=RenderType;Queue=Background=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;0;0;0;1;True;False;;True;0
WireConnection;0;0;533;0
ASEEND*/
//CHKSM=315B7E492EA049229A54C500805594B0CD12BBC0