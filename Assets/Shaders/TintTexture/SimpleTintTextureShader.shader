Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _BaseColor ("BaseColor", Color) = (1,1,1,1)
        _Speed ("Speed", Float) = 1
        _BaseTex ("Base Texture", 2D) = "white" {}
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
                float4 positionOS : Position;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS : SV_Position;
                float2 uv : TEXCOORD0;
            };
            
            float _Speed;
            sampler2D _BaseTex;
            
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor;
            float4 _BaseTex_ST;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o; // Создаем структуру v2f для выходных данных вершинного шейдера
                o.positionCS = TransformObjectToHClip(v.positionOS); // Преобразуем координаты вершины из локального пространства объекта в пространство отсечения (clip space)
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex); // Применяем масштаб и смещение текстуры (тайлинг и offset) к UV-координатам
                return o; // Возвращаем результат для передачи во фрагментный шейдер
            }

            float4 frag (v2f i) : SV_TARGET
            {
                float4 textureSample = tex2D(_BaseTex, i.uv); // Выбираем цвет из текстуры по UV-координатам
                return textureSample * _BaseColor; // Умножаем цвет текстуры на базовый цвет и возвращаем результат
            }
            
            ENDHLSL
        }
    }
}
