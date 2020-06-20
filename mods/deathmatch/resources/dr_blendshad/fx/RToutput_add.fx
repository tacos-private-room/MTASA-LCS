//
// RToutput_add.fx
//

//------------------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------------------
float2 sHalfPixel = float2(0.000625,0.00083);

//------------------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------------------
texture colorRT;

//------------------------------------------------------------------------------------------
// Include some common stuff
//------------------------------------------------------------------------------------------
//#define GENERATE_NORMALS      // Uncomment for normals to be generated
#include "mta-helper.fx"

//------------------------------------------------------------------------------------------
// Sampler for the main texture
//------------------------------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

sampler SamplerColor = sampler_state
{
    Texture = (colorRT);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
    SRGBTexture = false;
    MaxMipLevel = 0;
    MipMapLodBias = 0;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//------------------------------------------------------------------------------------------
struct VSInput
{
  float3 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//------------------------------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float3 TexProj : TEXCOORD1;
};

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;
	
    PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
	
    // Set texCoords for projective texture
    float projectedX = (0.5 * (PS.Position.w + PS.Position.x));
    float projectedY = (0.5 * (PS.Position.w - PS.Position.y));
    PS.TexProj.xyz = float3(projectedX, projectedY, PS.Position.w); 

    // pass texCoords and vertex color to PS
    PS.TexCoord = VS.TexCoord;
	
    // Calculate GTA lighting for buildings
    PS.Diffuse = VS.Diffuse;

    return PS;
}

//------------------------------------------------------------------------------------------
// Structure of color data sent to the renderer ( from the pixel shader  )
//------------------------------------------------------------------------------------------
struct Pixel
{
    float4 World : COLOR0;      // Render target #0
};

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
Pixel PixelShaderFunction(PSInput PS)
{
    Pixel output;
	
    // Get projective texture coords	
    float2 TexProj = PS.TexProj.xy / PS.TexProj.z;
    TexProj += sHalfPixel.xy;	

    // Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);

    // Apply diffuse lighting
    float4 finalColor = texel * float4(PS.Diffuse.rgb, 1);
    finalColor.rgb = saturate(finalColor.rgb * 3);
	
    // Get projective texture color
    float4 inColor = tex2D(SamplerColor, TexProj);

    finalColor.rgb *= inColor.rgb;
	
    output.World = finalColor;
 
    return output;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique RToutput_add
{
  pass P0
  {
    SrcBlend = SrcAlpha;
    DestBlend = One;
    VertexShader = compile vs_2_0 VertexShaderFunction();
    PixelShader = compile ps_2_0 PixelShaderFunction();
  }
}

technique fallback
{
  pass P0
  {
    // Just draw normally
  }
}
