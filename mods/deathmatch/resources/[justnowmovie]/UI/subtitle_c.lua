
isUIWaitforCancelEvent = false
subtitle = ""

function SAMPColorCodeTable(text)
    local str = text
    str = str:gsub( "~r~", "#7f1a14")
    str = str:gsub( "~g~", "#21411c")
    str = str:gsub( "~b~", "#25285b")
    str = str:gsub( "~w~", "#ffffff")
    str = str:gsub( "~y~", "#d3bc89")
    str = str:gsub( "~p~", "#ff9fd5")
    return str
end
function RemoveSAMPColorCodeTable(text)
    local str = text
    str = str:gsub( "#ff0000", "")
    str = str:gsub( "#21411c", "")
    str = str:gsub( "#25285b", "")
    str = str:gsub( "#ffffff", "")
    str = str:gsub( "#d3bc89", "")
    str = str:gsub( "#ff9fd5", "")
    return str
end
function showPlayerSubtitle(text,time)
    time = time or 1000
    subtitle = SAMPColorCodeTable(text)

    addEventHandler("onClientRender", getRootElement(), drawSubtitle)
    isUIWaitforCancelEvent = true
    setTimer(function()
        removeEventHandler("onClientRender",root,drawSubtitle)
        isUIWaitforCancelEvent = false
    end,time,1)
end

addEvent( "showPlayerSubtitle", true )
addEventHandler( "showPlayerSubtitle", localPlayer, showPlayerSubtitle )

function drawSubtitle()
    dxDrawText(RemoveSAMPColorCodeTable(subtitle), 406 + 1, 744 + 1, 1468 + 1, 893 + 1, tocolor(0, 0, 0, 255), 3.00, "sans", "center", "center", false, true, false, true, false)
    dxDrawText(subtitle, 406, 744, 1468, 893, tocolor(255, 255, 255, 255), 3.00, "sans", "center", "center", false, true, false, true, false)
end