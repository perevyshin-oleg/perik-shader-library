Shader "Unlit/UVRotation"
{
   Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {} // Основная текстура
        _Tiling ("Tiling", Float) = 1.0 // Масштаб текстуры
        _BlendSharpness ("Blend Sharpness", Float) = 1.0 // Резкость смешивания
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 worldPos : TEXCOORD0;
            };

            struct v2f
            {
                float3 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Tiling;
            float _BlendSharpness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.worldPos = TransformObjectToWorld(v.vertex); // Мировые координаты вершины
                o.normal = TransformObjectToWorldNormal(v.normal); // Мировые нормали
                return o;
            }

            // Функция для трипланарного наложения текстуры
            float4 TriplanarSample(float3 worldPos, float3 normal, float tiling, float blendSharpness)
            {
                // Вычисляем UV-координаты для каждой оси
                float2 uvX = worldPos.zy * tiling; // Проекция по оси X
                float2 uvY = worldPos.xz * tiling; // Проекция по оси Y
                float2 uvZ = worldPos.xy * tiling; // Проекция по оси Z

                // Выборка текстуры для каждой оси
                float4 texX = tex2D(_MainTex, uvX);
                float4 texY = tex2D(_MainTex, uvY);
                float4 texZ = tex2D(_MainTex, uvZ);

                // Веса для смешивания на основе нормалей
                float3 weights = pow(abs(normal), blendSharpness);
                weights = weights / (weights.x + weights.y + weights.z); // Нормализация весов

                // Смешивание текстур по весам
                float4 finalColor = texX * weights.x + texY * weights.y + texZ * weights.z;
                return finalColor;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Трипланарное наложение текстуры
                float4 color = TriplanarSample(i.worldPos, normalize(i.normal), _Tiling, _BlendSharpness);
                return color;
            }
            ENDHLSL
        }
    }
}
