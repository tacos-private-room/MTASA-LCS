function setUpRec ( model, x, y, z, rx, ry, rz, player )
	local veh = createVehicle ( model, x, y, z, rx, ry, rz )
	local ped = createPed ( 255, 0, 0, 0 )
	warpPedIntoVehicle ( ped, veh )
	--warpPedIntoVehicle ( player, veh, 1 ) 
	callClientFunction ( player, "startPlaying", veh )
	addEventHandler ( "onVehicleDamage", veh, function() callClientFunction ( player, "stopPlayback", veh ) end )
end 

function callServerFunction(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do arg[key] = tonumber(value) or value end
    end
    loadstring("return "..funcname)()(unpack(arg))
end
addEvent("onClientCallsServerFunction", true)
addEventHandler("onClientCallsServerFunction", root, callServerFunction)

function callClientFunction(client, funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    triggerClientEvent(client, "onServerCallsClientFunction", root, funcname, unpack(arg or {}))
end

function saveRecord ( msg )
    local fileHandle = fileCreate("rec.txt")             -- attempt to create a new file
    if fileHandle then                                    -- check if the creation succeeded
        fileWrite(fileHandle, msg)     -- write a text line
        fileClose(fileHandle)                             -- close the file once you're done with it

    end
end
addEvent( "saveRecord", true )
addEventHandler( "saveRecord", resourceRoot, saveRecord ) -- Bound to this resource only, saves on CPU usage.