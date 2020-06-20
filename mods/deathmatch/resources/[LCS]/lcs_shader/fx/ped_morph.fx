//
// skidmarks.fx
//


//---------------------------------------------------------------------
// Skidmarks settings
//---------------------------------------------------------------------
float4 sHSVA1 = float4(  0,      1,  1,  1);        // HSV + Alpha for each of the 4 layers
float4 sHSVA2 = float4(  0.25,   1,  1,  0.75);
float4 sHSVA3 = float4(  0.5,    1,  1,  0.5);
float4 sHSVA4 = float4(  0.75,   1,  1,  0.25);
float sPosAmount = 0;                               // How much the position changes the color
float sSpeed = 0;                                   // How much the time changes the color
float sFilth = 0;                                   // Amount of random black patches


//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"


//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
  float3 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
};


//---------------------------------------------------------------------
// Helper function - Converts HSV to RGB
//---------------------------------------------------------------------
float3 HSVToRGB(float3 HSV)
{
    float3 RGB = HSV.z;
    float var_h = HSV.x * 6;
    float var_i = floor(var_h);
    float var_1 = HSV.z * (1.0 - HSV.y);
    float var_2 = HSV.z * (1.0 - HSV.y * (var_h-var_i));
    float var_3 = HSV.z * (1.0 - HSV.y * (1-(var_h-var_i)));
    if      (var_i == 0) { RGB = float3(HSV.z, var_3, var_1); }
    else if (var_i == 1) { RGB = float3(var_2, HSV.z, var_1); }
    else if (var_i == 2) { RGB = float3(var_1, HSV.z, var_3); }
    else if (var_i == 3) { RGB = float3(var_1, var_2, HSV.z); }
    else if (var_i == 4) { RGB = float3(var_3, var_1, HSV.z); }
    else                 { RGB = float3(HSV.z, var_1, var_2); }
    return RGB;
}


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(float4 Position :SV_POSITION, float2 TexCoord : TEXCOORD0, float Visibility : TEXCOORD1)
{
    PSInput PS = (PSInput)0;

    //float4 worldPosition = mul(Position, WorldViewProjection);
    //PS.Position = MTACalcScreenPosition ( Position );

	//float vis = Visibility * 3.0 – 1.0;
	PS.Diffuse = 0.5 * float4(0.65,0.65,0.65,0.5);
	PS.TexCoord = float2(0.5, TexCoord.y);

    return PS;
}


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    // Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);

    // Apply diffuse lighting
    float4 finalColor = texel * PS.Diffuse;

    //finalColor.rgb += PS.Diffuse.rgb;
    return finalColor;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique skidmarks
{
    // 4 passes, one for each layer
    pass P0
    {
        AlphaRef = 0;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
    /*
    pass P1
    {
        VertexShader = compile vs_2_0 VertexShaderFunction( 1, sHSVA2 );
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
    pass P2
    {
        VertexShader = compile vs_2_0 VertexShaderFunction( 2, sHSVA3 );
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
    pass P3
    {
        VertexShader = compile vs_2_0 VertexShaderFunction( 3, sHSVA4 );
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
    */
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
