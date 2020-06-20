function setRain(player,cmd,level)
    setRainLevel(level)
end
addCommandHandler('rain',setRain,false,false)

function setPos(player,cmd,x,y,z)
    setElementPosition ( player, x, y, z )
end
addCommandHandler('pos',setPos,false,false)


function sound(source,cmd,val)
    playSoundFrontEnd ( source, val )
end
addCommandHandler("sound",sound)
function interior(source,cmd,int)
    setElementInterior(source,int)
    local notifyMessage = string.format("[系统]: 室内空间-> %d!", int)
    -- output the message
    outputChatBox ( notifyMessage,source )
end
addCommandHandler("int",interior)

function sub(source,cmd,text,time)
    triggerClientEvent ( source, "showPlayerSubtitle", source, text,time)
end
addCommandHandler("sub",sub)


function commandSetSunSize(player, command, size)
    local size = tonumber(size)
    if (not size) then return end -- They didn't use a number
    setSunSize(size)
end
addCommandHandler("sun", commandSetSunSize)

function enableFreecam (player)
    if (not exports.freecam:isPlayerFreecamEnabled (player)) then
        local x, y, z = getElementPosition (plaayer)
        exports.freecam:setPlayerFreecamEnabled (player, x, y, z)
    else
        exports.freecam:setPlayerFreecamDisabled (player)
        setCameraTarget(player ,player )
    end
end
addCommandHandler ('freecam', enableFreecam)