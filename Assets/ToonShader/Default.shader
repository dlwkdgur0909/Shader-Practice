Shader "ShaderPractice/Default"
{
    //인스펙트창에 뜰 수 있게 하는 곳
    Properties 
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _Threshould("Threshould" , float) = 0
        _ShadowColor("ShadowColor", Color) = (1,1,1,1)
        _OutlineWidth("OutlineWidth", float ) = 0
    }


    SubShader
    {
        Tags 
        { 
            //urp가 아닌 프로젝트에서 shader을 쓰고싶을 때
            "RenderPipeline" = "UniversalPipeline" 
            "UniversalMaterialType" = "Lit"
            "RenderType"="Opaque" 
            "Queue" = "Geometry+0"
        }

        Pass
        {
            Name "ToonRendering"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            cull back //뒷면을 제거한다
            HLSLPROGRAM

            //Receive Shadow
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

            CBUFFER_START(UnityPerMaterial)
            
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            half4 _BaseMap_ST;
            float _Threshould;
            float4 _ShadowColor;
            float _OutlineWidth;
            
            CBUFFER_END

            //버텍스 셰이더 구조체
            struct appdata
            {
                //모델 스페이스의 위치
                float4 vertex : POSITION;
                //랩핑을 했을 때 uv좌표를 가져옴
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //픽셀 셰이더 구조체
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                //URP 문법

                //모델 스페이스에서 한번에 투영하는 것
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normal = TransformObjectToWorldNormal(v.normal);

                return o;
            }
            
            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                Light mainLight = GetMainLight(float4(0,0,0,0));
                
                float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);

                float NdotL = dot(mainLight.direction, i.normal);
                //step은 셰이더쪽 함수이다. step(x,y) / if(x < y) 이면 1을 반환
                //NdotL = step(NdotL, _Threshould);

                //소수점을 버리는 ceil함수 
                //0, 1, 2, 3을 만든 다음 / 3을 해서 0.33, 0.66, 0.99
                NdotL = ceil(NdotL * 3) / 3;
                col.rgb = lerp(col.rgb, _ShadowColor, 1-NdotL);

                return half4(col.rgb, 1);
            }
            
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            cull front //앞면을 제거한다
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

            CBUFFER_START(UnityPerMaterial)
            
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            half4 _BaseMap_ST;
            float _Threshould;
            float4 _ShadowColor;
            float _OutlineWidth;
            
            CBUFFER_END

            //버텍스 셰이더 구조체
            struct appdata
            {
                //모델 스페이스의 위치
                float4 vertex : POSITION;
                //랩핑을 했을 때 uv좌표를 가져옴
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //픽셀 셰이더 구조체
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                //URP 문법

                //모델 스페이스에서 한번에 투영하는 것
                o.vertex = TransformObjectToHClip(v.vertex.xyz + v.normal * _OutlineWidth);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normal = TransformObjectToWorldNormal(v.normal);

                return o;
            }
            
            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                Light mainLight = GetMainLight(float4(0,0,0,0));
                
                float4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);

                return half4(0,1,0, 1);
            }
            
            ENDHLSL
        }

    }
}
