//
// Shader - addPalette.fx
// 

texture TEX0;
texture TEX1;
float isPaleteEnabled =0;
float4 gCol=float4(255,255,255,255);

sampler2D Sampler0 = sampler_state
{
    Texture = <TEX0>;
	AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
};

sampler2D Sampler1 = sampler_state
{
    Texture = <TEX1>;
	AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
};
//---------------------------------------------------------------------
// pixel shader
//---------------------------------------------------------------------

float4 PostProcessPS0(float2 TexCoord : TEXCOORD0) : COLOR0
{

float4 finalColor;
if (isPaleteEnabled ==1) {
	float4 main = tex2D(Sampler0,TexCoord.xy).rgba;
	finalColor.rgb=tex2D(Sampler1,float3(main.r,main.g,main.b)).rgb;
	finalColor.a=tex2D(Sampler0,TexCoord.xy).a;
	finalColor*=float4(main.rgb,1);
	finalColor.r*=(gCol.r/255);
	finalColor.r+=main.r*(1-(gCol.a/255));
	finalColor.g*=(gCol.g/255);
	finalColor.g+=main.g*(1-(gCol.a/255));
	finalColor.b*=(gCol.b/255);
	finalColor.b+=main.b*(1-(gCol.a/255));
	finalColor.a=main.a;
}
else
{
 finalColor = tex2D(Sampler0, TexCoord.xy);
}

return finalColor;		
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique addpalette
{
    pass P1
    {
        PixelShader = compile ps_2_0 PostProcessPS0();
    }
}
