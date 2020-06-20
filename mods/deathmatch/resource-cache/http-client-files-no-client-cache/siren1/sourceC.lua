local createdLightbars = {}

addEventHandler("onClientResourceStart", resourceRoot, function()
	triggerServerEvent("requestAttachedLightbarsS", localPlayer)
end)

local screenX, screenY = guiGetScreenSize()

local panelState = false

local buttons = {}
local activeButton = false

local Roboto = dxCreateFont("files/Roboto.ttf", 13, false, "proof") or "default"

local panelW, panelH = 500, 350
local panelX, panelY = (screenX - panelW) * 0.5, (screenY - panelH) * 0.5

local listW, listH = 220, 240
local listX, listY = panelX + 10, panelY + 40 + 10

local rowW, rowH = listW, 40
local rowX = panelX + 10

local maxRows = math.floor(listH / rowH)
local listOffset = 0
local activeItem = 1

local imageS = 200
local imageX, imageY = panelX + panelW - imageS - 20, listY

local availableLightbars = {}

for k, v in pairs(availableMods) do
	table.insert(availableLightbars, k)
end

function togglePanel(state)
	if state then
		showCursor ( true ) 
		addEventHandler("onClientRender", root, renderPanel)
		addEventHandler("onClientClick", root, panelClickHandler)
		addEventHandler("onClientKey", root, panelKeyHandler)
	else
		removeEventHandler("onClientRender", root, renderPanel)
		removeEventHandler("onClientClick", root, panelClickHandler)
		removeEventHandler("onClientKey", root, panelKeyHandler)
	end

	panelState = state
end

addCommandHandler("sirenpanel", function()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then
		if isVehicleSupported(vehicle) then
			togglePanel(not panelState)
		else
			outputChatBox("** Vehicle model is not supported!", 215, 89, 89)
		end
	else
		outputChatBox("** You are not in a vehicle!", 215, 89, 89)
	end
end)

function renderPanel()
	local absX, absY = getCursorPosition()

	buttons = {}

	if isCursorShowing() then
		absX = absX * screenX
		absY = absY * screenY
	else
		absX, absY = -1, -1
	end

	dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(80, 80, 80, 230))
	dxDrawRectangle(panelX, panelY + 30, panelW, 3, tocolor(80, 200, 120, 230))
	dxDrawText("Lightbar selector", panelX, panelY, panelX + panelW, panelY + 30, tocolor(240, 240, 240), 1, Roboto, "center", "center")

	--dxDrawRectangle(listX, listY, listW, listH, tocolor(50, 50, 50, 230))

	local i = 0
	for i = 1, maxRows do
		if availableLightbars[i + listOffset] then
			local rowY = listY + rowH * (i - 1)

			if activeItem == i + listOffset then
				dxDrawRectangle(rowX, rowY, rowW, rowH, tocolor(80, 200, 120, 140))
			elseif i % 2 == 0 then
				dxDrawRectangle(rowX, rowY, rowW, rowH, tocolor(50, 50, 50, 150))
			else
				dxDrawRectangle(rowX, rowY, rowW, rowH, tocolor(50, 50, 50, 230))
			end
			dxDrawText("Lightbar " .. i + listOffset, rowX + 5, rowY, rowW, rowH + rowY, tocolor(255, 255, 255), 0.8, Roboto, "left", "center")
			
			buttons["item:" .. i + listOffset] = {rowX, rowY, rowW, rowH}
		end
	end

	local lightbarNum = #availableLightbars

	if lightbarNum > maxRows then
		local trackSize = listH
		dxDrawRectangle(listX + listW - 5, listY, 5, trackSize, tocolor(40, 40, 40, 125))
		dxDrawRectangle(listX + listW - 5, listY + listOffset * (trackSize / lightbarNum), 5, trackSize / lightbarNum * maxRows, tocolor(80, 200, 120))
	end

	if activeItem then
		dxDrawImage(imageX, imageY, imageS, imageS, "files/" .. availableLightbars[activeItem] .. ".png")
	end

	dxDrawButton("button:exit", panelX + panelW - 120 - 10, panelY + panelH - 30 - 10, 120, 30, "Exit")
	dxDrawButton("button:select", panelX + 10, panelY + panelH - 30 - 10, 120, 30, createdLightbars[getPedOccupiedVehicle(localPlayer)] and "Remove" or "Select")

	dxDrawText("Created by Hexon\n(www.facebook.com/hexondev)", panelX, panelY, panelX + panelW, panelY + panelH - 5, tocolor(240, 240, 240), 0.6, Roboto, "center", "bottom")

	activeButton = false

	if isCursorShowing() then
		for k, v in pairs(buttons) do
			if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	end
end

function panelClickHandler(button, state)
	if activeButton then
		if state == "down" then
			if button == "left" then
				local data = split(activeButton, ":")

				if data[2] then
					if data[1] == "button" then
						if data[2] == "exit" then
							togglePanel(false)
						elseif data[2] == "select" then
							if createdLightbars[getPedOccupiedVehicle(localPlayer)] then
								triggerServerEvent("detachLightbarS", getPedOccupiedVehicle(localPlayer))
							else
								togglePanel(false)
								toggleEditor(true, availableLightbars[activeItem])
							end
						end
					elseif data[1] == "item" then
						activeItem = tonumber(data[2])
					end
				end
			end
		end
	end
end

function panelKeyHandler(button, press)
	if button == "mouse_wheel_up" and press then
		if listOffset > 0 then
			listOffset = listOffset - 1
		end
	elseif button == "mouse_wheel_down" and press then
		if listOffset < #availableLightbars - maxRows then
			listOffset = listOffset + 1
		end
	end
end

function dxDrawButton(id, x, y, w, h, text)
	dxDrawRectangle(x, y, w, h, tocolor(60, 60, 60, 230))

	local color = activeButton == id and tocolor(80, 200, 120, 230) or tocolor(150, 150, 150, 230)

	dxDrawRectangle(x, y, w, 1, color) -- top
	dxDrawRectangle(x, y + h - 1, w, 1, color) -- bottom
	dxDrawRectangle(x, y, 1, h, color) -- left
	dxDrawRectangle(x + w, y, 1, h, color) -- right

	dxDrawText(text, x, y, x + w, y + h, tocolor(230, 230, 230), 0.75, Roboto, "center", "center")

	buttons[id] = {x, y, w, h}
end

addEvent("receiveAttachedLightbarsC", true)
addEventHandler("receiveAttachedLightbarsC", root, function(data)
	for k, v in pairs(data) do
		local model, x, y, z, rx, ry, rz = unpack(v)

		createdLightbars[k] = createObject(model, 0, 0, 0)
		setElementCollisionsEnabled(createdLightbars[k], false)

		attachElements(createdLightbars[k], k, x, y, z, rx, ry, rz)
	end
end)

addEvent("attachLightbarC", true)
addEventHandler("attachLightbarC", root, function(lightbarData)
	local model, x, y, z, rx, ry, rz = unpack(lightbarData)

	createdLightbars[source] = createObject(model, 0, 0, 0)
	setElementCollisionsEnabled(createdLightbars[source], false)

	attachElements(createdLightbars[source], source, x, y, z, rx, ry, rz)
end)

addEvent("detachLightbarC", true)
addEventHandler("detachLightbarC", root, function()
	if createdLightbars[source] then
		destroyElement(createdLightbars[source])
		createdLightbars[source] = nil
	end
end)

addEventHandler("onClientElementDestroy", root, function()
	if getElementType(source) == "vehicle" then
		if createdLightbars[source] then
			destroyElement(createdLightbars[source])
			createdLightbars[source] = nil
		end
	end
end)