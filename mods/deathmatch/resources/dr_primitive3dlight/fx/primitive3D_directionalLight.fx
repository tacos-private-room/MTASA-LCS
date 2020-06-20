// 
// file: primitive3D_directionalLight.fx
// version: v1.6
// author: Ren712
//

//--------------------------------------------------------------------------------------
// Settings
//--------------------------------------------------------------------------------------
float4 sLightColor = float4(0,0,0,0);
float3 sLightDir = float3(0,0,-1);
float2 gDistFade = float2(250,150);

float2 fViewportSize = float2(800, 600);
float2 fViewportScale = float2(1, 1);
float2 fViewportPos = float2(0, 0);

float sZRotation = 0;
float2 sZRotationCenterOffset = float2(0, 0);

int fCullMode = 1;
bool bForceFogOn = true;

float2 sHalfPixel = float2(0.000625,0.00083);
float2 sPixelSize = float2(0.00125,0.00166);

float sTexBlend = 1;

//--------------------------------------------------------------------------------------
// Textures
//--------------------------------------------------------------------------------------
texture colorRT;
texture normalRT;

//--------------------------------------------------------------------------------------
// Variables set by MTA
//--------------------------------------------------------------------------------------
texture gDepthBuffer : DEPTHBUFFER;
float4x4 gProjection : PROJECTION;
float4x4 gView : VIEW;
float4x4 gViewInverse : VIEWINVERSE;
float4x4 gWorld : WORLD;
float3 gCameraPosition : CAMERAPOSITION;
float3 gCameraDirection : CAMERADIRECTION;
int gFogEnable < string renderState="FOGENABLE"; >;
float4 gFogColor < string renderState="FOGCOLOR"; >;
float gFogStart < string renderState="FOGSTART"; >;
float gFogEnd < string renderState="FOGEND"; >;
int CUSTOMFLAGS < string skipUnusedParameters = "yes"; >;

//--------------------------------------------------------------------------------------
// Sampler 
//--------------------------------------------------------------------------------------
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

