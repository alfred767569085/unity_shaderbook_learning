using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MyProceduralTextureGeneration : MonoBehaviour
{
    public Material material = null;

    #region Material Properties
    [SerializeField, SetProperty("textureWidth")]
    private int m_textureWidth = 512;
    public int textureWidth
    {
        get => m_textureWidth;
        set
        {
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get => m_backgroundColor;
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circlrColor")]
    private Color m_circleColor = Color.yellow;
    public Color circleColor
    {
        get => m_circleColor;
        set
        {
            m_circleColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("blurFactor")]
    private float m_blurFactor = 2.0f;
    public float blurFactor
    {
        get => m_blurFactor;
        set
        {
            m_blurFactor = value;
            _UpdateMaterial();
        }
    }
    #endregion

    private Texture2D m_generatedTexture = null;

    private void Start()
    {
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if (renderer == null)
            {
                Debug.LogWarning("Cannot find a renderer.");
                return;
            }
            material = renderer.sharedMaterial;
        }
        _UpdateMaterial();
    }

    private void _UpdateMaterial()
    {
        if (material != null)
        {
            m_generatedTexture = _GenerateProceduralTexture();
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }

    private Texture2D _GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);
        float radius = textureWidth / 5.0f;
        float edgeBlur = 1.0f / blurFactor;

        for (int w = 0; w < textureWidth; ++w)
            for (int h = 0; h < textureWidth; ++h)
            {
                Vector2 circleCenter = new Vector2(textureWidth / 2.0f, textureWidth / 2.0f);
                float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                Color pixel = Color.Lerp(circleColor, backgroundColor, dist * edgeBlur);
                proceduralTexture.SetPixel(w, h, pixel);
            }
        proceduralTexture.Apply();
        return proceduralTexture;
    }

}