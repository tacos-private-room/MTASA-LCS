--[[
    Author: Exile
    Description: Draws wingtip vortices for hydra activiated by command '/vortices'
    NOTE: May cause FPS drop on low performance PCs
]]

-- SETTINGS
local max_points = 100  -- Maximmum number of points (3D) to draw
local rotSpeedUpdateInterval = 400 -- delay in milliseconds before calculating the new rotational speed (angular velocity)
local deletePointInteveral = 50 -- delay in milliseconds before deleting another point

--[[
    Globals
]]
local points = {{}, {}}
local curRotSpeed = 0	 	-- Current angular velocity
local prevRot = {0, 0, 0}	-- Rotation last tick
local prevRotSpeed = 0		-- Angular velocity last tick
local prevTick = 0			-- Tick last update
local prevDelTick = 0		-- Tick last delete

--[[ Get the speed ]]
function rotSpeed(x1, y1, z1, x2, y2, z2)
    return ((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)^ (1/2)
end

--[[ Draw points ]]
function drawPoints(red, green, blue,alpha)
    assert(red and green and blue and alpha, "Not enough arguments")
    for i, v in ipairs(points) do
        if #v >= 2 then
            for j = 2, #v do
                local sx, sy, sz = unpack(v[j-1])
                local ex, ey, ez = unpack(v[j])
                local distance = getDistanceBetweenPoints3D(sx, sy, sz, ex, ey, ez)
                if distance <= 10 then
                    if sx and sy and sz and ex and ey and ez then
                        dxDrawLine3D(sx, sy, sz, ex, ey, ez, tocolor(red, green, blue, alpha), math.max(10, (#v - j)))
                    end
                end
            end
        end
    end
end

--[[ Delete a point ]]
function delPoint()
    table.remove(points[1], 1)
    table.remove(points[2], 1)
end

--[[ Add a point ]]
function addPoint()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle or not getElementModel(vehicle) == 520 then return false end
    local offset = hydra_wing_offset
    local x1, y1, z1 = getPositionFromElementOffset(vehicle, offset, -0.1, 0)
    local x2, y2, z2 = getPositionFromElementOffset(vehicle, -(offset), -0.1, 0)
    local left = #points[1]

    points[1][left + 1] = {x1, y1, z1}
    points[2][left + 1] = {x2, y2, z2}

	if left > max_points then
		delPoint()
	end
end

local prevVehicle = nil

--[[ Update angular velocity, draw points and delete them ]]
function drawVortices()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    outputChatBox((vehicle) and getElementModel(vehicle) or false)
    if not vehicle or getElementModel(vehicle) ~= 520 then stopVortices() return end

    local vpx, vpy, vpz = getElementPosition(vehicle)
    local speed = 0
    local currTick = getTickCount()
    local elapsedTime = currTick - prevTick

    if currTick - prevDelTick >= (deletePointInteveral) then
        delPoint()
        prevDelTick = currTick
    end

    if elapsedTime >= rotSpeedUpdateInterval then
        -- Process
        local rx1, ry1, rz1 = getElementRotation(vehicle)
        speed = getElementSpeed(vehicle, "km/h")
        -- Eliminate error => 360 is the same as 0
        rx1 = math.ceil((rx1 >= 360 and 0 or rx1))
        ry1 = math.ceil((ry1 >= 360 and 0 or ry1))
        rz1 = math.ceil((rz1 >= 360 and 0 or rz1))
        local rx2, ry2, rz2 = unpack(prevRot)
        local rSpeed = rotSpeed(rx1, ry1, rz1, rx2, ry2, rz2)
        -- HACK: Sometimes it will show angular velocity = 350 or 270 this is a false reading ofc.
        -- so 360 - rSpeed will sort it.
        rSpeed = math.abs((rSpeed >= 180 and 360 - rSpeed or rSpeed))
        -- Update
        curRotSpeed = rSpeed
        prevRot = {rx1, ry1, rz1}
        prevRotSpeed = rSpeed
        prevTick = currTick
    end

    if speed >= 250 or curRotSpeed >= 25 then
        addPoint()
    end

    drawPoints(255, 255, 255, 50)
end

--[[ When player exits hydra stop drawing vortices ]]
function stopVortices()
    points = {{}, {}}
    removeEventHandler("onClientRender", getRootElement(), drawVortices)
end

--[[ When player enters hydra start drawing vortices ]]
function startVortices()
    addEventHandler("onClientRender", getRootElement(), drawVortices)
end

--[[ When /vortices is typed start or stop the drawing ]]
local vorticesOn = false
function toggleVortices(veh)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle or getElementModel(vehicle) ~= 520 then vorticesOn = false return false end

    if vorticesOn then stopVortices() else startVortices() end
    vorticesOn = not vorticesOn
    outputChatBox("* Hydra vortices are now "..(vorticesOn and "on" or "off")..".", 255, 0, 0)
end
addCommandHandler("vortices", toggleVortices)