sampler SamplerNormal = sampler_state
{
    Texture = (normalRT);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
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
    float4 UvToView : TEXCOORD1;
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
// Returns a rotation matrix (rotate by Z)
//--------------------------------------------------------------------------------------
float4x4 makeZRotation( float angleInRadians) 
{
  float c = cos(angleInRadians);
  float s = sin(angleInRadians);
  
  return float4x4(
     c, s, 0, 0,
    -s, c, 0, 0,
     0, 0, 1, 0,
     0, 0, 0, 1
  );
}

//--------------------------------------------------------------------------------------
// Returns a translation matrix
//--------------------------------------------------------------------------------------
float4x4 makeTranslation( float3 trans) 
{
  return float4x4(
     1,  0,  0,  0,
     0,  1,  0,  0,
     0,  0,  1,  0,
     trans.x, trans.y, trans.z, 1
  );
}

//--------------------------------------------------------------------------------------
// Creates projection matrix of a shadered dxDrawImage
//--------------------------------------------------------------------------------------
float4x4 createImageProjectionMatrix(float2 viewportPos, float2 viewportSize, float2 viewportScale, float adjustZFactor, float nearPlane, float farPlane)
{
    float Q = farPlane / ( farPlane - nearPlane );
    float rcpSizeX = 2.0f / viewportSize.x;
    float rcpSizeY = -2.0f / viewportSize.y;
    rcpSizeX *= adjustZFactor;
    rcpSizeY *= adjustZFactor;
    float viewportPosX = 2 * viewportPos.x;
    float viewportPosY = 2 * viewportPos.y;
	
    float4x4 sProjection = {
        float4(rcpSizeX * viewportScale.x, 0, 0,  0), float4(0, rcpSizeY * viewportScale.y, 0, 0), float4(viewportPosX, -viewportPosY, Q, 1),
        float4(( -viewportSize.x / 2.0f - 0.5f ) * rcpSizeX,( -viewportSize.y / 2.0f - 0.5f ) * rcpSizeY, -Q * nearPlane , 0)
    };

    return sProjection;
}

//--------------------------------------------------------------------------------------
// Vertex Shader 
//--------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;
	
    // set proper position of the quad
    VS.Position.xyz = float3(VS.TexCoord, 0);
	
    // rotate
    VS.Position.xy -= 0.5 + sZRotationCenterOffset;
    VS.Position.xyz = mul(float4(VS.Position.xyz, 1), makeZRotation(sZRotation));	
    VS.Position.xy += 0.5 + sZRotationCenterOffset;		
    // resize
    VS.Position.xy *= fViewportSize;

    // create projection matrix (as done for shadered dxDrawImage)
    float4x4 sProjection = createImageProjectionMatrix(fViewportPos, fViewportSize, fViewportScale, 1000, 100, 10000);
	
    // calculate screen position of the vertex
    float4 viewPos = mul(float4(VS.Position.xyz, 1), makeTranslation(float3(0,0, 1000)));
    PS.Position = mul(viewPos, sProjection);

    // pass texCoords and vertex color to PS
    PS.TexCoord = VS.TexCoord;
    PS.Diffuse =  sLightColor;
	
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
    // get logarithmic and linear scene depth
    float bufferValue = FetchDepthBufferValue(PS.TexCoord);
    float linearDepth = Linearize(bufferValue);
	
    // disregard calculations when depth value is close to 1
    if (bufferValue > 0.99999f) return 0;
	
    // retrieve world position from scene depth
    float3 viewPos = GetPositionFromDepth(PS.TexCoord.xy, PS.UvToView);
    float3 worldPos = mul(float4(viewPos.xyz, 1),  gViewInverse).xyz;
	
    // fade effect
    float farClip = (gProjection[3][2] / (1 - gProjection[2][2]));
    float DistFromCam = viewPos.z;
    float2 DistFade = float2(max(0.3, min(gDistFade.x, farClip )), max(0, min(gDistFade.y, gFogStart)));
    float distFade = saturate((DistFromCam - DistFade.x)/(DistFade.y - DistFade.x));
	
    // get world normal from normalRT
    float3 texNormal = tex2D(SamplerNormal, PS.TexCoord.xy).xyz;
    float3 worldNormal = (texNormal - 0.5) * 2;

    // light direction
    float3 lightDir = - normalize(sLightDir);

    // dot product
    float NdotL = saturate(max(0.0f, dot(worldNormal, lightDir)));
	
    // get texture color from colorRT
    float4 texColor = tex2D(SamplerColor, PS.TexCoord.xy);
    texColor.rgb = texColor.rgb * sTexBlend + (1 - sTexBlend);
    texColor.rgb *= texColor.a;
	
    // apply diffuse color
    float4 finalColor = texColor * PS.Diffuse;
	
    // apply attenuation
    finalColor.rgb *= NdotL;

    // apply distance fade
    finalColor.a *= saturate(distFade);
	
    return saturate(finalColor);
}

float4 PixelShaderFunctionNoDB(PSInput PS) : COLOR0
{
    // apply diffuse color
    float4 finalColor = PS.Diffuse;
	
    // divide alpha value by 2
    finalColor.a *= 0.5;

    return saturate(finalColor);
}

//--------------------------------------------------------------------------------------
// Techniques
//--------------------------------------------------------------------------------------
technique dxDrawPrimitive3DDirectionalLight
{
  pass P0
  {
    ZEnable = false;
    ZWriteEnable = false;
    CullMode = fCullMode;
    ShadeMode = Gouraud;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    AlphaFunc = GreaterEqual;
    Lighting = false;
    FogEnable = false;
    VertexShader = compile vs_3_0 VertexShaderFunction();
    PixelShader  = compile ps_3_0 PixelShaderFunction();
  }
} 

technique dxDrawMaterial3DDirectionalLight_fallback
{
  pass P0
  {
    ZEnable = false;
    ZWriteEnable = false;
    CullMode = fCullMode;
    ShadeMode = Gouraud;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
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
