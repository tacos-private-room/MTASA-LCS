local screenX, screenY = guiGetScreenSize()

local vehicleElement = false
local attachedElement = false
local dummyElement = false

local editorState = false
local editorFont = false

local selectedMode = "move"
local selectedAxis = false

local movementOffset = 0
local movementDetails = {}
local movementSpeed = 15

local snapMovement = 0
local snapRotation = 0
local snapMovementString = tostring(snapMovement)
local snapRotationString = tostring(snapRotation)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(availableMods) do
			if fileExists("mods/" .. v .. ".col") then
				engineReplaceCOL(engineLoadCOL("mods/" .. v .. ".col"), k)
			end

			if fileExists("mods/" .. v .. ".txd") then
				engineImportTXD(engineLoadTXD("mods/" .. v .. ".txd"), k)
			end

			if fileExists("mods/" .. v .. ".dff") then
				engineReplaceModel(engineLoadDFF("mods/" .. v .. ".dff"), k)
			end
		end
	end
)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		if selectedAxis then
			setCursorAlpha(255)
		end
	end
)

function toggleEditor(state, modelId)
	editorState = state
	modelId = tonumber(modelId)

	if editorState and modelId then
		local myVehicle = getPedOccupiedVehicle(localPlayer)

		if isElement(myVehicle) then
			vehicleElement = myVehicle

			if not attachedElement then
				local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicleElement)

				dummyElement = createObject(modelId, vehicleX, vehicleY, vehicleZ)
				attachedElement = createObject(modelId, vehicleX, vehicleY, vehicleZ)

				if isElement(attachedElement) then
					setElementStreamable(attachedElement, false)
					setElementCollisionsEnabled(attachedElement, false)
					setElementDoubleSided(attachedElement, true)
					attachElements(attachedElement, vehicleElement, 0, 0, 1, 0, 0, 0)
				end

				if isElement(dummyElement) then
					setElementStreamable(dummyElement, false)
					setElementCollisionsEnabled(dummyElement, false)
					setElementAlpha(dummyElement, 0)
				end

				editorFont = dxCreateFont("files/Roboto.ttf", 13, false, "proof") or "default"
				selectedMode = "move"
				selectedAxis = false

				addEventHandler("onClientRender", getRootElement(), renderHandler)
				addEventHandler("onClientClick", getRootElement(), clickHandler)
				addEventHandler("onClientCharacter", getRootElement(), characterHandler)
				addEventHandler("onClientKey", getRootElement(), keyHandler)
				addEventHandler("onClientVehicleStartExit", getRootElement(), exitHandler)
			else
				if isElement(attachedElement) then
					setElementModel(attachedElement, modelId)
					setElementModel(dummyElement, modelId)
				end
			end
		else
			outputChatBox("* You are not in a vehicle!", 215, 89, 89)
		end
	else
		if attachedElement then
			removeEventHandler("onClientRender", getRootElement(), renderHandler)
			removeEventHandler("onClientClick", getRootElement(), clickHandler)
			removeEventHandler("onClientCharacter", getRootElement(), characterHandler)
			removeEventHandler("onClientKey", getRootElement(), keyHandler)
			removeEventHandler("onClientVehicleStartExit", getRootElement(), exitHandler)
			showCursor ( false ) 

		end

		if isElement(attachedElement) then
			destroyElement(attachedElement)
		end

		if isElement(dummyElement) then
			destroyElement(dummyElement)
		end

		if isElement(editorFont) then
			destroyElement(editorFont)
		end

		vehicleElement = false
		attachedElement = false
		dummyElement = false
	end
end

function exitHandler(player)
	if player == localPlayer then
		if attachedElement then
			toggleEditor(false)
		end
	end
end

