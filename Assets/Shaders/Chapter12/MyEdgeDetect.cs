using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyEdgeDetect : MyPostEffectBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMat = null;
    public Material material
    {
        get
        {
            edgeDetectMat = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMat);
            return edgeDetectMat;
        }
    }

    [Range(0f, 1f)]
    public float edgeOnly = 0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material)
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Debug.LogError("no post-processing material");
            Graphics.Blit(src, dest);
        }
    }
}
