using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyCameraSettings : MyPostEffectBase
{
    public Shader depthNormalShader;
    private Material depthNormalMat;
    public Material material
    {
        get
        {
            depthNormalMat = CheckShaderAndCreateMaterial(depthNormalShader, depthNormalMat);
            return depthNormalMat;
        }
    }
    private Camera p_camera;
    public Camera camera
    {
        get
        {
            return p_camera ? p_camera : p_camera = GetComponent<Camera>();
        }
    }
    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
        camera.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material)
        {
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Debug.LogWarning("no post processing material");
            Graphics.Blit(src, dest);
        }
    }
}
