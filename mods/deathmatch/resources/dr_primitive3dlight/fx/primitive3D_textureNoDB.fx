// 
// file: primitive3D_textureNoDB.fx
// version: v1.6
// author: Ren712
//

//--------------------------------------------------------------------------------------
// Settings
//--------------------------------------------------------------------------------------
float4 sLightColor = float4(0,0,0,0);
texture sTexture;
float2 sPicSize = float2(1,1);
float3 sLightRotation = float3(0,0,0);
bool bProjectionPosition = false;
float3 sSurfaceNormal = float3(0,0,0);
float3 sLightPosition = float3(0,0,0);

bool sFlipTexture = false;

float2 gDistFade = float2(250,150);

int fDestBlend = 6;
float2 sHalfPixel = float2(0.000625,0.00083);
float2 sPixelSize = float2(0.00125,0.00166);

//--------------------------------------------------------------------------------------
// Variables set by MTA
//--------------------------------------------------------------------------------------
float4x4 gProjection : PROJECTION;
float4x4 gView : VIEW;
float4x4 gViewInverse : VIEWINVERSE;
int gFogEnable < string renderState="FOGENABLE"; >;
float4 gFogColor < string renderState="FOGCOLOR"; >;
float gFogStart < string renderState="FOGSTART"; >;
float gFogEnd < string renderState="FOGEND"; >;
static const float PI = 3.14159265f;
int gCapsMaxAnisotropy < string deviceCaps="MaxAnisotropy"; >;
int CUSTOMFLAGS < string skipUnusedParameters = "yes"; >;

//--------------------------------------------------------------------------------------
// Sampler 
//--------------------------------------------------------------------------------------
sampler SamplerTexture = sampler_state
{
    Texture = (sTexture);
    AddressU = Border;
    AddressV = Border;
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy;
    MinFilter = Anisotropic;
    BorderColor = float4(0,0,0,0);
};

//--------------------------------------------------------------------------------------
// Structures
//--------------------------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
    float4 Diffuse : COLOR0;
};

struct PSInput
{
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
    float DistFade : TEXCOORD1;
    float4 Diffuse : COLOR0;
};

//--------------------------------------------------------------------------------------
// Create world matrix with world position and euler rotation
//--------------------------------------------------------------------------------------
float4x4 createWorldMatrix(float3 pos, float3 rot)
{
    float4x4 eleMatrix = {
        float4(cos(rot.z) * cos(rot.y) - sin(rot.z) * sin(rot.x) * sin(rot.y), 
                cos(rot.y) * sin(rot.z) + cos(rot.z) * sin(rot.x) * sin(rot.y), -cos(rot.x) * sin(rot.y), 0),
        float4(-cos(rot.x) * sin(rot.z), cos(rot.z) * cos(rot.x), sin(rot.x), 0),
        float4(cos(rot.z) * sin(rot.y) + cos(rot.y) * sin(rot.z) * sin(rot.x), sin(rot.z) * sin(rot.y) - 
                cos(rot.z) * cos(rot.y) * sin(rot.x), cos(rot.x) * cos(rot.y), 0),
        float4(pos.x,pos.y,pos.z, 1),
    };
    return eleMatrix;
}

//--------------------------------------------------------------------------------------
// Vertex Shader 
//--------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // get position if bProjectionPosition
    float3 lightRotation = sLightRotation;
    float3 lightPosition = sLightPosition;
	float3 fwVec = - normalize(sSurfaceNormal) + float3(0.001,0.001,0.001);
    if (bProjectionPosition) 
    {
        lightRotation = float3(asin(fwVec.z / length(fwVec)), 0, -atan2(fwVec.x, fwVec.y));
        lightPosition -= fwVec * 0.05;
    }	
	
    // set proper size to the quad
    VS.Position.xy *= sPicSize;
	
    VS.Position.xyz = VS.Position.xzy;

    // create WorldMatrix for the quad
    float4x4 sWorld = createWorldMatrix(lightPosition, lightRotation);

    // calculate screen position of the vertex
    float4 wPos = mul(float4(VS.Position, 1), sWorld);
    float4 vPos = mul(wPos, gView);
    PS.Position = mul(vPos, gProjection);

    // get clip values
    float nearClip = - gProjection[3][2] / gProjection[2][2];
    float farClip = (gProjection[3][2] / (1 - gProjection[2][2]));
	
    // fade object
    float DistFromCam = vPos.z / vPos.w;
    float lightAttenuation = max(sPicSize.x, sPicSize.y);
    float2 DistFade = float2(max(0.3, min(gDistFade.x, farClip ) - lightAttenuation * 0.5), max(0, min(gDistFade.y, gFogStart) - lightAttenuation * 0.5));
    PS.DistFade = saturate((DistFromCam - DistFade.x)/(DistFade.y - DistFade.x));

    // flip texCoords.x
    if (sFlipTexture) VS.TexCoord = float2(VS.TexCoord.x, 1 - VS.TexCoord.y);
	
    // pass texCoords and vertex color to PS
    PS.TexCoord = VS.TexCoord;
    PS.Diffuse =  sLightColor;
	
    return PS;
}

//--------------------------------------------------------------------------------------
// Pixel shaders 
//--------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    // apply diffuse color
    float4 finalColor = PS.Diffuse;
	
    // apply distance fade
    finalColor.a *= saturate(PS.DistFade);
	
    // add projective texture
    float4 texel = tex2D(SamplerTexture, PS.TexCoord.xy);
    finalColor *= texel;

    return saturate(finalColor);
}

//--------------------------------------------------------------------------------------
// Techniques
//--------------------------------------------------------------------------------------
technique dxDrawPrimitive3DTextureNoDB
{
  pass P0
  {
    ZEnable = true;
    ZFunc = LessEqual;
    ZWriteEnable = false;
    CullMode = 2;
    ShadeMode = Gouraud;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = fDestBlend;
    AlphaTestEnable = true;
    AlphaRef = 1;
    AlphaFunc = GreaterEqual;
    Lighting = false;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunction();
    PixelShader  = compile ps_2_0 PixelShaderFunction();
  }
}

// Fallback
technique fallback
{
  pass P0
  {
    // Just draw normally
  }
}
