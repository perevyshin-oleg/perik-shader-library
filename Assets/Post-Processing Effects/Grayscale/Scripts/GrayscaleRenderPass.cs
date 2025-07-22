using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace PostProcessingEffects.Grayscale
{
    public class GrayscaleRenderPass : ScriptableRenderPass
    {
        private Material _material;
        private GrayscaleSettings _settings;
        private RenderTargetIdentifier _source;
        private RenderTargetIdentifier _mainTex;
        private string _profilerTag;
        
        public void Setup(ScriptableRenderer renderer, string profilerTag)
        {
            _profilerTag = profilerTag;
            VolumeStack stack = VolumeManager.instance.stack;
            _settings = stack.GetComponent<GrayscaleSettings>();
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

            if (_settings != null && _settings.IsActive())
            {
                renderer.EnqueuePass(this);
                _material = new Material(Shader.Find("PerikShaders/ImageEffects/Grayscale"));
            }
        }

        //Use to set up any temporary textures that will be used for effect.
        //Later in the Execute method, we must read this texture and write back it. 
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            if (_settings == null) return;
            
            int id = Shader.PropertyToID("_MainTex");
            _mainTex = new RenderTargetIdentifier(id);
            cmd.GetTemporaryRT(id, cameraTextureDescriptor);
            
            base.Configure(cmd, cameraTextureDescriptor);
        }

        //Runs the effect. Inside we create a CommandBuffer, which is an object that holds a list
        //of rendering commands and attach commands to Blit (copy buffer) the source and mainTex textures.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (!_settings.IsActive()) return;
            
            //Create command buffer with profilerTag to evaluate performance in profiler
            CommandBuffer cmd = CommandBufferPool.Get(_profilerTag);
            
            //Blit (copy frag data from shader to other shader)
            cmd.Blit(_source, _mainTex);
            
            //Set up any material properties.
            _material.SetFloat("_Strength", _settings.strength.value);
            
            //all-important Blit in which we apply the material to mainTex and assign the result back
            //to the source texture
            cmd.Blit(_mainTex, _source, _material);
            
            //Execute the command buffer and clean up resources.
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }
        
        //Runs at the end of each frame to clean up any temporary
        //data that was created back in Configure
        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(Shader.PropertyToID("_MainTex"));
        }
    }
}