function keyHandler(key, press)
	if press then
		if key == "backspace" then
			if not activeFakeInput then
				toggleEditor(false)
				return
			end

			if selectedMode == "move" then
				if activeFakeInput == selectedMode then
					if string.len(snapMovementString) > 0 then
						snapMovementString = string.sub(snapMovementString, 1, -2)

						if tonumber(snapMovementString) then
							snapMovement = tonumber(snapMovementString)
						else
							snapMovement = 0
							snapMovementString = "0"
						end
					end
				end
			elseif selectedMode == "rotate" then
				if activeFakeInput == selectedMode then
					if string.len(snapRotationString) > 0 then
						snapRotationString = string.sub(snapRotationString, 1, -2)

						if tonumber(snapRotationString) then
							snapRotation = tonumber(snapRotationString)
						else
							snapRotation = 0
							snapRotationString = "0"
						end
					end
				end
			end
		end
	end
end

function characterHandler(character)
	if tonumber(character) or character == "." then
		if selectedMode == "move" then
			if activeFakeInput == selectedMode then
				if string.len(snapMovementString) < 8 then
					snapMovementString = snapMovementString .. character

					if tonumber(snapMovementString) then
						snapMovement = tonumber(snapMovementString)
					end
				end
			end
		elseif selectedMode == "rotate" then
			if activeFakeInput == selectedMode then
				if string.len(snapRotationString) < 7 then
					snapRotationString = snapRotationString .. character

					if tonumber(snapRotationString) then
						snapRotation = tonumber(snapRotationString)
					end
				end
			end
		end
	end
end

function clickHandler(button, state, absX, absY, worldX, worldY, worldZ)
	if button == "left" then
		if state == "up" then
			if attachedElement then
				activeFakeInput = false
				if not selectedAxis then
					local dummyMatrix = getElementMatrix(dummyElement)
					local guiX, guiY = getScreenFromWorldPosition(elementOffset(dummyMatrix, 0, 0, -0.75))

					if guiX and guiY then
						if absX >= guiX - 84 - 12 and absX <= guiX - 84 + 12 and absY >= guiY - 12 and absY <= guiY + 12 then
							selectedMode = "move"
						elseif absX >= guiX - 56 - 12 and absX <= guiX - 56 + 12 and absY >= guiY - 12 and absY <= guiY + 12 then
							selectedMode = "rotate"
						elseif absX >= guiX - 28 - 12 and absX <= guiX - 28 + 12 and absY >= guiY - 12 and absY <= guiY + 12 then
							setElementAttachedOffsets(attachedElement, 0, 0, 1, 0, 0, 0)
						elseif absX >= guiX - 12 and absX <= guiX + 12 and absY >= guiY - 12 and absY <= guiY + 12 then
							if isElement(attachedElement) then
								local data = {getElementModel(attachedElement), getElementAttachedOffsets(attachedElement)}

								triggerServerEvent("attachLightbarS", vehicleElement, data)
								toggleEditor(false)
							end
						elseif absX >= guiX - 30 - 24 and absX <= guiX + 30 - 24 and absY >= guiY + 24 and absY <= guiY + 48 then
							if selectedMode == "move" then
								activeFakeInput = "move"
							elseif selectedMode == "rotate" then
								activeFakeInput = "rotate"
							end
						end
					end
				end
			end
		end
	end
end

