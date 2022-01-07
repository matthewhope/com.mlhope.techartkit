// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pixel Theory/Environment Caustics"
{
	Properties
	{
		_CausticsTexture("Caustics Texture", 2D) = "black" {}
		_CausticsStrength("Caustics Strength", Range( 0 , 1)) = 0.02
		_CausticsSpeedA("Caustics Speed A", Float) = 1
		_CausticsSpeedB("Caustics Speed B", Float) = 1
		_CausticsTilingB("Caustics Tiling B", Float) = 1
		_MaskRadius("Mask Radius", Float) = 1
		_MaskHardness("Mask Hardness", Float) = 1
		_CausticsTilingA("Caustics Tiling A", Float) = 1
		_Albedo("Albedo", 2D) = "white" {}
		_CausticsColor("Caustics Color", Color) = (0,0,0,0)
		_BaseColor("Base Color", Color) = (1,1,1,1)
		_EffectColor("Effect Color", Color) = (0,0,0,1)
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
			#define ASE_NEEDS_FRAG_WORLD_POSITION


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

			uniform float4 _BaseColor;
			uniform sampler2D _Albedo;
			uniform float4 _Albedo_ST;
			uniform sampler2D _CausticsTexture;
			uniform float _CausticsTilingA;
			uniform float _CausticsSpeedA;
			uniform float _CausticsTilingB;
			uniform float _CausticsSpeedB;
			uniform float4 _CausticsColor;
			uniform float _CausticsStrength;
			uniform float3 _MaskCenter;
			uniform float _MaskRadius;
			uniform float _MaskHardness;
			uniform float4 _EffectColor;
			inline float4 TriplanarSampling1( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			inline float4 TriplanarSampling9( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
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
				float2 temp_cast_1 = (_CausticsTilingA).xx;
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float mulTime26 = _Time.y * _CausticsSpeedA;
				float4 triplanar1 = TriplanarSampling1( _CausticsTexture, ( mulTime26 + WorldPosition ), ase_worldNormal, 1.0, temp_cast_1, 1.0, 0 );
				float2 temp_cast_2 = (_CausticsTilingB).xx;
				float mulTime28 = _Time.y * _CausticsSpeedB;
				float4 triplanar9 = TriplanarSampling9( _CausticsTexture, ( WorldPosition + mulTime28 ), ase_worldNormal, 1.0, temp_cast_2, 1.0, 0 );
				float3 temp_output_5_0_g1 = ( ( WorldPosition - _MaskCenter ) / _MaskRadius );
				float dotResult8_g1 = dot( temp_output_5_0_g1 , temp_output_5_0_g1 );
				float temp_output_53_0 = saturate( ( 1.0 - pow( saturate( dotResult8_g1 ) , _MaskHardness ) ) );
				float4 lerpResult70 = lerp( ( _BaseColor * tex2D( _Albedo, uv_Albedo ) ) , ( min( triplanar1 , triplanar9 ) * _CausticsColor * _CausticsStrength * temp_output_53_0 * _EffectColor ) , temp_output_53_0);
				
				
				finalColor = lerpResult70;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18933
0;1005.6;2794;634;5737.272;919.9971;3.812333;True;False
Node;AmplifyShaderEditor.RangedFloatNode;27;-2253.837,-295.3683;Inherit;False;Property;_CausticsSpeedA;Caustics Speed A;3;0;Create;True;0;0;0;False;0;False;1;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2249.54,236.6151;Inherit;False;Property;_CausticsSpeedB;Caustics Speed B;4;0;Create;True;0;0;0;False;0;False;1;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;28;-1957.422,229.1595;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;22;-2020.095,-109.3164;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;26;-1953.826,-284.7818;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1908.983,-520.9034;Inherit;True;Property;_CausticsTexture;Caustics Texture;0;0;Create;True;0;0;0;False;0;False;None;None;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;50;-1883.179,836.3885;Inherit;False;Property;_MaskRadius;Mask Radius;6;0;Create;True;0;0;0;False;0;False;1;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;49;-1929.582,618.2951;Inherit;False;Global;_MaskCenter;_MaskCenter;12;0;Create;True;0;0;0;False;0;False;0,0,0;0,15,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;51;-1894.007,941.5682;Inherit;False;Property;_MaskHardness;Mask Hardness;7;0;Create;True;0;0;0;False;0;False;1;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;16;-1248.63,-179.9703;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1635.312,-138.1718;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;15;-1251.23,-169.5703;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1401.812,304.5737;Inherit;False;Property;_CausticsTilingB;Caustics Tiling B;5;0;Create;True;0;0;0;False;0;False;1;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-1579.065,42.03374;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-1384.44,-39.97272;Inherit;False;Property;_CausticsTilingA;Caustics Tiling A;8;0;Create;True;0;0;0;False;0;False;1;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;48;-1458.91,837.3328;Inherit;False;SphereMask;-1;;1;988803ee12caf5f4690caee3c8c4a5bb;0;3;15;FLOAT3;0,0,0;False;14;FLOAT;0;False;12;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;52;-1098.971,862.6834;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;9;-975.5569,89.07629;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;5;None;Bot Texture 1;_BotTexture1;white;7;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;1;-975.6433,-123.0432;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;1;None;Bot Texture 0;_BotTexture0;white;3;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;33;-542.2049,533.822;Inherit;False;Property;_BaseColor;Base Color;11;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-555.1397,726.1326;Inherit;True;Property;_Albedo;Albedo;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;30;-534.6713,32.09427;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-973.6904,514.9029;Inherit;False;Property;_CausticsStrength;Caustics Strength;2;0;Create;True;0;0;0;False;0;False;0.02;0.02;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;53;-900.9852,845.6691;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;24;-821.3937,304.4754;Inherit;False;Property;_CausticsColor;Caustics Color;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;58;-541.5826,291.2415;Inherit;False;Property;_EffectColor;Effect Color;12;0;Create;True;0;0;0;False;0;False;0,0,0,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-354.4015,44.84983;Inherit;False;5;5;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;72;-27.04855,964.8968;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-111.5964,429.1579;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;12;-2680.265,-50.76626;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;44;-502.1958,-65.72768;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-3130.19,401.0028;Inherit;False;Property;_RGBSplit;RGB Split;1;0;Create;True;0;0;0;False;0;False;0.02;0.02;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-2652.024,500.2474;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1,-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-2827.356,397.5811;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformPositionNode;57;-1620.004,618.2231;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-2650.024,371.2474;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;70;69.05194,37.93251;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;419.9649,-4.564837;Float;False;True;-1;2;ASEMaterialInspector;100;1;Pixel Theory/Environment Caustics;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;28;0;31;0
WireConnection;26;0;27;0
WireConnection;16;0;2;0
WireConnection;45;0;26;0
WireConnection;45;1;22;0
WireConnection;15;0;2;0
WireConnection;13;0;22;0
WireConnection;13;1;28;0
WireConnection;48;15;49;0
WireConnection;48;14;50;0
WireConnection;48;12;51;0
WireConnection;52;0;48;0
WireConnection;9;0;15;0
WireConnection;9;9;13;0
WireConnection;9;3;46;0
WireConnection;1;0;16;0
WireConnection;1;9;45;0
WireConnection;1;3;47;0
WireConnection;30;0;1;0
WireConnection;30;1;9;0
WireConnection;53;0;52;0
WireConnection;23;0;30;0
WireConnection;23;1;24;0
WireConnection;23;2;25;0
WireConnection;23;3;53;0
WireConnection;23;4;58;0
WireConnection;72;0;53;0
WireConnection;32;0;33;0
WireConnection;32;1;7;0
WireConnection;44;0;1;0
WireConnection;44;1;9;0
WireConnection;6;0;4;0
WireConnection;4;0;3;0
WireConnection;4;1;3;0
WireConnection;5;0;4;0
WireConnection;70;0;32;0
WireConnection;70;1;23;0
WireConnection;70;2;72;0
WireConnection;0;0;70;0
ASEEND*/
//CHKSM=54249E0BAC5FCC3F082AE3A0B236C93BDD7A3829