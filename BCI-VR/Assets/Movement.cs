using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Movement : MonoBehaviour {

    public Transform cameraRigTransform;
    public bool left = false;
    public bool right = false;
    public bool forward = false;
    public float speed = 10f;

    // Use this for initialization
    void Start () {
    }

    // Update is called once per frame
    void Update () {
        if (left)
        {
            RotateLeft();
        } else if (right)
        {
            RotateRight();
        }

        if (forward) Forward();
    }

    public void SetSpeed(float newspeed)
    {
        this.speed = newspeed;
    }

    public void SetDirection(string dir)
    {
        if (dir == "right")
        {
            left = false;
            right = true;
        } else if (dir == "left")
        {
            right = false;
            left = true;
        }
    }

    void RotateLeft()
    {
        transform.Rotate(-Vector3.up * Time.deltaTime * speed);
    }

    void RotateRight()
    {
        transform.Rotate(Vector3.up * Time.deltaTime * speed);
    }

    void Forward()
    {
        transform.position += transform.forward * Time.deltaTime;
    }
}
