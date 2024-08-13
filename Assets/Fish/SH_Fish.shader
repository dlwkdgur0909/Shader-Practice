Shader "Unlit/SH_Fish"
{
    Properties
    {
       [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
       _WaveMotionMask_Value("WaveMotionMask_Value", float) = 0
       _WaveMotionMask_Blur("WaveMotionMask_Blur", float) = 0

       //WaveMotion
       _MotionAmplitude("MotionAmplitude", float) = 1
       _MotionFrequency("MotionFrequency", float) = 1
       _MotionSpeed("MotionSpeed", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float _WaveMotionMask_Value;
            float _WaveMotionMask_Blur;


            //Motion
            float _MotionAmplitude;
            float _MotionFrequency;
            float _MotionSpeed;

            //1. Mask
            //2. Motion

            v2f vert (appdata v)
            {
                v2f o;


                //mask - done
                float mask = smoothstep(_WaveMotionMask_Value, _WaveMotionMask_Value + _WaveMotionMask_Blur, v.vertex.z);
                //o.color = float4(mask.rrr, 1);

                float waveMotion = sin(v.vertex.z * _MotionFrequency + (_Time.y * _MotionSpeed)) * _MotionAmplitude;
                v.vertex.x += waveMotion * (1 - mask);
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
