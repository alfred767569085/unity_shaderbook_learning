using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyBloom : MyPostEffectBase
{
    public Shader bloomShader;
    private Material bloomMat = null;
    public Material material
    {
        get
        {
            bloomMat = CheckShaderAndCreateMaterial(bloomShader, bloomMat);
            return bloomMat;
        }
    }

    [Range(0, 4)]
    public int iterations = 3;
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    [Range(1, 8)]
    public int downSample = 2;
    [Range(0f, 4f)]
    public float luminanceThreshold = 0.6f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material)
        {
            int rtW = src.width / downSample,
                rtH = src.height / downSample;
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);

            Graphics.Blit(src, buffer0, material, 0);

            for (int i = 0; i < iterations; ++i)
            {
                material.SetFloat("_BlurSize", 1f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            material.SetTexture("_Bloom", buffer0);
            Graphics.Blit(src, dest, material, 3);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Debug.LogError("no post-processing material");
            Graphics.Blit(src, dest);
        }
    }
}
