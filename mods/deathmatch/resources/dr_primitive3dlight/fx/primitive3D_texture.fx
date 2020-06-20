// 
// file: primitive3D_texture.fx
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

float sSurfaceAttenuation = 0.2;
float sSurfaceAttenuationPower = 0.1;
float sSurfaceOffset = 0;

bool sFlipTexture = false;

float2 gDistFade = float2(250,150);

int fDestBlend = 6;
float2 sHalfPixel = float2(0.000625,0.00083);
float2 sPixelSize = float2(0.00125,0.00166);

float sTexBlend = 1;

//--------------------------------------------------------------------------------------
// Textures
//--------------------------------------------------------------------------------------
texture colorRT;

//--------------------------------------------------------------------------------------
// Variables set by MTA
//--------------------------------------------------------------------------------------
texture gDepthBuffer : DEPTHBUFFER;
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

sampler SamplerDepth = sampler_state
{
    Texture = (gDepthBuffer);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
    MaxMipLevel = 0;
    MipMapLodBias = 0;
};

sampler SamplerColor = sampler_state
{
    Texture = (colorRT);
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    MaxMipLevel = 0;
    MipMapLodBias = 0;
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
    float4 ProjCoord : TEXCOORD2;
    float3 WorldPos : TEXCOORD3;
    float3 FwVec : TEXCOORD4;
    float4 UvToView : TEXCOORD5;
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
// Create view matrix 
//--------------------------------------------------------------------------------------
float4x4 createViewMatrix( float3 pos, float3 fwVec, float3 upVec )
{
    float3 zaxis = normalize( fwVec );    // The "forward" vector.
    float3 xaxis = normalize( cross( -upVec, zaxis ));// The "right" vector.
    float3 yaxis = cross( xaxis, zaxis );     // The "up" vector.

    // Create a 4x4 view matrix from the right, up, forward and eye position vectors
    float4x4 viewMatrix = {
        float4(      xaxis.x,            yaxis.x,            zaxis.x,       0 ),
        float4(      xaxis.y,            yaxis.y,            zaxis.y,       0 ),
        float4(      xaxis.z,            yaxis.z,            zaxis.z,       0 ),
        float4(-dot( xaxis, pos ), -dot( yaxis, pos ), -dot( zaxis, pos ),  1 )
    };
    return viewMatrix;
}

//--------------------------------------------------------------------------------------
// Create orthographic projection matrix 
//--------------------------------------------------------------------------------------
float4x4 createOrthographicProjectionMatrix(float near_plane, float far_plane, float viewport_sizeX, float viewport_sizeY)
{
    float sizeX = 2 / viewport_sizeX;
    float sizeY = 2 / viewport_sizeY;
	
    float4x4 projectionMatrix = {
        float4(sizeX, 0, 0, 0),
        float4(0, sizeY, 0, 0),
        float4(0, 0, 2.0 / (far_plane - near_plane), 0),
        float4(0, 0, -(far_plane + near_plane) / (far_plane - near_plane), 1)
    };

    return projectionMatrix;
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
    PS.FwVec = sWorld[1].xyz;

    // calculate screen position of the vertex
    float4 wPos = mul(float4(VS.Position, 1), sWorld);
    float4 vPos = mul(wPos, gView);
    PS.Position = mul(vPos, gProjection);
	
    // pass world position
    PS.WorldPos = wPos.xyz;

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
	
    // set texCoords for projective texture
    float projectedX = (0.5 * (PS.Position.w + PS.Position.x));
    float projectedY = (0.5 * (PS.Position.w - PS.Position.y));
    PS.ProjCoord.xyz = float3(projectedX, projectedY, PS.Position.w);
	
    // Get distance from plane
    PS.ProjCoord.w = dot(gViewInverse[2].xyz, sLightPosition - gViewInverse[3].xyz) + 2 * lightAttenuation;
	
    // calculations for perspective-correct position recontruction
    float2 uvToViewADD = - 1 / float2(gProjection[0][0], gProjection[1][1]);	
    float2 uvToViewMUL = -2.0 * uvToViewADD.xy;
    PS.UvToView = float4(uvToViewMUL, uvToViewADD);
	
    return PS;
}

//--------------------------------------------------------------------------------------
//-- Get value from the depth buffer
//-- Uses define set at compile time to handle RAWZ special case (which will use up a few more slots)
//--------------------------------------------------------------------------------------
float FetchDepthBufferValue( float2 uv )
{
    float4 texel = tex2D(SamplerDepth, uv);
#if IS_DEPTHBUFFER_RAWZ
    float3 rawval = floor(255.0 * texel.arg + 0.5);
    float3 valueScaler = float3(0.996093809371817670572857294849, 0.0038909914428586627756752238080039, 1.5199185323666651467481343000015e-5);
    return dot(rawval, valueScaler / 255.0);
#else
    return texel.r;
#endif
}

//--------------------------------------------------------------------------------------
//-- Use the last scene projecion matrix to linearize the depth value a bit more
//--------------------------------------------------------------------------------------
float Linearize(float posZ)
{
    return gProjection[3][2] / (posZ - gProjection[2][2]);
}

//--------------------------------------------------------------------------------------
// GetPositionFromDepth
//--------------------------------------------------------------------------------------
float3 GetPositionFromDepth(float2 coords, float4 uvToView)
{
    return float3(coords.x * uvToView.x + uvToView.z, (1 - coords.y) * uvToView.y + uvToView.w, 1.0) 
        * Linearize(FetchDepthBufferValue(coords.xy));
}

//--------------------------------------------------------------------------------------
// GetPositionFromDepthMatrix
//--------------------------------------------------------------------------------------
float3 GetPositionFromDepthMatrix(float2 coords, float4x4 g_matInvProjection)
{
    float4 vProjectedPos = float4(coords.x * 2 - 1, (1 - coords.y) * 2 - 1, FetchDepthBufferValue(coords), 1.0f);
    float4 vPositionVS = mul(vProjectedPos, g_matInvProjection);  
    return vPositionVS.xyz / vPositionVS.w;  
}

//--------------------------------------------------------------------------------------
// More accurate than GetNormalFromDepth
//--------------------------------------------------------------------------------------
float3 GetNormalFromDepthMatrix(float2 coords, float4x4 g_matInvProjection)
{
    float3 offs = float3(sPixelSize.xy, 0);

    float3 f = GetPositionFromDepthMatrix(coords.xy, g_matInvProjection);
    float3 d_dx1 = - f + GetPositionFromDepthMatrix(coords.xy + offs.xz, g_matInvProjection);
    float3 d_dx2 =   f - GetPositionFromDepthMatrix(coords.xy - offs.xz, g_matInvProjection);
    float3 d_dy1 = - f + GetPositionFromDepthMatrix(coords.xy + offs.zy, g_matInvProjection);
    float3 d_dy2 =   f - GetPositionFromDepthMatrix(coords.xy - offs.zy, g_matInvProjection);

    d_dx1 = lerp(d_dx1, d_dx2, abs(d_dx1.z) > abs(d_dx2.z));
    d_dy1 = lerp(d_dy1, d_dy2, abs(d_dy1.z) > abs(d_dy2.z));

    return (- normalize(cross(d_dy1, d_dx1)));
}

//--------------------------------------------------------------------------------------
//  Calculates normals based on partial depth buffer derivatives.
//--------------------------------------------------------------------------------------
float3 GetNormalFromDepth(float2 coords, float4 uvToView)
{
    float3 offs = float3(sPixelSize.xy, 0);

    float3 f = GetPositionFromDepth(coords.xy, uvToView);
    float3 d_dx1 = - f + GetPositionFromDepth(coords.xy + offs.xz, uvToView);
    float3 d_dx2 =   f - GetPositionFromDepth(coords.xy - offs.xz, uvToView);
    float3 d_dy1 = - f + GetPositionFromDepth(coords.xy + offs.zy, uvToView);
    float3 d_dy2 =   f - GetPositionFromDepth(coords.xy - offs.zy, uvToView);

    d_dx1 = lerp(d_dx1, d_dx2, abs(d_dx1.z) > abs(d_dx2.z));
    d_dy1 = lerp(d_dy1, d_dy2, abs(d_dy1.z) > abs(d_dy2.z));

    return (- normalize(cross(d_dy1, d_dx1)));
}

//--------------------------------------------------------------------------------------
// Pixel shaders 
//--------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    // get projective texture coords
    float2 TexProj = PS.ProjCoord.xy / PS.ProjCoord.z;
    TexProj += sHalfPixel.xy;
	
    // get logarithmic and linear scene depth
    float bufferValue = FetchDepthBufferValue(TexProj);
    float linearDepth = Linearize(bufferValue);
	
    // disregard calculations when depth value is close to 1 and beyound light radius
    if (bufferValue > 0.99999f) return 0;
    if ((linearDepth - PS.ProjCoord.w) > 0) return 0;
	
    // retrieve world position from scene depth
    float3 viewPos = GetPositionFromDepth(TexProj.xy, PS.UvToView);
    float3 worldPos = mul(float4(viewPos.xyz, 1), gViewInverse).xyz;
	
    // get projection surface normal vector
    float3 surfaceNormal = normalize(PS.FwVec);
	
    // compute the distance from light and surface
    float fSDistance = abs(dot(surfaceNormal, worldPos.xyz - sLightPosition) + sSurfaceOffset);

    // compute the light attenuation
    float fSAttenuation = 1 - saturate(fSDistance / sSurfaceAttenuation);
    fSAttenuation = pow(fSAttenuation, sSurfaceAttenuationPower);
	
    // get texture color from colorRT
    float4 texColor = tex2D(SamplerColor, TexProj.xy);
    texColor.rgb = texColor.rgb * sTexBlend + (1 - sTexBlend);
    texColor.rgb *= texColor.a;
	
    // apply diffuse color
    float4 finalColor = texColor * PS.Diffuse;
	
    // combine
    finalColor.a *= fSAttenuation;
	
    // apply distance fade
    finalColor.a *= saturate(PS.DistFade);
	
    // add projective texture
    float4 texel = tex2D(SamplerTexture, PS.TexCoord.xy);
    finalColor *= texel;

    return saturate(finalColor);
}

float4 PixelShaderFunctionNoDB(PSInput PS) : COLOR0
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
technique dxDrawPrimitive3DTexture
{
  pass P0
  {
    ZEnable = false;
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
    VertexShader = compile vs_3_0 VertexShaderFunction();
    PixelShader  = compile ps_3_0 PixelShaderFunction();
  }
}

technique dxDrawPrimitive3DTexture_fallback
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
    PixelShader  = compile ps_2_0 PixelShaderFunctionNoDB();
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
