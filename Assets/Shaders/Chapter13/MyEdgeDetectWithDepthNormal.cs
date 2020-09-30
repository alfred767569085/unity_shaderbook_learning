using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyEdgeDetectWithDepthNormal : MyPostEffectBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMat = null;
    public Material material
    {
        get => edgeDetectMat = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMat);
    }

    private Camera p_camera = null;
    public Camera camera
    {
        get => p_camera ? p_camera : p_camera = GetComponent<Camera>();
    }

    [Range(0f, 1f)]
    public float edgeOnly = 0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    public float sampleDistance = 1f;
    public float sensitivityDepth = 1f;
    public float sensitivityNormal = 1;

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material)
        {
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetVector("_Sensitivity", new Vector4(sensitivityDepth, sensitivityNormal, 0f, 0f));

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Debug.LogError("no post processing material");
            Graphics.Blit(src, dest);
        }
    }
}
