g_Me = getLocalPlayer( )
g_Root = getRootElement( )
g_ResRoot = getResourceRootElement( )

addEventHandler( "onClientResourceStart", g_ResRoot,
	function( )
		bindKey( "vehicle_fire", "both", nosToogle )
	end
)


function nosToogle ( key, keyState )
	local veh = getPedOccupiedVehicle( g_Me )
	if veh and not isEditingPosition then
		if keyState == "up" then

			removeVehicleUpgrade( veh, 1010 )
			setPedControlState( "vehicle_fire", false )
		else
			addVehicleUpgrade( veh, 1010 )
		end
	end
end
