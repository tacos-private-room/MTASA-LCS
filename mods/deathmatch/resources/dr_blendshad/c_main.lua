--
-- c_main.lua
--

local textureListTable = {}
textureListTable.AddBlendList = { "headlight", "shad_exp", "headlight1", "lamp_shad_64","coronastar" }

local scx, scy = guiGetScreenSize()
isFXSupported = (tonumber(dxGetStatus().VideoCardNumRenderTargets) > 1 and tonumber(dxGetStatus().VideoCardPSVersion) > 2 
	and tostring(dxGetStatus().DepthBufferFormat) ~= "unknown")

local renderTarget = {RTColor = nil, isOn = false}
					
local outShaderAdd = nil
local tbEffectEnabled = false

----------------------------------------------------------------------------------------------------------------------------
-- onClientResourceStart/Stop
----------------------------------------------------------------------------------------------------------------------------
addEventHandler( "onClientResourceStart", resourceRoot,
	function()
		if not isFXSupported then return end
		-- Create outShaderAdd
		outShaderAdd = dxCreateShader ( "fx/RToutput_add.fx", 1, 60, false, "world,object" )

		if not outShaderAdd then
			outputChatBox( "dr_blendShad: Shader not created.",255,0,0 )
		else
			renderTarget.isOn = getElementData ( localPlayer, "dr_renderTarget.on", false )
			if renderTarget.isOn then
				renderTarget.RTColor, _, _ = exports.dr_rendertarget:getRenderTargets()
				if not tbEffectEnabled and renderTarget.RTColor then
					applyBlendShad( outShaderAdd, textureListTable.AddBlendList )
					tbEffectEnabled = true
					print("shader on")
				end 
			end
		end
	end
)

function applyBlendShad(thisShader, texList)
	dxSetShaderValue( thisShader, "ColorRT", renderTarget.RTColor )
	dxSetShaderValue( thisShader, "sHalfPixel", 1 / (scx * 2), 1 / (scy * 2) )
	for _,applyMatch in ipairs( texList ) do
		engineApplyShaderToWorldTexture ( thisShader, applyMatch )

	end
end

function switchTexBlendEffect(resName, isStarted)
	if not isFXSupported then return end
	if isStarted then
		if resName == "dr_rendertarget" then
			if tbEffectEnabled then return end
			renderTarget.isOn = getElementData ( localPlayer, "dr_renderTarget.on", false )
			if renderTarget.isOn then
				renderTarget.RTColor, _, _ = exports.dr_rendertarget:getRenderTargets()
				if outShaderAdd and not tbEffectEnabled and renderTarget.RTColor then
					applyBlendShad( outShaderAdd, textureListTable.AddBlendList )
					tbEffectEnabled = true
				end
				return 
			end
		end	
	else
		if resName == "dr_rendertarget" then
			if tbEffectEnabled then
				renderTarget.isOn = false
				engineRemoveShaderFromWorldTexture ( outShaderAdd, "*" )
				tbEffectEnabled = false
			end
		end	
	end
end

addEventHandler ( "onClientResourceStop", root, function(stoppedRes)
	switchTexBlendEffect(getResourceName(stoppedRes), false)
end
)

addEventHandler ( "onClientResourceStart", root, function(startedRes)
	switchTexBlendEffect(getResourceName(startedRes), true)
end
)	

addEvent( "switchDR_renderTarget", true )
addEventHandler( "switchDR_renderTarget", root, function(isOn) switchTexBlendEffect("dr_rendertarget", isOn) end)