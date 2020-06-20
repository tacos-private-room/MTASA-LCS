// 
// file: primitive3D_projectedTextureConeNoDB.fx
// version: v1.6
// author: Ren712
//

//--------------------------------------------------------------------------------------
// Settings
//--------------------------------------------------------------------------------------
texture sTexture;
float2 sPicSize = float2(1,1);
float sProjFov = 1.3;
float3 sLightRotation = float3(0,0,0);
bool bProjectionPosition = false;
float3 sSurfaceNormal = float3(0,0,0);
float3 sLightPosition = float3(0,0,0);
float sLightAttenuation = 1;
float sLightAttenuationPower = 2;

float sSurfaceAttenuation = 0.2;
float sSurfaceAttenuationPower = 0.1;
float sSurfaceOffset = 0;

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
    float3 WorldPos : TEXCOORD2;
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

//------------------------------------------------------------------------------------------
// Create orthographic projection matrix 
//------------------------------------------------------------------------------------------
float4x4 createPerspectiveProjectionMatrix(float near_plane, float far_plane, float fov_horiz, float fov_aspect)
{
    float h, w, Q;

    w = 1/tan(fov_horiz * 0.5);
    h = w / fov_aspect;
    Q = far_plane/(far_plane - near_plane);

    float4x4 projectionMatrix = {
        float4(w, 0, 0, 0 ), float4(0, h, 0, 0), float4(0, 0, Q, 1), float4(0, 0, -Q*near_plane, 0)
    };    
    return projectionMatrix;
}

//--------------------------------------------------------------------------------------
// Vertex Shader 
//--------------------------------------------------------------------------------------
PSInput VertexShaderFunctionNoDB(VSInput VS)
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
    VS.Position.xy *= sLightAttenuation * 2.5;
	
    VS.Position.xyz = VS.Position.xzy;
	
    // flip texCoords.x
    VS.TexCoord.x = 1 - VS.TexCoord.x;

    // create WorldMatrix for the quad
    float4x4 sWorld = createWorldMatrix(lightPosition, lightRotation);

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
    float2 DistFade = float2(max(0.3, min(gDistFade.x, farClip ) - sLightAttenuation * 0.5), max(0, min(gDistFade.y, gFogStart) - sLightAttenuation * 0.5));
    PS.DistFade = saturate((DistFromCam - DistFade.x)/(DistFade.y - DistFade.x));

    // pass texCoords and vertex color to PS
    PS.TexCoord = VS.TexCoord;
    PS.Diffuse = VS.Diffuse;
	
    return PS;
}

//--------------------------------------------------------------------------------------
// Pixel shaders 
//--------------------------------------------------------------------------------------
float4 PixelShaderFunctionNoDB(PSInput PS) : COLOR0
{
    // Create world view and projection matrices (for the projective texture)	
    float4x4 sWorld = createWorldMatrix(sLightPosition, sLightRotation);
	float camDist = max(sPicSize.x, sPicSize.y) / 3;
    float4x4 sView = createViewMatrix(sLightPosition - sWorld[1].xyz * (camDist + 0.05), sWorld[1].xyz, sWorld[2].xyz);
    float4x4 sProjection = createPerspectiveProjectionMatrix(0.3, 400, sProjFov, sPicSize.y / sPicSize.x);
	
    // Get projective texture coordinates
    float4 viewPos = mul(float4(PS.WorldPos.xyz, 1), sView);
    float4 projPos = mul(viewPos, sProjection);
	
    float projX = (0.5 * (projPos.w + projPos.x));
    float projY = (0.5 * (projPos.w - projPos.y));
    float2 texCoord = float2(projX, projY) / projPos.w;
    texCoord.x = 1 - texCoord.x;
	
    // cut parts beyond the (0 - 1) coords and behind camera
    if ((texCoord.x > 1) || (texCoord.x < 0) || (texCoord.y > 1) || (texCoord.y < 0) || ((viewPos.z / viewPos.w) < 0)) return 0;

    // get projection surface normal vector
    float3 surfaceNormal = float3(0,0,0);
    if (bProjectionPosition) surfaceNormal = sSurfaceNormal;
    else surfaceNormal = - sWorld[1].xyz;
	
    // compute the distance from light and surface
    float fLDistance = distance(sLightPosition, PS.WorldPos.xyz);
	
    // compute the light attenuation
    float fLAttenuation = 1 - saturate(fLDistance / sLightAttenuation);
    fLAttenuation = pow(fLAttenuation, sLightAttenuationPower);
	
    // combine attenuation
    float fAttenuation = fLAttenuation;
	
    // apply diffuse color
    float4 finalColor = PS.Diffuse;
	
    // combine
    finalColor.a *= fAttenuation;
	
    // apply distance fade
    finalColor.a *= saturate(PS.DistFade);
	
    // flip texCoords.x
    if (sFlipTexture) texCoord = float2(1 - texCoord.y, texCoord.x);
	
    // add projective texture
    texCoord.x = 1 - texCoord.x;
    float4 texel = tex2D(SamplerTexture, texCoord);
    finalColor *= texel;

    return saturate(finalColor);
}

//--------------------------------------------------------------------------------------
// Techniques
//--------------------------------------------------------------------------------------
technique dxDrawPrimitive3DProjectedTextureConeNoDB
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
    VertexShader = compile vs_2_0 VertexShaderFunctionNoDB();
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
