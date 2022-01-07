// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pixel Theory/Matcap Object"
{
	Properties
	{
		_DiffuseLevel("Diffuse Level", Range( 0 , 1)) = 1
		_AOInfluence("AO Influence", Range( 0 , 1)) = 0.7167265
		_Roughness("Roughness", Range( 0 , 1)) = 0
		_DiffuseMatcap("Diffuse Matcap", 2D) = "white" {}
		_SpecularMatcap("Specular Matcap", 2D) = "black" {}
		_Albedo("Albedo", 2D) = "white" {}
		_AmbientOcclusion("AmbientOcclusion", 2D) = "white" {}
		_SpecularMapASmoothness("Specular Map (A Smoothness)", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 2.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
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
			uniform sampler2D _DiffuseMatcap;
			uniform float _DiffuseLevel;
			uniform sampler2D _AmbientOcclusion;
			uniform float4 _AmbientOcclusion_ST;
			uniform float _AOInfluence;
			uniform sampler2D _SpecularMatcap;
			uniform float _Roughness;
			uniform sampler2D _SpecularMapASmoothness;
			uniform float4 _SpecularMapASmoothness_ST;

			
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
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float4 appendResult14_g16 = (float4((tex2Dlod( _DiffuseMatcap, float4( ( 0.5 + ( 0.5 * (mul( UNITY_MATRIX_V, float4( ase_worldNormal , 0.0 ) ).xyz).xy ) ), 0, 0.0) )).rgb , 1.0));
				float temp_output_2_0_g17 = _DiffuseLevel;
				float temp_output_3_0_g17 = ( 1.0 - temp_output_2_0_g17 );
				float3 appendResult7_g17 = (float3(temp_output_3_0_g17 , temp_output_3_0_g17 , temp_output_3_0_g17));
				float2 uv_AmbientOcclusion = i.ase_texcoord1.xy * _AmbientOcclusion_ST.xy + _AmbientOcclusion_ST.zw;
				float temp_output_2_0_g18 = _AOInfluence;
				float temp_output_3_0_g18 = ( 1.0 - temp_output_2_0_g18 );
				float3 appendResult7_g18 = (float3(temp_output_3_0_g18 , temp_output_3_0_g18 , temp_output_3_0_g18));
				float4 temp_output_6_0 = ( tex2D( _Albedo, uv_Albedo ) * float4( ( ( appendResult14_g16.xyz * temp_output_2_0_g17 ) + appendResult7_g17 ) , 0.0 ) * float4( ( ( tex2D( _AmbientOcclusion, uv_AmbientOcclusion ).rgb * temp_output_2_0_g18 ) + appendResult7_g18 ) , 0.0 ) );
				float lerpResult54 = lerp( 8.0 , 0.0 , _Roughness);
				float4 appendResult14_g19 = (float4((tex2Dlod( _SpecularMatcap, float4( ( 0.5 + ( 0.5 * (mul( UNITY_MATRIX_V, float4( ase_worldNormal , 0.0 ) ).xyz).xy ) ), 0, ( 1.0 - lerpResult54 )) )).rgb , 1.0));
				float2 uv_SpecularMapASmoothness = i.ase_texcoord1.xy * _SpecularMapASmoothness_ST.xy + _SpecularMapASmoothness_ST.zw;
				float4 appendResult42 = (float4((( temp_output_6_0 + ( temp_output_6_0 * ( appendResult14_g19 * ( _Roughness * tex2D( _SpecularMapASmoothness, uv_SpecularMapASmoothness ).r ) ) ) )).rgb , 1.0));
				
				
				finalColor = appendResult42;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18933
604;617;1487;901;2333.378;-110.8762;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;9;-1917.755,503.2058;Inherit;False;Property;_Roughness;Roughness;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;54;-1545.779,450.1618;Inherit;False;3;0;FLOAT;8;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;51;-1407.416,575.1368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;52;-1346.779,483.1618;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-1161.13,-529.8348;Inherit;True;Property;_DiffuseMatcap;Diffuse Matcap;6;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;18;-1611.393,634.4809;Inherit;True;Property;_SpecularMapASmoothness;Specular Map (A Smoothness);10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-821.0773,-41.94336;Inherit;False;Property;_DiffuseLevel;Diffuse Level;2;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-1051.647,46.37301;Inherit;True;Property;_AmbientOcclusion;AmbientOcclusion;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;45;-739.6436,195.6765;Inherit;False;Property;_AOInfluence;AO Influence;3;0;Create;True;0;0;0;False;0;False;0.7167265;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;-1058.683,297.9311;Inherit;True;Property;_SpecularMatcap;Specular Matcap;7;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WireNode;50;-951.8272,518.6924;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;48;-497.5806,-528.8636;Inherit;False;MatcapTexture;0;;16;769392ba5f29801468dcb1809168b96b;0;2;9;SAMPLER2D;;False;10;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1153.431,645.1972;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;49;-736.8158,335.3065;Inherit;False;MatcapTexture;0;;19;769392ba5f29801468dcb1809168b96b;0;2;9;SAMPLER2D;;False;10;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;20;-773.1781,679.8998;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;7;-454.3955,-220.2929;Inherit;False;Lerp White To;-1;;17;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0.33;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;44;-475.8095,53.61209;Inherit;False;Lerp White To;-1;;18;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0.33;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;5;-857.7811,-318.0073;Inherit;True;Property;_Albedo;Albedo;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-196.9343,-263.3188;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-363.3015,320.6991;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-40.11779,-169.9489;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;112.4047,-253.853;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;41;291.5224,-251.569;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;535.0158,-251.2298;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-918.3445,581.3017;Inherit;False;Property;_Specular;Specular;5;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;47;151.399,-532.2059;Inherit;False;unity_AmbientGround;0;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;43;1941.366,-287.5124;Inherit;False;FLOAT;1;0;FLOAT;0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;731.512,-343.2148;Float;False;True;-1;2;ASEMaterialInspector;100;1;Pixel Theory/Matcap Object;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;54;2;9;0
WireConnection;51;0;9;0
WireConnection;52;0;54;0
WireConnection;50;0;52;0
WireConnection;48;9;4;0
WireConnection;19;0;51;0
WireConnection;19;1;18;1
WireConnection;49;9;10;0
WireConnection;49;10;50;0
WireConnection;20;0;19;0
WireConnection;7;1;48;0
WireConnection;7;2;3;0
WireConnection;44;1;8;0
WireConnection;44;2;45;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;6;2;44;0
WireConnection;15;0;49;0
WireConnection;15;1;20;0
WireConnection;46;0;6;0
WireConnection;46;1;15;0
WireConnection;13;0;6;0
WireConnection;13;1;46;0
WireConnection;41;0;13;0
WireConnection;42;0;41;0
WireConnection;0;0;42;0
ASEEND*/
//CHKSM=12471BB5FC7BE840FEE4E4A15D7851A27486CD13