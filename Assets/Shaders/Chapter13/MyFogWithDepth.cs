using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyFogWithDepth : MyPostEffectBase
{
    public Shader fogShader;
    private Material fogMat = null;
    public Material material
    {
        get
        {
            fogMat = CheckShaderAndCreateMaterial(fogShader, fogMat);
            return fogMat;
        }
    }

    private Camera p_camera;
    public Camera camera
    {
        get => p_camera ? p_camera : p_camera = GetComponent<Camera>();
    }

    [Range(0f, 3f)]
    public float fogDensity = 1f;
    public Color fogColor = Color.gray;

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = camera.fieldOfView,
                near = camera.nearClipPlane,
                aspect = camera.aspect,
                halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);

            Vector3 toRight = camera.transform.right * halfHeight * aspect,
                toUp = camera.transform.up * halfHeight;

            Vector3 upLeft = camera.transform.forward * near + toUp - toRight,
                upRight = camera.transform.forward * near + toUp + toRight,
                downLeft = camera.transform.forward * near - toUp - toRight,
                downRight = camera.transform.forward * near - toUp + toRight;

            upLeft /= near;
            upRight /= near;
            downLeft /= near;
            downRight /= near;

            frustumCorners.SetRow(0, downLeft);
            frustumCorners.SetRow(1, downRight);
            frustumCorners.SetRow(2, upLeft);
            frustumCorners.SetRow(3, upRight);

            material.SetMatrix("_FrustumCornersRay", frustumCorners);
            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Debug.LogError("no post processing material");
            Graphics.Blit(src, dest);
        }
    }
}
