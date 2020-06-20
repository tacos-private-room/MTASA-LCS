

function godmode()
	local playerid = getLocalPlayer()
	local godemode = getElementData(playerid,"god") or false
	if godemode then
		cancelEvent()
	end
end

function vehGodemode()
	local playerid = getLocalPlayer()
	if isPedInVehicle(playerid) then
		local vPtr = getPedOccupiedVehicle(playerid)
		if vPtr == source then
			fixVehicle(vPtr)
		end
	end
end

function client_godemodeOn()
	addEventHandler ( "onClientPlayerDamage", getRootElement(), godmode )
	addEventHandler ( "onClientPlayerStealthKill", getRootElement(), godmode )
	--addEventHandler ( "onClientPedDamage", getRootElement(), godmode )
	addEventHandler ( "onClientVehicleDamage", getRootElement(), vehGodemode )
end
addEvent( "client_godemodeOn", true )
addEventHandler( "client_godemodeOn", localPlayer, client_godemodeOn )

function client_godemodeOff()
	removeEventHandler ( "onClientPlayerDamage", getRootElement(), godmode )
	removeEventHandler ( "onClientPlayerStealthKill", getRootElement(), godmode )
	--addEventHandler ( "onClientPedDamage", getRootElement(), godmode )
	removeEventHandler ( "onClientVehicleDamage", getRootElement(), vehGodemode )
end
addEvent( "client_godemodeOff", true )
addEventHandler( "client_godemodeOff", localPlayer, client_godemodeOff )
function ghostmode_on()
	local playerVehicle = getPedOccupiedVehicle(localPlayer) -- Get the players vehicle
	if(playerVehicle) then -- Check the return value.
		for i,v in pairs(getElementsByType("vehicle")) do --LOOP through all vehicles
			setElementCollidableWith(v, playerVehicle, false) -- Set the collison off with the other vehicles.
		end
		outputChatBox("[状态]: 被动模式开启")
	end
end
addCommandHandler("ghost", ghostmode_on) -- Add the /ghostmode Command.





