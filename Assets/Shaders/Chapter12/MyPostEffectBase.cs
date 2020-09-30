using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class MyPostEffectBase : MonoBehaviour
{
    private void Start()
    {
        CheckResources();
    }

    protected void CheckResources()
    {
        if (!CheckSupport())
            NotSupported();
    }

    protected bool CheckSupport()
    {
        return true;
    }

    protected void NotSupported()
    {
        enabled = false;
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null || !shader.isSupported)
            return null;
        if (material && material.shader == shader)
            return material;

        material = new Material(shader);
        material.hideFlags = HideFlags.DontSave;
        return material;
    }
}
