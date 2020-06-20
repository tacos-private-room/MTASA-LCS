function setWea(player,cmd,wea)
    --setWeather( wea)
    setElementData ( player, "wea", wea)
end
addCommandHandler('wea',setWea,false,false)

function setTimeAndNotify(player,cmd, hour, minute )
    minute = minute or 0
    -- set the time first
    -- setTime ( hour, minute )
    setElementData ( player, "time", hour)
    -- format a notification message, adding leading zeros (e.g. 12:03 instead of 12:3)
    local notifyMessage = string.format("[System]: Time-> %02d:%02d!", hour, minute)
    -- output the message
    outputChatBox ( notifyMessage,player )
end
addCommandHandler('t',setTimeAndNotify,false,false)

function wid (player,cmd,wid)
    wid = wid or outputChatBox ("[用法]: /wid (频道ID)",player)
    setElementDimension(player,wid)
    outputChatBox ("[频道]: 切换到->"..wid,player)
end
addCommandHandler('wid',wid,false,false)
function wn (player,cmd,wid)
    setElementDimension(player,0)
    outputChatBox ("[频道]: 回到默认频道了(大世界)",player)
end
addCommandHandler('wn',wn,false,false)