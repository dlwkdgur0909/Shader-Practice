Shader "ShaderPractice/Default"
{
    //�ν���Ʈâ�� �� �� �ְ� �ϴ� ��
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
            //urp�� �ƴ� ������Ʈ���� shader�� ������� ��
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
            cull back //�޸��� �����Ѵ�
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

            //���ؽ� ���̴� ����ü
            struct appdata
            {
                //�� �����̽��� ��ġ
                float4 vertex : POSITION;
                //������ ���� �� uv��ǥ�� ������
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //�ȼ� ���̴� ����ü
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
                //URP ����

                //�� �����̽����� �ѹ��� �����ϴ� ��
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
                //step�� ���̴��� �Լ��̴�. step(x,y) / if(x < y) �̸� 1�� ��ȯ
                //NdotL = step(NdotL, _Threshould);

                //�Ҽ����� ������ ceil�Լ� 
                //0, 1, 2, 3�� ���� ���� / 3�� �ؼ� 0.33, 0.66, 0.99
                NdotL = ceil(NdotL * 3) / 3;
                col.rgb = lerp(col.rgb, _ShadowColor, 1-NdotL);

                return half4(col.rgb, 1);
            }
            
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            cull front //�ո��� �����Ѵ�
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

            //���ؽ� ���̴� ����ü
            struct appdata
            {
                //�� �����̽��� ��ġ
                float4 vertex : POSITION;
                //������ ���� �� uv��ǥ�� ������
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //�ȼ� ���̴� ����ü
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
                //URP ����

                //�� �����̽����� �ѹ��� �����ϴ� ��
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
