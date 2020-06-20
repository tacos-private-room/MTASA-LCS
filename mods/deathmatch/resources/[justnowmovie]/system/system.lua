function displayLoadedRes ( res )
    outputChatBox ( "Resource " .. getResourceName(res) .. " loaded", getRootElement(), 255, 255, 255 )
end
addEventHandler ( "onResourceStart", getRootElement(), displayLoadedRes )