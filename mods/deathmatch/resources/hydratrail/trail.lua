--[[
	Author: Exile
	Description: This script draws each hydra's wingtip/projectile trail
    NOTE: May cause FPS drop on low performance PCs
--]]

--[[
	OPTIONS - tweak if necessary
--]]
local MAX_POINT_LIST = 200	-- Length of the trail in (3D) points
local MAX_PROJECTILE_LIST = 200	-- Length of projectile trail in (3D) points
local MAX_RENDER_DIST = 300		-- Maximmum distance before drawing of trail stops
local PROJECTILE_TRAIL = {red = 253, green = 106, blue = 2, alpha = 200, thickness = 1} -- RGBA and thickness
local HYDRA_TRAIL = {red = 0, green = 0, blue = 255, alpha = 200, thickness = 1}

local HYDRA_POINT_LIST = {{}, {}}	-- A list of points (3D)
local HYDRA_PROJECTILE_POINT_LIST = {}	-- A list of projectile points (3D)
local nearbyVehicles = {}	-- Nearby vehicles
local projects = {}

--[[ Draw every point in the left and right side ]]
function drawHydraTrail(red, green, blue, alpha, width)
    local x, y, z = getElementPosition(localPlayer)

    for hydra, points in pairs(HYDRA_POINT_LIST) do
        if hydra then
	        Async:foreach(points,
	            function(v)

		            if #v >= 2 then
		    	        for j = 2, #v do
		    		        local sx, sy, sz = unpack(v[j-1])
                            local distance = getDistanceBetweenPoints3D(x, y, z, sx, sy, sz)
                            if distance < MAX_RENDER_DIST then
		    		            local ex, ey, ez = unpack(v[j])
		    		            dxDrawLine3D(sx, sy, sz, ex, ey, ez, tocolor(red, green, blue, alpha), width)
                            end
		    	        end
		            end
	            end
	        )
        end
    end
end

-- --[[ Draw every point in the projectile trail ]]
function drawProjectileTrail(red, green, blue, alpha, width)
    local x, y, z = getElementPosition(localPlayer)

    for proj, points in pairs(HYDRA_PROJECTILE_POINT_LIST) do
        if proj then
            Async:foreach(points,
                function(v)
                    if #v >= 2 then
                        for j = 2, #v do
                            local sx, sy, sz = unpack(v[j-1])
                            local distance = getDistanceBetweenPoints3D(x, y, z, sx, sy, sz)
                            if distance < MAX_RENDER_DIST then
                                local ex, ey, ez = unpack(v[j])
                                dxDrawLine3D(sx, sy, sz, ex, ey, ez, tocolor(red, green, blue, alpha), width)
                            end
                        end
                    end
                end
            )
        end
    end
end

