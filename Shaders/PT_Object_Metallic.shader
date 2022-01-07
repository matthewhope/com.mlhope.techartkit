// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pixel Theory/Object (Metallic)"
{
	Properties
	{
		_FresnelStart("Fresnel Start", Range( 0 , 1)) = 0
		_Highlight("Highlight", Range( 0 , 1)) = 0
		_FresnelStrength("Fresnel Strength", Range( 0 , 1)) = 0
		_HighlightColor("Highlight Color", Color) = (0,0,0,0)
		_FresnelEnd("Fresnel End", Range( 0 , 1)) = 1
		_NormalMaps("Normal Maps", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Float) = 0
		_Cubemap("Cubemap", CUBE) = "white" {}
		_ReflectionStrength("Reflection Strength", Range( 0 , 1)) = 1
		_BaseColor("Base Color", Color) = (1,1,1,0)
		_SpecularColor("Specular Color", Color) = (1,1,1,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_AmbientOcclusion("Ambient Occlusion", 2D) = "white" {}
		[KeywordEnum(UV0,UV1,UV2)] _AOUVSet("AO UV Set", Float) = 0
		_AOInfluence("AO Influence", Range( 0 , 1)) = 1
		_SpecularMapASmoothness("Specular Map (A Smoothness)", 2D) = "white" {}
		_StaticLightDirection("Static Light Direction", Vector) = (0,0,0,0)
		_MetallicMatcap("Metallic Matcap", 2D) = "white" {}
		_Albedo("Albedo", 2D) = "white" {}
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
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _AOUVSET_UV0 _AOUVSET_UV1 _AOUVSET_UV2


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _Albedo;
			uniform float4 _Albedo_ST;
			uniform sampler2D _MetallicMatcap;
			uniform sampler2D _NormalMaps;
			uniform float4 _NormalMaps_ST;
			uniform float _NormalStrength;
			uniform sampler2D _AmbientOcclusion;
			uniform float _AOInfluence;
			uniform float3 _StaticLightDirection;
			uniform samplerCUBE _Cubemap;
			uniform sampler2D _SpecularMapASmoothness;
			uniform float4 _SpecularMapASmoothness_ST;
			uniform float _Smoothness;
			uniform float _ReflectionStrength;
			uniform float4 _BaseColor;
			uniform float4 _SpecularColor;
			uniform float _FresnelStart;
			uniform float _FresnelEnd;
			uniform float _FresnelStrength;
			uniform float4 _HighlightColor;
			uniform float _Highlight;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult4_g23 = dot( ase_worldViewDir , ase_worldNormal );
				float temp_output_20_0_g23 = saturate( (0.0 + (( 1.0 - dotResult4_g23 ) - _FresnelStart) * (1.0 - 0.0) / (_FresnelEnd - _FresnelStart)) );
				float lerpResult5_g23 = lerp( 0.0 , temp_output_20_0_g23 , _FresnelStrength);
				float vertexToFrag21_g23 = lerpResult5_g23;
				o.ase_texcoord2.w = vertexToFrag21_g23;
				float vertexToFrag22_g23 = temp_output_20_0_g23;
				o.ase_texcoord3.z = vertexToFrag22_g23;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord1.zw = v.ase_texcoord1.xy;
				o.ase_texcoord3.xy = v.ase_texcoord2.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
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
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float2 uv_NormalMaps = i.ase_texcoord1.xy * _NormalMaps_ST.xy + _NormalMaps_ST.zw;
				float3 tex2DNode902 = UnpackNormal( tex2D( _NormalMaps, uv_NormalMaps ) );
				float3 temp_cast_0 = (tex2DNode902.b).xxx;
				float temp_output_2_0_g37 = _NormalStrength;
				float temp_output_3_0_g37 = ( 1.0 - temp_output_2_0_g37 );
				float3 appendResult7_g37 = (float3(temp_output_3_0_g37 , temp_output_3_0_g37 , temp_output_3_0_g37));
				float3 appendResult901 = (float3(( (tex2DNode902).xy * _NormalStrength ) , ( ( temp_cast_0 * temp_output_2_0_g37 ) + appendResult7_g37 ).x));
				float3 temp_output_903_0 = BlendNormals( ase_worldNormal , appendResult901 );
				float4 appendResult14_g43 = (float4((tex2Dlod( _MetallicMatcap, float4( ( 0.5 + ( 0.5 * (mul( UNITY_MATRIX_V, float4( temp_output_903_0 , 0.0 ) ).xyz).xy ) ), 0, 0.0) )).rgb , 1.0));
				float3 temp_output_198_0_g49 = ( tex2D( _Albedo, uv_Albedo ) * appendResult14_g43 ).rgb;
				#if defined(_AOUVSET_UV0)
				float2 staticSwitch230_g49 = i.ase_texcoord1.xy;
				#elif defined(_AOUVSET_UV1)
				float2 staticSwitch230_g49 = i.ase_texcoord1.zw;
				#elif defined(_AOUVSET_UV2)
				float2 staticSwitch230_g49 = i.ase_texcoord3.xy;
				#else
				float2 staticSwitch230_g49 = i.ase_texcoord1.xy;
				#endif
				float3 temp_cast_7 = (tex2D( _AmbientOcclusion, staticSwitch230_g49 ).r).xxx;
				float temp_output_2_0_g51 = _AOInfluence;
				float temp_output_3_0_g51 = ( 1.0 - temp_output_2_0_g51 );
				float3 appendResult7_g51 = (float3(temp_output_3_0_g51 , temp_output_3_0_g51 , temp_output_3_0_g51));
				float3 temp_output_209_0_g49 = ( ( temp_cast_7 * temp_output_2_0_g51 ) + appendResult7_g51 );
				float3 normalizeResult292_g49 = normalize( _StaticLightDirection );
				float dotResult291_g49 = dot( ase_worldNormal , normalizeResult292_g49 );
				float2 _Vector0 = float2(0.5,1.5);
				float temp_output_257_0_g49 = (dotResult291_g49*_Vector0.x + _Vector0.y);
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 temp_output_20_0_g52 = reflect( -ase_worldViewDir , ase_worldNormal );
				float2 uv_SpecularMapASmoothness = i.ase_texcoord1.xy * _SpecularMapASmoothness_ST.xy + _SpecularMapASmoothness_ST.zw;
				float temp_output_224_0_g49 = ( tex2D( _SpecularMapASmoothness, uv_SpecularMapASmoothness ).r * _Smoothness );
				float temp_output_220_0_g49 = temp_output_224_0_g49;
				float lerpResult289_g49 = lerp( 10.0 , 0.0 , temp_output_220_0_g49);
				float temp_output_26_0_g52 = lerpResult289_g49;
				float temp_output_2_0_g53 = _ReflectionStrength;
				float temp_output_3_0_g53 = ( 1.0 - temp_output_2_0_g53 );
				float3 appendResult7_g53 = (float3(temp_output_3_0_g53 , temp_output_3_0_g53 , temp_output_3_0_g53));
				float3 temp_output_317_0_g49 = ( ( texCUBElod( _Cubemap, float4( temp_output_20_0_g52, temp_output_26_0_g52) ).rgb * temp_output_2_0_g53 ) + appendResult7_g53 );
				float3 temp_output_56_0_g49 = temp_output_903_0;
				float dotResult248_g49 = dot( normalizeResult292_g49 , temp_output_56_0_g49 );
				float dotResult104_g49 = dot( reflect( ( 1.0 - normalizeResult292_g49 ) , temp_output_56_0_g49 ) , ase_worldViewDir );
				float4 temp_output_49_0_g49 = ( _SpecularColor * temp_output_224_0_g49 * (0.05 + (saturate( pow( saturate( ( saturate( dotResult248_g49 ) * dotResult104_g49 ) ) , ( temp_output_220_0_g49 * 5.0 ) ) ) - 0.0) * (1.0 - 0.05) / (1.0 - 0.0)) * float4( temp_output_317_0_g49 , 0.0 ) );
				float3 temp_output_1_0_g23 = ( ( float4( temp_output_198_0_g49 , 0.0 ) * float4( temp_output_209_0_g49 , 0.0 ) * float4( ( temp_output_257_0_g49 * temp_output_317_0_g49 ) , 0.0 ) * _BaseColor ) + temp_output_49_0_g49 ).rgb;
				float vertexToFrag21_g23 = i.ase_texcoord2.w;
				float vertexToFrag22_g23 = i.ase_texcoord3.z;
				float4 lerpResult9_g23 = lerp( float4( ( temp_output_1_0_g23 + saturate( ( temp_output_1_0_g23 * vertexToFrag21_g23 ) ) ) , 0.0 ) , _HighlightColor , ( vertexToFrag22_g23 * _Highlight ));
				float4 appendResult876 = (float4((lerpResult9_g23).rgb , 1.0));
				
				
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
0;1070.4;2795;569.2;819.8796;865.8973;1.730331;True;False
Node;AmplifyShaderEditor.SamplerNode;902;368.8564,-361.7217;Inherit;True;Property;_NormalMaps;Normal Maps;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;904;770.8371,-268.6429;Inherit;False;Property;_NormalStrength;Normal Strength;11;0;Create;True;0;0;0;False;0;False;0;0.075;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;900;902.4218,-354.7922;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;906;1094.734,-331.1111;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;899;935.7339,-165.1111;Inherit;False;Lerp White To;-1;;37;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;905;1080.445,-599.6542;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;901;1237.422,-320.7921;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;889;1682.504,-748.4724;Inherit;True;Property;_MetallicMatcap;Metallic Matcap;34;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;757;2023.728,-889.2021;Inherit;False;966.9757;446.5406;Diffuse Terms;3;687;775;888;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BlendNormalsNode;903;1708.336,-405.7811;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;687;2175.508,-784.7489;Inherit;True;Property;_Albedo;Albedo;36;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;908;2164.404,-572.4724;Inherit;False;MatcapTexture;1;;43;769392ba5f29801468dcb1809168b96b;0;3;9;SAMPLER2D;;False;10;FLOAT;0;False;15;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;888;2537.404,-671.4724;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;775;2667.622,-610.1001;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;910;2358.313,-381.8315;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;911;3052.229,-710.3745;Inherit;False;BakedGI;12;;49;627e98e461f22b541b8c98e012256e4d;0;3;318;FLOAT3;0,0,0;False;198;FLOAT3;0,0,0;False;56;FLOAT3;0,0,0;False;6;COLOR;197;FLOAT;0;COLOR;28;FLOAT3;141;FLOAT3;223;FLOAT3;135
Node;AmplifyShaderEditor.FunctionNode;885;3751.457,-440.8715;Inherit;False;FresnelHighlighter;4;;23;c50e3af94f70afc4783b159d4f2fcc5d;0;1;1;FLOAT3;0,0,0;False;2;COLOR;0;FLOAT;23
Node;AmplifyShaderEditor.CommentaryNode;749;-3861.85,-1007.552;Inherit;False;1480.875;559.7739;Reflections;9;697;691;693;694;678;713;672;772;773;;0,0.4633408,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;748;-1087.379,-1525.938;Inherit;False;898.3652;395.847;Highlight;5;739;738;716;737;747;;0.2926462,1,0,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;875;4024.504,-434.8632;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;756;-2913.801,-1881.996;Inherit;False;278.0268;173.9281;Approximate SH Light Dir;1;644;;1,0.6982701,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;750;-2325.871,-1381.315;Inherit;False;1083.486;448.6442;Fresnel;9;742;732;727;741;733;743;728;740;725;;0,0.282353,0.6117647,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;740;-2275.871,-1049.934;Inherit;False;Property;_Highlight;Highlight;38;0;Create;True;0;0;0;False;0;False;0.04638387;0.04638387;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;764;-2120.792,-1743.117;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;742;-1988.912,-1132.564;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;762;-3055.032,-1909.051;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;755;-2344.163,-1401.167;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;726;-3028.026,-1731.92;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;738;-497.3196,-1475.938;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;733;-1707.965,-1325.204;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;769;-2326.757,-1448.501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;683;-3067.526,-1789.89;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;673;-4561.625,-1406.865;Inherit;True;Property;_SpecularMapASmoothness;Specular Map (A Smoothness);35;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;761;-2571.969,-1967.378;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;694;-3811.85,-781.6198;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;732;-1997.249,-1238.277;Inherit;False;Constant;_Min;Min;3;0;Create;True;0;0;0;False;0;False;0.2;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;691;-2545.776,-769.8881;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;772;-3810.486,-952.5624;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;704;-1757.12,-1721.696;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;664;-955.1271,-1758.322;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;736;4.932009,-1755.938;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;658;-138.5824,-1793.213;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;743;-1665.929,-1226.071;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;763;-2437.413,-1951.592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;721;-1451.771,-1717.194;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;765;-1289.005,-1055.711;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;678;-3268.137,-776.1447;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;768;-2758.263,-594.1177;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;773;-3580.635,-945.7577;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;713;-3163.7,-677.6688;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;10;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;644;-2863.801,-1831.996;Inherit;False;return normalize((0.3 * unity_SHAr + 0.59 * unity_SHAg + 0.11 * unity_SHAb).rgb)@$$;3;Create;0;SH Light Dir;True;False;0;;False;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;656;-2532.368,-1701.47;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;747;-1030.243,-1270.388;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;722;-1741.349,-1634.394;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;642;-2285.975,-1724.865;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;741;-1824.929,-1225.071;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;767;-2449.736,-1372.988;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;706;-1982.801,-1689.183;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;739;-516.1946,-1245.491;Inherit;False;Constant;_Str;Str;4;0;Create;True;0;0;0;False;0;False;2;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;759;-1319.294,-1468.334;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;660;-2548.551,-1833.316;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;790;3429.918,-396.2139;Inherit;False;Property;_DebugChannels;Debug Channels;0;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;6;FullColor;Diffuse;Specular;AO;Reflections;Albedo;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;727;-1865.845,-1317.816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;770;-2749.633,-559.5974;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;754;-1315.513,-1447.733;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;737;-1037.379,-1457.307;Inherit;False;Property;_HighlightColor;Highlight Color;37;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;716;-351.4136,-1343.737;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;674;-4186.107,-1394.395;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;672;-3594.095,-567.7107;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;638;-3453.247,-1855.842;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;697;-2930.149,-778.2698;Inherit;False;return UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, roughness ).rgb@;3;Create;2;True;reflectDir;FLOAT3;0,0,0;In;;Inherit;False;True;roughness;FLOAT;0;In;;Inherit;False;Reflection;True;False;0;;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;728;-1449.186,-1303.807;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.4;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;876;4257.504,-450.8632;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;663;-1176.739,-1735.382;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;725;-2161.581,-1331.315;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;693;-3532.973,-770.97;Inherit;False;Object;Tangent;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;24;4470.534,-536.1807;Float;False;True;-1;2;ASEMaterialInspector;100;1;Pixel Theory/Object (Metallic);0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;False;1;False;-1;255;False;-1;255;False;-1;6;False;-1;2;False;-1;3;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;False;0.5;False;-1;0.5;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;900;0;902;0
WireConnection;906;0;900;0
WireConnection;906;1;904;0
WireConnection;899;1;902;3
WireConnection;899;2;904;0
WireConnection;901;0;906;0
WireConnection;901;2;899;0
WireConnection;903;0;905;0
WireConnection;903;1;901;0
WireConnection;908;9;889;0
WireConnection;908;15;903;0
WireConnection;888;0;687;0
WireConnection;888;1;908;0
WireConnection;775;0;888;0
WireConnection;910;0;903;0
WireConnection;911;198;775;0
WireConnection;911;56;910;0
WireConnection;885;1;911;197
WireConnection;875;0;885;0
WireConnection;764;0;763;0
WireConnection;764;1;642;0
WireConnection;742;0;740;0
WireConnection;762;0;638;0
WireConnection;755;0;691;0
WireConnection;726;0;638;0
WireConnection;738;1;737;0
WireConnection;738;2;765;0
WireConnection;733;0;727;0
WireConnection;769;0;770;0
WireConnection;683;0;638;0
WireConnection;761;0;762;0
WireConnection;761;1;644;0
WireConnection;691;0;697;0
WireConnection;704;0;706;0
WireConnection;664;1;663;0
WireConnection;664;2;759;0
WireConnection;664;3;754;0
WireConnection;736;0;658;0
WireConnection;658;1;664;0
WireConnection;658;2;716;0
WireConnection;743;0;741;0
WireConnection;763;0;761;0
WireConnection;721;0;704;0
WireConnection;721;1;722;0
WireConnection;765;0;740;0
WireConnection;678;0;773;0
WireConnection;678;1;693;0
WireConnection;768;0;672;0
WireConnection;773;0;772;0
WireConnection;713;0;672;0
WireConnection;747;0;728;0
WireConnection;722;0;767;0
WireConnection;642;0;660;0
WireConnection;642;1;656;0
WireConnection;741;0;732;0
WireConnection;741;1;742;0
WireConnection;767;0;768;0
WireConnection;706;0;764;0
WireConnection;759;0;769;0
WireConnection;660;0;644;0
WireConnection;660;1;683;0
WireConnection;727;0;725;0
WireConnection;770;0;672;0
WireConnection;754;0;755;0
WireConnection;716;0;738;0
WireConnection;716;1;747;0
WireConnection;716;2;739;0
WireConnection;674;0;673;0
WireConnection;697;0;678;0
WireConnection;697;1;713;0
WireConnection;728;0;733;0
WireConnection;728;1;743;0
WireConnection;876;0;875;0
WireConnection;663;0;721;0
WireConnection;725;0;656;0
WireConnection;725;1;726;0
WireConnection;693;0;694;0
WireConnection;24;0;876;0
ASEEND*/
//CHKSM=9C634A0170C344203C893AF848033F9C402B62AA