function renderHandler()
	local relX, relY = getCursorPosition()
	local absX, absY = -1000, -1000

	if relX then
		absX = relX * screenX
		absY = relY * screenY

		if selectedAxis then
			setCursorAlpha(0)
		end
	else
		if selectedAxis then
			selectedAxis = false
			setCursorAlpha(255)
		end
	end

	if isElement(vehicleElement) then
		if isElement(attachedElement) then
			local dummyMatrix = getElementMatrix(dummyElement)
			local dummyPosX, dummyPosY, dummyPosZ = getElementPosition(dummyElement)

			local basePosX, basePosY, basePosZ = getElementPosition(attachedElement)
			local vehicleRotX, vehicleRotY, vehicleRotZ = getElementRotation(vehicleElement)

			setElementPosition(dummyElement, basePosX, basePosY, basePosZ)
			setElementRotation(dummyElement, vehicleRotX, vehicleRotY, vehicleRotZ)

			if not selectedAxis then
				local guiX, guiY = getScreenFromWorldPosition(elementOffset(dummyMatrix, 0, 0, -0.75))

				if guiX and guiY then
					local tooltipText = false

					-- Mozgatás mód
					local moveRectColor = tocolor(25, 25, 25, 200)
					local moveIconColor = tocolor(200, 200, 200)
					if selectedMode == "move" then
						--[[
						moveRectColor = tocolor(120, 65, 65)

						dxDrawText("Snap:", guiX - 112 + 1, guiY + 24 + 1, 0 + 1, guiY + 48 + 1, tocolor(0, 0, 0), 0.75, editorFont, "left", "center")
						dxDrawText("Snap:", guiX - 112, guiY + 24, 0, guiY + 48, tocolor(255, 255, 255), 0.75, editorFont, "left", "center")

						local visibleText = tostring(snapMovement)
						if activeFakeInput == selectedMode then
							if math.abs(getTickCount() % 750 - 375) / 375 > 0.5 then
								visibleText = visibleText .. "|"
							end
						end
						dxDrawRectangle(guiX - 30 - 24, guiY + 24, 60, 24, tocolor(200, 200, 200))
						dxDrawText(visibleText, guiX - 30 - 24, guiY + 24, guiX + 30 - 24, guiY + 48, tocolor(0, 0, 0), 0.75, editorFont, "center", "center")
						--]]
					else
						if absX >= guiX - 84 - 12 and absX <= guiX - 84 + 12 and absY >= guiY - 12 and absY <= guiY + 12 then
							moveRectColor = tocolor(0, 0, 0, 200)
							moveIconColor = tocolor(255, 255, 255)
							tooltipText = "Move"
						end
					end
					dxDrawImage(guiX - 84 - 12, guiY - 12, 24, 24, "files/rounded.png", 0, 0, 0, moveRectColor)
					dxDrawImage(guiX - 84 - 12, guiY - 12, 24, 24, "files/move.png", 0, 0, 0, moveIconColor)

					-- Forgatás mód
					local rotateRectColor = tocolor(25, 25, 25, 200)
					local rotateIconColor = tocolor(200, 200, 200)
					if selectedMode == "rotate" then
						rotateRectColor = tocolor(120, 65, 65)

						dxDrawText("Snap:", guiX - 112 + 1, guiY + 24 + 1, 0 + 1, guiY + 48 + 1, tocolor(0, 0, 0), 0.75, editorFont, "left", "center")
						dxDrawText("Snap:", guiX - 112, guiY + 24, 0, guiY + 48, tocolor(255, 255, 255), 0.75, editorFont, "left", "center")

						local visibleText = tostring(snapRotation)
						if activeFakeInput == selectedMode then
							if math.abs(getTickCount() % 750 - 375) / 375 > 0.5 then
								visibleText = visibleText .. "|"
							end
						end
						dxDrawRectangle(guiX - 30 - 24, guiY + 24, 60, 24, tocolor(200, 200, 200))
						dxDrawText(visibleText .. " °", guiX - 30 - 24, guiY + 24, guiX + 30 - 24, guiY + 48, tocolor(0, 0, 0), 0.75, editorFont, "center", "center")
					else
						if absX >= guiX - 56 - 12 and absX <= guiX - 56 + 12 and absY >= guiY - 12 and absY <= guiY + 12 then
							rotateRectColor = tocolor(0, 0, 0, 200)
							rotateIconColor = tocolor(255, 255, 255)
							tooltipText = "Rotate"
						end
					end
					dxDrawImage(guiX - 56 - 12, guiY - 12, 24, 24, "files/rounded.png", 0, 0, 0, rotateRectColor)
					dxDrawImage(guiX - 56 - 12, guiY - 12, 24, 24, "files/rotate.png", 0, 0, 0, rotateIconColor)

					-- Alapállapot visszaállítása
					local resetRectColor = tocolor(25, 25, 25, 200)
					local resetIconColor = tocolor(200, 200, 200)
					if absX >= guiX - 28 - 12 and absX <= guiX - 28 + 12 and absY >= guiY - 12 and absY <= guiY + 12 then
						resetRectColor = tocolor(0, 0, 0, 200)
						resetIconColor = tocolor(255, 255, 255)
						tooltipText = "Reset"
					end
					dxDrawImage(guiX - 28 - 12, guiY - 12, 24, 24, "files/rounded.png", 0, 0, 0, resetRectColor)
					dxDrawImage(guiX - 28 - 12, guiY - 12, 24, 24, "files/reset.png", 0, 0, 0, resetIconColor)

					-- Mentés
					local saveRectColor = tocolor(25, 25, 25, 200)
					local saveIconColor = tocolor(200, 200, 200)
					if absX >= guiX - 12 and absX <= guiX + 12 and absY >= guiY - 12 and absY <= guiY + 12 then
						saveRectColor = tocolor(0, 0, 0, 200)
						saveIconColor = tocolor(255, 255, 255)
						tooltipText = "Save"
					end
					dxDrawImage(guiX - 12, guiY - 12, 24, 24, "files/rounded.png", 0, 0, 0, saveRectColor)
					dxDrawImage(guiX - 12, guiY - 12, 24, 24, "files/save.png", 0, 0, 0, saveIconColor)

					-- ** Tooltip
					if tooltipText then
						local textWidth = dxGetTextWidth(tooltipText, 0.85, editorFont)
						local textHeight = dxGetFontHeight(1, editorFont) + 5

						dxDrawRectangle(absX + 5, absY, textWidth, textHeight, tocolor(0, 0, 0, 200))
						dxDrawText(tooltipText, absX + 5, absY, absX + 5 + textWidth, absY + textHeight, tocolor(255, 255, 255), 0.75, editorFont, "center", "center")
					end
				end
			end

			local element_2d_x, element_2d_y = getScreenFromWorldPosition(dummyPosX, dummyPosY, dummyPosZ)

			if selectedAxis then
				if relX and relY then
					local camRotX, camRotY, camRotZ = getElementRotation(getCamera())
					local movementAngle = math.rad(camRotZ - vehicleRotZ) * -1
					local distanceMoved = 0

					if selectedMode == "move" then
						if selectedAxis == "x" then
							distanceMoved = (0.5 - relY) * movementSpeed * math.sin(movementAngle) + (0.5 - relX) * movementSpeed * -math.cos(movementAngle)
						elseif selectedAxis == "y" then
							distanceMoved = (0.5 - relX) * movementSpeed * math.sin(movementAngle) + (0.5 - relY) * movementSpeed * math.cos(movementAngle)
						elseif selectedAxis == "z" then
							distanceMoved = (0.5 - relY) * movementSpeed
						end
					elseif selectedMode == "rotate" then
						distanceMoved = (0.5 - relX) * movementSpeed * 5

						if snapRotation > 0 then
							distanceMoved = distanceMoved * 15
						end
					end

					setCursorPosition(screenX / 2, screenY / 2)
					movementOffset = movementOffset + distanceMoved

					if selectedMode == "move" then
						if selectedAxis == "x" then
							local newValue = movementDetails[1] + movementOffset

							if snapMovement > 0 then
								newValue = math.floor(newValue * snapMovement) / snapMovement
							end

							setElementAttachedOffsets(attachedElement, newValue, movementDetails[2], movementDetails[3], movementDetails[4], movementDetails[5], movementDetails[6])
						elseif selectedAxis == "y" then
							local newValue = movementDetails[2] + movementOffset

							if snapMovement > 0 then
								newValue = math.floor(newValue * snapMovement) / snapMovement
							end

							setElementAttachedOffsets(attachedElement, movementDetails[1], newValue, movementDetails[3], movementDetails[4], movementDetails[5], movementDetails[6])
						elseif selectedAxis == "z" then
							local newValue = movementDetails[3] + movementOffset

							if snapMovement > 0 then
								newValue = math.floor(newValue * snapMovement) / snapMovement
							end

							setElementAttachedOffsets(attachedElement, movementDetails[1], movementDetails[2], newValue, movementDetails[4], movementDetails[5], movementDetails[6])
						end
					elseif selectedMode == "rotate" then
						if selectedAxis == "x" then
							local newValue = movementDetails[4] + movementOffset

							if snapRotation > 0 then
								newValue = math.ceil(newValue / snapRotation) * snapRotation
							end

							setElementAttachedOffsets(attachedElement, movementDetails[1], movementDetails[2], movementDetails[3], newValue, movementDetails[5], movementDetails[6])
						elseif selectedAxis == "y" then
							local newValue = movementDetails[5] + movementOffset

							if snapRotation > 0 then
								newValue = math.ceil(newValue / snapRotation) * snapRotation
							end

							setElementAttachedOffsets(attachedElement, movementDetails[1], movementDetails[2], movementDetails[3], movementDetails[4], newValue, movementDetails[6])
						elseif selectedAxis == "z" then
							local newValue = movementDetails[6] + movementOffset

							if snapRotation > 0 then
								newValue = math.ceil(newValue / snapRotation) * snapRotation
							end

							setElementAttachedOffsets(attachedElement, movementDetails[1], movementDetails[2], movementDetails[3], movementDetails[4], movementDetails[5], newValue)
						end
					end
				end
			end

			if element_2d_x and element_2d_y then
				local axis_xx, axis_xy = getScreenFromWorldPosition(elementOffset(dummyMatrix, 0.75, 0, 0))
				local axis_yx, axis_yy = getScreenFromWorldPosition(elementOffset(dummyMatrix, 0, 0.75, 0))
				local axis_zx, axis_zy = getScreenFromWorldPosition(elementOffset(dummyMatrix, 0, 0, 0.75))

				if axis_xx and axis_xy then
					local line_length_x = (axis_xx - element_2d_x) / 2
					local line_length_y = (axis_xy - element_2d_y) / 2

					local line_start_x = element_2d_x - line_length_x
					local line_start_y = element_2d_y - line_length_y

					if selectedMode then
						if selectedAxis == "x" then
							if not getKeyState("mouse1") then
								selectedAxis = false
								setCursorPosition(line_start_x, line_start_y)
								setCursorAlpha(255)
								return
							end
						end
					end

					if not selectedAxis then
						if getKeyState("mouse1") then
							if relX then
								if absX >= line_start_x - 12 and absY >= line_start_y - 12 and absX <= line_start_x + 24 and absY <= line_start_y + 24 then
									local offPosX, offPosY, offPosZ, offRotX, offRotY, offRotZ = getElementAttachedOffsets(attachedElement)

									if selectedMode == "move" then
										movementDetails = {offPosX, offPosY, offPosZ, offRotX, offRotY, offRotZ}
									elseif selectedMode == "rotate" then
										movementDetails = {offPosX, offPosY, offPosZ, offRotX, offRotY, offRotZ}
									end

									movementOffset = 0
									selectedAxis = "x"

									setCursorPosition(screenX / 2, screenY / 2)
									setCursorAlpha(0)
								end
							end
						end
					end

					dxDrawLine(line_start_x, line_start_y, line_start_x + line_length_x * 2, line_start_y + line_length_y * 2, tocolor(150, 150, 200), 1.5)

					local rectColor = tocolor(25, 25, 25, 200)
					local iconColor = tocolor(150, 150, 200)

					if selectedAxis == "x" then
						rectColor = iconColor
						iconColor = tocolor(255, 255, 255)
					end

					dxDrawImage(line_start_x - 12, line_start_y - 12, 24, 24, "files/rounded.png", 0, 0, 0, rectColor)
					dxDrawImage(line_start_x - 12, line_start_y - 12, 24, 24, "files/" .. selectedMode .. "_x.png", 0, 0, 0, iconColor)
				end

				if axis_yx and axis_yy then
					local line_length_x = (axis_yx - element_2d_x) / 2
					local line_length_y = (axis_yy - element_2d_y) / 2

					local line_start_x = element_2d_x - line_length_x
					local line_start_y = element_2d_y - line_length_y

					if selectedMode then
						if selectedAxis == "y" then
							if not getKeyState("mouse1") then
								selectedAxis = false
								setCursorPosition(line_start_x, line_start_y)
								setCursorAlpha(255)
								return
							end
						end
					end

					if not selectedAxis then
						if getKeyState("mouse1") then
							if relX then
								if absX >= line_start_x - 12 and absY >= line_start_y - 12 and absX <= line_start_x + 24 and absY <= line_start_y + 24 then
									local offPosX, offPosY, offPosZ, offRotX, offRotY, offRotZ = getElementAttachedOffsets(attachedElement)

									if selectedMode == "move" then
										movementDetails = {offPosX, offPosY, offPosZ, offRotX, offRotY, offRotZ}
									elseif selectedMode == "rotate" then
										movementDetails = {offPosX, offPosY, offPosZ, offRotX, offRotY, offRotZ}
									end

									movementOffset = 0
									selectedAxis = "y"

									setCursorPosition(screenX / 2, screenY / 2)
									setCursorAlpha(0)
								end
							end
						end
					end

					dxDrawLine(line_start_x, line_start_y, line_start_x + line_length_x * 2, line_start_y + line_length_y * 2, tocolor(205, 150, 150), 1.5)

					local rectColor = tocolor(25, 25, 25, 200)
					local iconColor = tocolor(205, 150, 150)

					if selectedAxis == "y" then
						rectColor = iconColor
						iconColor = tocolor(255, 255, 255)
					end

					dxDrawImage(line_start_x - 12, line_start_y - 12, 24, 24, "files/rounded.png", 0, 0, 0, rectColor)
					dxDrawImage(line_start_x - 12, line_start_y - 12, 24, 24, "files/" .. selectedMode .. "_y.png", 0, 0, 0, iconColor)
				end

				if axis_zx and axis_zy then
					local line_length_x = (element_2d_x - axis_zx) / 2
					local line_length_y = (element_2d_y - axis_zy) / 2

					local line_start_x = element_2d_x - line_length_x
					local line_start_y = element_2d_y - line_length_y

					if selectedMode then
						if selectedAxis == "z" then
							if not getKeyState("mouse1") then
								selectedAxis = false
								setCursorPosition(line_start_x, line_start_y)
								setCursorAlpha(255)
								return
							end
						end
					end

					if not selectedAxis then
						if getKeyState("mouse1") then
							if relX then
								if absX >= line_start_x - 12 and absY >= line_start_y - 12 and absX <= line_start_x + 24 and absY <= line_start_y + 24 then
									local offPosX, offPosY, offPosZ, offRotX, offRotY, offRotZ = getElementAttachedOffsets(attachedElement)

									if selectedMode == "move" then
										movementDetails = {offPosX, offPosY, offPosZ, offRotX, offRotY, offRotZ}
									elseif selectedMode == "rotate" then
										movementDetails = {offPosX, offPosY, offPosZ, offRotX, offRotY, offRotZ}
									end

									movementOffset = 0
									selectedAxis = "z"

									setCursorPosition(screenX / 2, screenY / 2)
									setCursorAlpha(0)
								end
							end
						end
					end

					dxDrawLine(line_start_x, line_start_y, line_start_x + line_length_x * 2, line_start_y + line_length_y * 2, tocolor(145, 195, 145), 1.5)

					local rectColor = tocolor(25, 25, 25, 200)
					local iconColor = tocolor(145, 195, 145)

					if selectedAxis == "z" then
						rectColor = iconColor
						iconColor = tocolor(255, 255, 255)
					end

					dxDrawImage(line_start_x - 12, line_start_y - 12, 24, 24, "files/rounded.png", 0, 0, 0, rectColor)
					dxDrawImage(line_start_x - 12, line_start_y - 12, 24, 24, "files/" .. selectedMode .. "_z.png", 0, 0, 0, iconColor)
				end
			end
		end
	end
end

function elementOffset(m, x, y, z)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
			x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
			x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end

function rotateAround(angle, offsetX, offsetY, baseX, baseY)
	angle = math.rad(angle)

	offsetX = offsetX or 0
	offsetY = offsetY or 0

	baseX = baseX or 0
	baseY = baseY or 0

	return baseX + offsetX * math.cos(angle) - offsetY * math.sin(angle),
			 baseY + offsetX * math.sin(angle) + offsetY * math.cos(angle)
end
