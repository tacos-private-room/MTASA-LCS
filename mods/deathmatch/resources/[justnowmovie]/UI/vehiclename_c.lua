function carName (thePlayer, seat)
    if thePlayer == getLocalPlayer() then
        local vehicleName = getVehicleName ( source )
        exports.lcs_ui:showBottomRightText(vehicleName,3000)
    end
end
addEventHandler( "onClientVehicleEnter", getRootElement(), carName )