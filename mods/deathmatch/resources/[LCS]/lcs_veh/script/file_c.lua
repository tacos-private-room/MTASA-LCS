function replaceTexture()
local theShader = dxCreateShader( "material/effect.fx" )
local theTexture = dxCreateTexture( "material/fireball6.png" )
dxSetShaderValue(theShader,"gTexture",theTexture)
engineApplyShaderToWorldTexture(theShader,"fireball6")
end 
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), replaceTexture)
function resetTexture()
if theShader then
engineRemoveShaderFromWorldTexture ( theShader, "fireball6" )
end 
end
addEventHandler("onClientResourceStop", getResourceRootElement(getThisResource()),resetTexture )

