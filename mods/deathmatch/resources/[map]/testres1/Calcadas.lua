addEventHandler("onClientResourceStart", resourceRoot, function()
  shader = dxCreateShader("shader.fx")
  terrain = dxCreateTexture("1.png")
  dxSetShaderValue(shader, "gTexture", terrain)
  engineApplyShaderToWorldTexture(shader, "tunnel_law")
end
)


local tblVisibleLights = {}
local lp = getLocalPlayer()


_setLightColor = setLightColor
function setLightColor(uLight, iColorR, iColorG, iColorB)
	_setLightColor(uLight, iColorR, iColorG, iColorB)
	if tblVisibleLights[uLight] then
		setMarkerColor(tblVisibleLights[uLight].uMarker, iColorR, iColorG, iColorB, 255)
	end
end




_setLightRadius = setLightRadius
function setLightRadius(uLight, iRadius)
	_setLightRadius(uLight, iRadius)
	if tblVisibleLights[uLight] then
		setMarkerSize(tblVisibleLights[uLight].uMarker, iRadius/20)
	end
end




function createVisibleLight(iLightType, iX, iY, iZ, iRadius, iColorR, iColorG, iColorB, iDirX, iDirY, iDirZ, bShadow)
	if iLightType ~= 2 then
		local uLight = createLight(iLightType, iX, iY, iZ, iRadius, iColorR, iColorG, iColorB, iDirX, iDirY, iDirZ, bShadow)
			tblVisibleLights[uLight] = {}
			addEventHandler("onClientElementDestroy", uLight, function()
				tblVisibleLights[uLight] = nil
			end)
		if iLightType == 0 then
			local uSecondLight = createLight(iLightType, iX, iY, iZ, iRadius, iColorR, iColorG, iColorB, iDirX, iDirY, iDirZ, bShadow)
				tblVisibleLights[uLight].uSecondLight = uSecondLight
				attachElements(uSecondLight, uLight)
				setElementParent(uSecondLight, uLight)
		end
		local uMarker = createMarker(iX, iY, iZ, "corona", iRadius/20, iColorR, iColorG, iColorB, 255)
			tblVisibleLights[uLight].uMarker = uMarker
			attachElements(uMarker, uLight)
			setElementParent(uMarker, uLight)


		return uLight
	end
	return false
end

createVisibleLight(0, 0, 0, 5, 10, 255, 255, 255, 0, 0, 0, false)