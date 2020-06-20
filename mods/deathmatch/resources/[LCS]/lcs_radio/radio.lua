function exitVehicle (thePlayer)
    triggerClientEvent(thePlayer,"radio_onExitVehicle",thePlayer)
end
addEventHandler ("onVehicleStartExit", getRootElement(), exitVehicle)
function onPlayerWasted ( )
    triggerClientEvent(source,"radio_onExitVehicle",source)
end
addEventHandler ( "onPlayerWasted", getRootElement(), onPlayerWasted)