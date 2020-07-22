
setHeatHaze ( 0 )
function system_initPlayerVars()
    -- spawn player
    --spawnPlayer(source,1722.1062,1508.2020,10.8128)
    --spawnPlayer(source,714.0,241.0,4.0)
    --spawnPlayer(source,-744.14739990234,-582.71356201172,8.8197898864746)
    -- Time
    setElementData ( source, "time", 10)
    setElementData ( source, "wea", 0)
    --[[
    -- camera
    fadeCamera(source,true)
    setCameraTarget(source ,source )

    setOcclusionsEnabled(true )

    exports.lcs_ui:showTextBox(source,"Welcome to Liberty City Stories Freeroam!",3000)
    setTimer ( function(source)
        exports.lcs_ui:showTextBox(source,"We Wish you have a good time play around in here.",3000)
    end, 4000, 1,source )

    setTimer ( function(source)
        exports.lcs_ui:showTextBox(source,"Greeting from developer - Nurupo",3000)
    end, 8000, 1,source )
    --]]

end
function kill(source)
    setElementHealth(source,0)
    outputChatBox("[S]: HP Set 0",source)
end
addCommandHandler("kill",kill)


function god(source)
    local godmode = getElementData(source,"god") or false
    godmode = not godmode

    setElementData(source,"god",godmode)
    if godmode then
        outputChatBox("[S]: Godmode on",source)
        setElementHealth(source,1000)
        triggerClientEvent ( source, "client_godemodeOn", source)
        exports.lcs_ui:showTextBox(source,"Cheat activated")
    else
        outputChatBox("[系统]: Godemod off",source)
        setElementHealth(source,100)
        triggerClientEvent ( source, "client_godemodeOff", source)
        exports.lcs_ui:showTextBox(source,"Cheat deactivated")
    end
end
addCommandHandler("god",god)
addCommandHandler("wudi",god)

function hp(source,cmd,hp)
    if not hp then outputChatBox("[用法]: /hp [血量]",source) return end
    setElementHealth(source,hp)
    outputChatBox("[系统]: 设置血量->"..hp,source)
end
addCommandHandler("hp",hp)

function am(source,cmd,am)
    if not am then outputChatBox("[用法]: /am [护甲]",source) return end
    setPedArmor(source,am)
    outputChatBox("[系统]: 设置护甲->"..hp,source)
end
addCommandHandler("am",am)

function sid(source,cmd,sid)

    setElementModel(source,sid)
    outputChatBox("[模型]: 切换模型->"..sid,source)
end
addCommandHandler("sid",sid)
addEventHandler('onPlayerJoin',root,system_initPlayerVars)
