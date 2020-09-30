using UnityEngine;
using System.Collections;

public class Translating : MonoBehaviour
{

    public float speed = 10.0f;
    public Vector3 startPoint = Vector3.zero;
    public Vector3 endPoint = Vector3.zero;
    public Vector3 lookAt = Vector3.zero;
    public bool pingpong = true;

    private Vector3 curEndPoint = Vector3.zero;

    // Use this for initialization
    void Start()
    {
        transform.position = startPoint;
        curEndPoint = endPoint;
    }

    // Update is called once per frame
    void Update()
    {
        transform.RotateAround(lookAt, Vector3.up, 300 * Time.deltaTime);
        transform.LookAt(lookAt);
    }
}
