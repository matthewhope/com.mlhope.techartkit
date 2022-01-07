// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TechArt Kit/Environment Lit"
{
	Properties
	{
		[KeywordEnum(FullColor,Diffuse,Specular,AO,Reflections,Albedo)] _DebugChannels("Debug Channels", Float) = 0
		_LocalLightPosition("Local Light Position", Vector) = (0,0,0,0)
		_Albedo("Albedo", 2D) = "white" {}
		_AmbientOcclusion("Ambient Occlusion", 2D) = "white" {}
		_BaseColor("Base Color", Color) = (0.4528302,0.4528302,0.4528302,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_SpecularMapASmoothness("Specular Map (A Smoothness)", 2D) = "white" {}
		_FresnelStrength("Fresnel Strength", Range( 0 , 1)) = 1
		_FresnelHardness("Fresnel Hardness", Range( 0 , 1)) = 1
		_DiffuseStrength("Diffuse Strength", Float) = 0
		_Cubemap("Cubemap", CUBE) = "white" {}
		_ReflectionStrength("Reflection Strength", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _DEBUGCHANNELS_FULLCOLOR _DEBUGCHANNELS_DIFFUSE _DEBUGCHANNELS_SPECULAR _DEBUGCHANNELS_AO _DEBUGCHANNELS_REFLECTIONS _DEBUGCHANNELS_ALBEDO
			#include "ShaderLibrary/TechArtKit.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _Albedo;
			uniform float4 _Albedo_ST;
			uniform float4 _BaseColor;
			uniform samplerCUBE _Cubemap;
			uniform float _Smoothness;
			uniform float _ReflectionStrength;
			uniform float3 _LocalLightPosition;
			uniform float _DiffuseStrength;
			uniform sampler2D _AmbientOcclusion;
			uniform float4 _AmbientOcclusion_ST;
			uniform sampler2D _SpecularMapASmoothness;
			uniform float4 _SpecularMapASmoothness_ST;
			uniform float _FresnelHardness;
			uniform float _FresnelStrength;
			inline float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max( 0.001f , dot( inVec , inVec ) );
				return inVec* rsqrt( dp3);
			}
			
			float D_GGX62_g177( float3 n, float3 l, float3 v, float roughness, float PI )
			{
				    float NoH = dot(n, normalize( l + v ));
				    float a = NoH * roughness;
				    float k = roughness / (1.0 - NoH * NoH + a * a);
				    return k * k * (1.0 / PI);
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
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
				float2 uv_Albedo = i.ase_texcoord1.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 temp_output_20_0_g162 = reflect( -ase_worldViewDir , ase_worldNormal );
				float lerpResult31_g162 = lerp( 10.0 , 0.0 , _Smoothness);
				float temp_output_2_0_g163 = _ReflectionStrength;
				float temp_output_3_0_g163 = ( 1.0 - temp_output_2_0_g163 );
				float3 appendResult7_g163 = (float3(temp_output_3_0_g163 , temp_output_3_0_g163 , temp_output_3_0_g163));
				float3 temp_output_1104_0 = ( ( texCUBElod( _Cubemap, float4( temp_output_20_0_g162, lerpResult31_g162) ).rgb * temp_output_2_0_g163 ) + appendResult7_g163 );
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 temp_output_1032_0 = ( _LocalLightPosition - WorldPosition );
				float3 normalizeResult14_g157 = ASESafeNormalize( temp_output_1032_0 );
				float dotResult7_g157 = dot( normalizedWorldNormal , normalizeResult14_g157 );
				float2 uv_AmbientOcclusion = i.ase_texcoord1.xy * _AmbientOcclusion_ST.xy + _AmbientOcclusion_ST.zw;
				float temp_output_2_0_g154 = 0.0;
				float temp_output_3_0_g154 = ( 1.0 - temp_output_2_0_g154 );
				float3 appendResult7_g154 = (float3(temp_output_3_0_g154 , temp_output_3_0_g154 , temp_output_3_0_g154));
				float temp_output_21_0_g157 = ( ( ( dotResult7_g157 * _DiffuseStrength ) + _DiffuseStrength ) * ( ( tex2D( _AmbientOcclusion, uv_AmbientOcclusion ).rgb * temp_output_2_0_g154 ) + appendResult7_g154 ).x );
				float3 lerpResult12_g157 = lerp( float3( 0,0,0 ) , temp_output_1104_0 , temp_output_21_0_g157);
				float3 temp_output_13_0_g157 = ( ( ( tex2D( _Albedo, uv_Albedo ) * _BaseColor * float4( temp_output_1104_0 , 0.0 ) ) / UNITY_PI ).rgb * lerpResult12_g157 );
				float2 uv_SpecularMapASmoothness = i.ase_texcoord1.xy * _SpecularMapASmoothness_ST.xy + _SpecularMapASmoothness_ST.zw;
				float temp_output_5_0_g177 = ( tex2D( _SpecularMapASmoothness, uv_SpecularMapASmoothness ).r * min( _Smoothness , 0.99 ) );
				float3 temp_output_30_0_g177 = ase_worldNormal;
				float3 n62_g177 = temp_output_30_0_g177;
				float3 l62_g177 = temp_output_1032_0;
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float3 v62_g177 = ase_worldViewDir;
				float roughness62_g177 = saturate( ( 1.0 - temp_output_5_0_g177 ) );
				float PI62_g177 = UNITY_PI;
				float localD_GGX62_g177 = D_GGX62_g177( n62_g177 , l62_g177 , v62_g177 , roughness62_g177 , PI62_g177 );
				float temp_output_71_0_g177 = pow( localD_GGX62_g177 , temp_output_5_0_g177 );
				float dotResult42_g177 = dot( temp_output_30_0_g177 , float3( 0,0,0 ) );
				float3 temp_output_8_0_g177 = ( temp_output_1104_0 * temp_output_5_0_g177 * temp_output_71_0_g177 * saturate( dotResult42_g177 ) );
				float3 normalizeResult32_g167 = normalize( ( ase_worldViewDir + float3( 0,0,0 ) ) );
				float dotResult6_g167 = dot( ase_worldNormal , normalizeResult32_g167 );
				float lerpResult15_g167 = lerp( -1.0 , 1.0 , _FresnelHardness);
				float temp_output_35_0_g167 = ( saturate( (0.0 + (( 1.0 - dotResult6_g167 ) - lerpResult15_g167) * (1.0 - 0.0) / (1.0 - lerpResult15_g167)) ) * _FresnelStrength );
				float3 temp_output_29_0_g167 = ( temp_output_35_0_g167 * temp_output_1104_0 );
				float3 temp_cast_5 = (temp_output_21_0_g157).xxx;
				float3 temp_cast_6 = (temp_output_71_0_g177).xxx;
				#if defined(_DEBUGCHANNELS_FULLCOLOR)
				float3 staticSwitch790 = ( temp_output_13_0_g157 + saturate( ( temp_output_8_0_g177 + temp_output_29_0_g167 ) ) );
				#elif defined(_DEBUGCHANNELS_DIFFUSE)
				float3 staticSwitch790 = temp_cast_5;
				#elif defined(_DEBUGCHANNELS_SPECULAR)
				float3 staticSwitch790 = temp_cast_6;
				#elif defined(_DEBUGCHANNELS_AO)
				float3 staticSwitch790 = float3( 0,0,0 );
				#elif defined(_DEBUGCHANNELS_REFLECTIONS)
				float3 staticSwitch790 = float3( 0,0,0 );
				#elif defined(_DEBUGCHANNELS_ALBEDO)
				float3 staticSwitch790 = float3( 0,0,0 );
				#else
				float3 staticSwitch790 = ( temp_output_13_0_g157 + saturate( ( temp_output_8_0_g177 + temp_output_29_0_g167 ) ) );
				#endif
				float4 appendResult876 = (float4(staticSwitch790 , 1.0));
				
				
				finalColor = appendResult876;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18933
756;761.6;2315.2;877.0001;-1339.429;316.5063;1.67181;True;False
Node;AmplifyShaderEditor.RangedFloatNode;1067;1871.145,460.931;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1104;2240.492,572.0904;Inherit;False;Reflections  (TechArt Kit);15;;162;6c9dba146efb4884c99238d511e402b6;2,30,1,22,0;4;11;FLOAT3;0,0,0;False;12;SAMPLERCUBE;;False;21;FLOAT3;0,0,0;False;26;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;757;1917.728,-889.2021;Inherit;False;1132.359;698.7568;Albedo;7;1082;687;1076;1075;1083;1084;1125;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;687;2158.988,-840.715;Inherit;True;Property;_Albedo;Albedo;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;1031;2734.865,56.97748;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;1029;2705.545,-99.16549;Inherit;False;Property;_LocalLightPosition;Local Light Position;1;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;1075;2177.819,-642.64;Inherit;False;Property;_BaseColor;Base Color;4;0;Create;True;0;0;0;False;0;False;0.4528302,0.4528302,0.4528302,0;0.4528302,0.4528302,0.4528302,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;1121;2615.283,289.6698;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;1119;2808.32,569.2353;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;1070;2817.753,522.4369;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1076;2781.822,-593.466;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PiNode;1125;2783.65,-404.7867;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1032;2982.649,38.76487;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;1080;2812.826,468.4336;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1082;2133.128,-460.2801;Inherit;True;Property;_AmbientOcclusion;Ambient Occlusion;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1084;2131.204,-261.0811;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1123;3015.524,-481.2286;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1114;3108.726,601.4831;Inherit;False;Fresnel  (TechArt Kit);8;;167;70e5c8b0ed12aac4882e962879c4627f;1,26,0;4;1;FLOAT3;0,0,0;False;30;FLOAT3;1,1,1;False;3;FLOAT3;0,0,0;False;31;FLOAT3;0,0,0;False;2;FLOAT3;0;FLOAT;34
Node;AmplifyShaderEditor.FunctionNode;1136;3250.787,337.1477;Inherit;False;Specular  (TechArt Kit);6;;177;23a0f1b1149421d43bc6737c44508532;1,48,0;7;30;FLOAT3;0,0,0;False;32;FLOAT3;1,1,1;False;31;FLOAT3;0,0,0;False;35;FLOAT;1;False;34;FLOAT;0;False;29;FLOAT3;1,1,1;False;2;FLOAT3;1,1,1;False;2;FLOAT3;0;FLOAT;58
Node;AmplifyShaderEditor.SimpleAddOpNode;1030;3650.471,338.1407;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1126;3198.019,130.3943;Inherit;False;Property;_DiffuseStrength;Diffuse Strength;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1077;3235.811,-268.6689;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;1120;2795.58,426.5433;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1083;2506.023,-454.6469;Inherit;False;Lerp White To;-1;;154;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1087;3485.626,11.28505;Inherit;False;Diffuse (TechArt Kit);-1;;157;d324aad9d4605ca4cb2189514e257ba2;1,17,0;8;2;FLOAT3;1,1,1;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,1,1;False;5;FLOAT;1;False;6;FLOAT;0;False;20;FLOAT;1;False;11;FLOAT3;0,0,0;False;8;FLOAT3;1,1,1;False;2;FLOAT3;0;FLOAT;18
Node;AmplifyShaderEditor.SaturateNode;1090;3805.545,336.7711;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;1122;3672.067,689.0231;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1011;4245.276,-49.3806;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;1091;4048.209,672.0001;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;790;4531.185,-43.36702;Inherit;False;Property;_DebugChannels;Debug Channels;0;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;6;FullColor;Diffuse;Specular;AO;Reflections;Albedo;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1016;2145.788,213.8532;Inherit;False;Normal Maps  (TechArt Kit);12;;84;3079578f90f3a2b48abaeba94d0659ee;1,37,0;2;26;FLOAT3;0,0,0;False;27;SAMPLER2D;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PiNode;1118;3108.407,856.4903;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;876;4769.089,-154.8895;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1117;3340.281,780.0484;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;24;5227.661,-114.1526;Float;False;True;-1;2;ASEMaterialInspector;100;1;TechArt Kit/Environment Lit;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;False;1;False;-1;255;False;-1;255;False;-1;6;False;-1;2;False;-1;3;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0.5;False;-1;0.5;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;2;Include;;False;;Native;Include;ShaderLibrary/TechArtKit.cginc;False;;Custom;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;1104;26;1067;0
WireConnection;1121;0;1104;0
WireConnection;1119;0;1104;0
WireConnection;1070;0;1104;0
WireConnection;1076;0;687;0
WireConnection;1076;1;1075;0
WireConnection;1076;2;1121;0
WireConnection;1032;0;1029;0
WireConnection;1032;1;1031;0
WireConnection;1080;0;1067;0
WireConnection;1123;0;1076;0
WireConnection;1123;1;1125;0
WireConnection;1114;30;1119;0
WireConnection;1136;32;1032;0
WireConnection;1136;35;1080;0
WireConnection;1136;29;1070;0
WireConnection;1030;0;1136;0
WireConnection;1030;1;1114;0
WireConnection;1077;0;1123;0
WireConnection;1120;0;1104;0
WireConnection;1083;1;1082;0
WireConnection;1083;2;1084;0
WireConnection;1087;2;1077;0
WireConnection;1087;4;1032;0
WireConnection;1087;5;1126;0
WireConnection;1087;6;1126;0
WireConnection;1087;20;1083;0
WireConnection;1087;8;1120;0
WireConnection;1090;0;1030;0
WireConnection;1122;0;1136;58
WireConnection;1011;0;1087;0
WireConnection;1011;1;1090;0
WireConnection;1091;0;1122;0
WireConnection;790;1;1011;0
WireConnection;790;0;1087;18
WireConnection;790;2;1091;0
WireConnection;876;0;790;0
WireConnection;1117;1;1118;0
WireConnection;24;0;876;0
ASEEND*/
//CHKSM=2570739FE0786D04E227BB11CFBC3F8360D6407A