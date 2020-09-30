using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyScrollingPlayerMove : MonoBehaviour
{
    Material material = null;
    float distanceX = 0f;
    float distance2X = 0f;
    // Start is called before the first frame update
    void Start()
    {
        distanceX = distance2X = 0f;
        if (material == null)
        {
            Renderer renderer = GetComponent<Renderer>();
            if (renderer != null)
                material = renderer.sharedMaterial;
            else
                Debug.LogWarning("no renderer found.");
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (material != null)
        {
            distanceX += Input.GetAxis("Horizontal") * Time.deltaTime * 0.5f;
            distance2X += Input.GetAxis("Horizontal") * Time.deltaTime;
            material.SetFloat("_ShiftX", distanceX);
            material.SetFloat("_Shift2X", distance2X);
        }
    }
}
