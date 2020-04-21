using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{
    [SerializeField] Transform toLookAt;
    // Start is called before the first frame update
    void Start()
    {
        LookAt();
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 direction = Vector3.zero;
        if (Input.GetKey(KeyCode.D))
            direction += Vector3.right;
        if (Input.GetKey(KeyCode.A))
            direction += Vector3.left;
        if (Input.GetKey(KeyCode.S))
            direction += Vector3.down;
        if (Input.GetKey(KeyCode.W))
            direction += Vector3.up;
        transform.Translate(direction * Time.deltaTime);
        LookAt();
    }

    void LookAt()
    {
        transform.rotation = Quaternion.LookRotation(toLookAt.position - transform.position);
    }
}