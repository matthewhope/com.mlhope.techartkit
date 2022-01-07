// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pixel Theory/Metaball"
{
	Properties
	{
		_MatcapTexture("Matcap Texture", 2D) = "white" {}
		_FresnelStart("Fresnel Start", Range( 0 , 1)) = 0
		_Highlight("Highlight", Range( 0 , 1)) = 0
		_FresnelStrength("Fresnel Strength", Range( 0 , 1)) = 0
		_HighlightColor("Highlight Color", Color) = (0,0,0,0)
		_FresnelEnd("Fresnel End", Range( 0 , 1)) = 1
		_Saturation("Saturation", Range( 0 , 1)) = 1

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
			#define ASE_NEEDS_FRAG_COLOR


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MatcapTexture;
			uniform float _Saturation;
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
				o.ase_texcoord1.xyz = ase_worldNormal;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult4_g240 = dot( ase_worldViewDir , ase_worldNormal );
				float lerpResult5_g240 = lerp( 0.0 , saturate( (0.0 + (( 1.0 - dotResult4_g240 ) - _FresnelStart) * (1.0 - 0.0) / (_FresnelEnd - _FresnelStart)) ) , _FresnelStrength);
				float vertexToFrag21_g240 = lerpResult5_g240;
				o.ase_texcoord1.w = vertexToFrag21_g240;
				
				o.ase_color = v.color;
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
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float4 temp_output_46_0 = ( tex2D( _MatcapTexture, ( 0.5 + ( 0.5 * (mul( UNITY_MATRIX_V, float4( ase_worldNormal , 0.0 ) ).xyz).xy ) ) ) * i.ase_color );
				float luminance29 = Luminance(temp_output_46_0.rgb);
				float4 temp_cast_3 = (luminance29).xxxx;
				float4 lerpResult30 = lerp( temp_cast_3 , temp_output_46_0 , (0.0 + (_Saturation - 0.0) * (2.0 - 0.0) / (1.0 - 0.0)));
				float3 temp_output_1_0_g240 = saturate( lerpResult30 ).rgb;
				float vertexToFrag21_g240 = i.ase_texcoord1.w;
				float4 lerpResult9_g240 = lerp( float4( ( temp_output_1_0_g240 + saturate( ( temp_output_1_0_g240 * vertexToFrag21_g240 ) ) ) , 0.0 ) , _HighlightColor , ( vertexToFrag21_g240 * _Highlight ));
				
				
				finalColor = lerpResult9_g240;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18933
0;851.2;3072;542.2;2171.688;283.3278;1.453566;True;False
Node;AmplifyShaderEditor.FunctionNode;45;-534.9571,-112.9198;Inherit;False;MatcapTexture;0;;1;769392ba5f29801468dcb1809168b96b;0;0;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;15;-334.3491,34.46352;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-112.3838,210.655;Inherit;False;Property;_Saturation;Saturation;23;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-66.92482,-108.9;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;31;228.0899,205.6066;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LuminanceNode;29;180.9682,-74.49884;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;47;114.7599,58.24935;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;30;502.0009,10.93951;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;23;1102.066,8.776773;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;44;1320.822,62.34438;Inherit;False;FresnelHighlighter;2;;240;c50e3af94f70afc4783b159d4f2fcc5d;0;1;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;38;756.5485,255.9143;Inherit;False;BakedGI;8;;232;627e98e461f22b541b8c98e012256e4d;0;2;198;FLOAT3;0,0,0;False;56;FLOAT3;0,0,0;False;6;FLOAT4;197;FLOAT4;0;COLOR;28;FLOAT3;141;FLOAT3;223;FLOAT4;135
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1661.701,3.736507;Float;False;True;-1;2;ASEMaterialInspector;100;1;Pixel Theory/Metaball;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;46;0;45;0
WireConnection;46;1;15;0
WireConnection;31;0;21;0
WireConnection;29;0;46;0
WireConnection;47;0;46;0
WireConnection;30;0;29;0
WireConnection;30;1;47;0
WireConnection;30;2;31;0
WireConnection;23;0;30;0
WireConnection;44;1;23;0
WireConnection;38;198;30;0
WireConnection;0;0;44;0
ASEEND*/
//CHKSM=96F0B2E8F8BEAF45AC8564E3D6CA486530DB86A5