--[[ Get a list of points from vehicle ]]
function getVehiclePoints(vehicle)
    local leftTable = false
    local rightTable = false
    for hydra, v in pairs(HYDRA_POINT_LIST) do
        if not isElement(hydra) or isVehicleBlown(hydra) then
            HYDRA_POINT_LIST[hydra] = nil
        end

        --[[ If it's not nearby then delete it. ]]
        local found = false
        for _, veh in ipairs(nearbyVehicles) do
            if hydra == veh then
                found = true
            end
        end

        if not found then
            HYDRA_POINT_LIST[hydra] = nil
        end

        if hydra == vehicle then
            leftTable = v[1]
            rightTable = v[2]
        end
    end

    return leftTable, rightTable
end

-- Delete the first point from both left and right side lists
function delVehiclePoint(vehicle)
    if not vehicle then return end

    local leftTable, rightTable = getVehiclePoints(vehicle)
    if leftTable and rightTable then
        table.remove(leftTable, 1)
        table.remove(rightTable, 1)
    end
end

-- Add vehicle points
function addVehiclePoint(vehicle)
    if not vehicle or not isElement(vehicle) then return false end
    local leftTable, rightTable = getVehiclePoints(vehicle)

    -- Create both left and right tables if they don't exist.
    if not leftTable or not rightTable then
        local newIndex = #HYDRA_POINT_LIST + 1
        HYDRA_POINT_LIST[vehicle] = {{}, {}}
        leftTable = HYDRA_POINT_LIST[vehicle][1]
        rightTable = HYDRA_POINT_LIST[vehicle][2]
    end

    -- Get the hydra wing offset
    local offset = hydra_wing_offset

    -- Add the new point to the list
    local leftLength = #leftTable
    local x1, y1, z1 = getPositionFromElementOffset(vehicle, offset, 0, 0)
    local x2, y2, z2 = getPositionFromElementOffset(vehicle, -offset, 0, 0)
    leftTable[leftLength + 1] = {x1, y1, z1}
    rightTable[leftLength + 1] = {x2, y2, z2}

    -- Don't exceed the maximum number of (3D) points
	if leftLength + 1 > MAX_POINT_LIST then
		table.remove(leftTable, 1)
	end

	if leftLength + 1 > MAX_POINT_LIST then
		table.remove(rightTable, 1)
	end
end

-- Get list of points from projectile
function getProjectilePoints(projectile)
    local points = false
    for proj, v in pairs(HYDRA_PROJECTILE_POINT_LIST) do
        -- If it's not nearby delete it
        local projFound = false
        for _, veh in ipairs(projects) do
            if proj == veh then
                projFound = true
            end
        end

        if not projFound then
            HYDRA_PROJECTILE_POINT_LIST[proj] = nil
        end

        if proj == projectile then
            points = v
        end
    end
    return points
end

-- Delete dead/exploded missile trails
function clearDeadProjectiles()
    for proj, v in pairs(HYDRA_PROJECTILE_POINT_LIST) do
        if not isElement(proj) or getProjectileCounter(proj) <= 0 then
            HYDRA_PROJECTILE_POINT_LIST[proj] = nil
        end
    end
end

-- Delete trailing points
function delProjectilePoint(projectile)
    local t = getProjectilePoints(projectile)
    if t then table.remove(t, 1) else clearDeadProjectiles() end
end

-- Add the new projectile point
function addProjectilePoint(projectile)
    if not projectile or not isElement(projectile) then return end
	local x, y, z = getElementPosition(projectile)
    local points = getProjectilePoints(projectile)
    if not points then
        HYDRA_PROJECTILE_POINT_LIST[projectile] = {}
        points = HYDRA_PROJECTILE_POINT_LIST[projectile]
    end

	points[#points + 1] = {x, y, z}
    if #points + 1 > MAX_PROJECTILE_LIST then
        delProjectilePoint(projectile)
    end
end

--[[
    Drawing settings
]]
local trailOn = false  -- should we draw the hydra trail?
local getPoints = 0    -- Delay in ms for adding new points
local deletePoints = 30   -- Delay in ms for deleting points
local prevTick = 0         -- ms since new points were last added
local delPrevTick = 0       -- ms since last delated

-- Draw hydra trail
function drawTrails()
	local tick = getTickCount()
	-- Delete the points
    if (tick - delPrevTick) > deletePoints then
        Async:foreach(nearbyVehicles,
            function (v)
                delVehiclePoint(v)
            end
        )

        -- Async:foreach(projects,
        --     function (v)
        --         delProjectilePoint(v)
        --     end
        -- )
        delPrevTick = tick
    end

	-- Add the points
    if (tick - prevTick) > getPoints then
		Async:foreach(nearbyVehicles,
            function (v)
                addVehiclePoint(v)
            end
        )
        -- Async:foreach(projects,
        --     function (v)
        --         addProjectilePoint(v)
        --     end
        -- )
        prevTick = tick
	end
    drawHydraTrail(HYDRA_TRAIL.red, HYDRA_TRAIL.green, HYDRA_TRAIL.blue, HYDRA_TRAIL.alpha, HYDRA_TRAIL.thickness)
    --drawProjectileTrail(PROJECTILE_TRAIL.red, PROJECTILE_TRAIL.green, PROJECTILE_TRAIL.blue, PROJECTILE_TRAIL.alpha, PROJECTILE_TRAIL.thickness)
end

-- Toggle the hydra trail by command
function toggleHydraTrail()
    trailOn = not trailOn
    if not trailOn then
        HYDRA_POINT_LIST = {{}, {}}
        HYDRA_PROJECTILE_POINT_LIST = {}
        nearbyVehicles = {}
        projects = {}
        removeEventHandler("onClientRender", getRootElement(), drawTrails)
    else
        nearbyVehicles = map(function(vehicle) return getElementModel(vehicle) == 520 and vehicle end, getElementsByType("vehicle"))
        addEventHandler("onClientRender", getRootElement(), drawTrails)
    end
    outputChatBox("* Hydra trail is now "..(trailOn and "on" or "off")..".", 255, 0, 0)
end

--[[
    Events and handlers
]]
-- Add the projectile to the list when created
addEventHandler("onClientProjectileCreation", getRootElement(),
    function ()
        if not trailOn then return false end
        for _, v in ipairs(projects) do
            if v == source then
                return false
            end
        end

        projects[#projects + 1] = source
    end
)

-- Add the hydra to the list when streamed in
addEventHandler( "onClientElementStreamIn", getRootElement( ),
    function ( )
        if getElementType( source ) == "vehicle" and getElementModel(source) == 520 then
            for _, veh in ipairs(nearbyVehicles) do
                if source == veh then
                    return false
                end
            end

            nearbyVehicles[#nearbyVehicles + 1] = source
        end
    end
);

-- remove the hydra from the list when streamed out
addEventHandler( "onClientElementStreamOut", getRootElement(),
    function ()
        if getElementType( source ) == "vehicle" and getElementModel(source) == 520 then
            for i, veh in ipairs(nearbyVehicles) do
                if source == veh then
                    table.remove(nearbyVehicles, i)
                end
            end
        end
    end
)

-- Remove recently destroyed projectiles (not 100% sure this triggers)
addEventHandler("onClientElementDestroy", getRootElement(),
    function ()
        if trailOn and getElementType(source) == "projectile" then
            clearDeadProjectiles()
        end
    end
)

addCommandHandler("hydratrail", toggleHydraTrail)
