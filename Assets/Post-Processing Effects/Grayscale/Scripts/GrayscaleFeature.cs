using UnityEngine.Rendering.Universal;

namespace PostProcessingEffects.Grayscale
{
    public class GrayscaleFeature : ScriptableRendererFeature
    {
        GrayscaleRenderPass _renderPass;
        
        public override void Create()
        {
            name = "Grayscale";
            _renderPass = new GrayscaleRenderPass();
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            _renderPass.Setup(renderer, "Grayscale Post Process");
        }
    }
}