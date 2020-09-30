using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyBrightnessSaturationContrast : MyPostEffectBase
{
    public Shader briSatConShader;
    private Material briSatConMaterial;
    public Material material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }
    [Range(0f, 3f)]
    public float brightness = 1f;
    [Range(0f, 3f)]
    public float saturation = 1f;
    [Range(0f, 3f)]
    public float contrast = 1f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material)
        {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Debug.LogError("no post-processing material");
            Graphics.Blit(src, dest);
        }
    }
}
