--[[ Util function from mtasa wiki ]]
function getPositionFromElementOffset(element, offX, offY, offZ)
    local m = getElementMatrix ( element ) -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1] -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z -- Return the transformed point
end


function getNearbyVehicles(distance)
    local px, py, pz = getElementPosition(localPlayer)
    local vehicles = getElementsByType("vehicle")
    local hydras = {}
    for _, vehicle in ipairs(vehicles) do
        if getElementModel(vehicle) == 520 then
            local x, y, z = getElementPosition(vehicle)
            if getDistanceBetweenPoints3D(px, py, pz, x, y, z) <= distance then
                hydras[#hydras + 1] = vehicle
            end
        end
    end
    return hydras
end

function getNearbyProjectiles(distance)
    local px, py, pz = getElementPosition(localPlayer)
    local projectiles = getElementsByType("projectile")
    local projs = {}
    for i, v in ipairs(projectiles) do
        local type = getProjectileType(v)
        if type == 19 or type == 20 or type == 53 then
            local x, y, z = getElementPosition(v)
            if getDistanceBetweenPoints3D(px, py, pz, x, y, z) <= distance then
                projs[#projs + 1] = v
            end
        end
    end
    return projs
end

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function map(func, array)
    local new_array = {}
    for i, v in ipairs(array) do
        new_array[i] = func(v)
    end
    return new_array
end
