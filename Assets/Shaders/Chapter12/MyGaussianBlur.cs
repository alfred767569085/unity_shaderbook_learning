using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyGaussianBlur : MyPostEffectBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMat;
    public Material material
    {
        get
        {
            gaussianBlurMat = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMat);
            return gaussianBlurMat;
        }
    }

    [Range(0, 4)]
    public int iterations = 3;
    [Range(0.2f, 3f)]
    public float blurSpread = 0.6f;
    [Range(1, 8)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material)
        {
            int rtW = src.width / downSample,
                rtH = src.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(src.width, src.height),
                buffer1 = null;
            Graphics.Blit(src, buffer0);
            for (int i = 0; i < iterations; ++i)
            {
                material.SetFloat("_BlurSize", 1f + i * blurSpread);

                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 0);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;

                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Debug.LogError("no post-processing material");
            Graphics.Blit(src, dest);
        }
    }
}
