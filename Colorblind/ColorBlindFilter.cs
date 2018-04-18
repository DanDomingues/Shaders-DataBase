// Created by Alan Zucconi
// www.alanzucconi.com

// Furthered by Danilo Domingues
// dom.dev.contact@gmail.com

using System;
using UnityEngine;
using UnityEngine.UI;

public enum ColorBlindMode
{
    Regular = 0,
    Protanopia = 1,
    Protanomaly = 2,
    Deuteranopia = 3,
    Deuteranomaly = 4,
    Tritanopia = 5,
    Tritanomaly = 6,
    Achromatopsia = 7,
    Achromatomaly = 8,
}

[ExecuteInEditMode]
public class ColorBlindFilter : MonoBehaviour
{
    public ColorBlindMode m_mode = ColorBlindMode.Regular;
    public ColorBlindMode mode
    {
        get { return m_mode; }
        set
        {
            if (value == m_mode) return;

            title.text = value.ToString();
            m_mode = value;
        }
    }

    private ColorBlindMode previousMode = ColorBlindMode.Regular;

    public Text title;

    public bool showDifference = false;

    [SerializeField]
    private Material material;
    public float pointerPosition = 0.0f;
    public bool usingPointer = false;

    private static Color[,] RGB =
    {
        { new Color(1f,0f,0f),             new Color(0f,1f,0f),             new Color(0f,0f,1f) },    // Normal
        { new Color(.56667f, .43333f, 0f), new Color(.55833f, .44167f, 0f), new Color(0f, .24167f, .75833f) },    // Protanopia
        { new Color(.81667f, .18333f, 0f), new Color(.33333f, .66667f, 0f), new Color(0f, .125f, .875f)    }, // Protanomaly
        { new Color(.625f, .375f, 0f),     new Color(.70f, .30f, 0f),       new Color(0f, .30f, .70f)    },   // Deuteranopia
        { new Color(.80f, .20f, 0f),       new Color(.25833f, .74167f, 0),  new Color(0f, .14167f, .85833f)    },    // Deuteranomaly
        { new Color(.95f, .05f, 0),        new Color(0f, .43333f, .56667f), new Color(0f, .475f, .525f) }, // Tritanopia
        { new Color(.96667f, .03333f, 0),  new Color(0f, .73333f, .26667f), new Color(0f, .18333f, .81667f) }, // Tritanomaly
        { new Color(.299f, .587f, .114f),  new Color(.299f, .587f, .114f),  new Color(.299f, .587f, .114f)  },   // Achromatopsia
        { new Color(.618f, .32f, .062f),   new Color(.163f, .775f, .062f),  new Color(.163f, .320f, .516f)  }    // Achromatomaly
    };

    void Awake()
    {
        //material = new Material(Shader.Find("Hidden/ChannelMixer"));
        material.SetColor("_R", RGB[0, 0]);
        material.SetColor("_G", RGB[0, 1]);
        material.SetColor("_B", RGB[0, 2]);

        title.text = ColorBlindMode.Regular.ToString();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space)) usingPointer = !usingPointer;

        if(usingPointer)
        {
            float mouseX = Input.mousePosition.x;
            pointerPosition = mouseX / Screen.width;
            material.SetFloat("_XLimit", pointerPosition);
        }
        else
            material.SetFloat("_XLimit", 1.0f);

        int way = 0;
        if (Input.GetKeyDown(KeyCode.RightArrow)) way =  +1;
        if (Input.GetKeyDown(KeyCode.LeftArrow)) way = -1;

        if(way != 0)
        {
            int length = Enum.GetNames(typeof(ColorBlindMode)).Length;
            int projOutput = (int)mode + way;

            if (projOutput >= length || projOutput < 0) projOutput = way > 0 ? 0 : length - 1;
            mode = (ColorBlindMode)projOutput;

        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // No effect
        if (mode == ColorBlindMode.Regular)
        {
            Graphics.Blit(source, destination);
            return;
        }

        // Change effect
        if (mode != previousMode)
        {
            material.SetColor("_R", RGB[(int)mode, 0]);
            material.SetColor("_G", RGB[(int)mode, 1]);
            material.SetColor("_B", RGB[(int)mode, 2]);
            previousMode = mode;
        }

        // Apply effect
        Graphics.Blit(source, destination, material, showDifference ? 1 : 0);
    }
}