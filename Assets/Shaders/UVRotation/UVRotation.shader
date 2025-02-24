Shader "Unlit/UVRotation"
{
    Properties
    {
        _BaseColor ("BaseColor", Color) = (1,1,1,1)
        _RotationAngle ("Rotation Amount", Float) = 0
        _MainTex ("Base Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

           struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _RotationAngle; // Угол вращения в градусах

            // Функция для вращения UV-координат
            float2 RotateUV(float2 uv, float angle)
            {
                float radians = angle * (3.14159265359 / 180.0); // Преобразуем градусы в радианы
                float sinAngle = sin(radians);
                float cosAngle = cos(radians);

                // Центрируем UV-координаты вокруг (0.5, 0.5)
                uv -= 0.5;

                // Применяем матрицу вращения
                float2 rotatedUV;
                rotatedUV.x = uv.x * cosAngle - uv.y * sinAngle;
                rotatedUV.y = uv.x * sinAngle + uv.y * cosAngle;

                // Возвращаем UV-координаты в исходный диапазон
                rotatedUV += 0.5;

                return rotatedUV;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); // Применяем стандартные tiling и offset
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Вращаем UV-координаты
                float2 rotatedUV = RotateUV(i.uv, _RotationAngle);

                // Выборка текстуры с вращенными UV-координатами
                float4 color = tex2D(_MainTex, rotatedUV);
                return color;
            }
            
            ENDHLSL
        }
    }
}
