function kickPlayerHandler ( sourcePlayer)
	kickPlayer ( sourcePlayer, "Exit Game" )
end
addEvent( "server_kickPlayer", true )
addEventHandler( "server_kickPlayer", resourceRoot, kickPlayerHandler ) -- Bound to this resource only, saves on CPU usage.
