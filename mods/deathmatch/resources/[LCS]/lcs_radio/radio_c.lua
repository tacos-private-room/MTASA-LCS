
select_radio = 0
MAX_RADIO_ID = 9
radioStations = {
    {"DOUBLE CLEF FM","src/DOUBLE.mp3",0},
    {"FLASHBACK FM","src/FLASH.mp3",0},
    {"HEAD RADIO","src/HEAD.mp3",0},
    {"K-JAH","src/KJAH.mp3",0},
    {"LCFR","src/LCFR.mp3",0},
    {"THE LIBERTY JAM","src/LCJ.mp3",0},
    {"LIPS 106","src/LIPS.mp3",0},
    {"MSX 98","src/MSX.mp3",0},
    {"RADIO DEL MUNDO","src/MUNDO.mp3",0},
    --[[
    {"PARADISE FM","src/WILD.mp3",0},
    {"WAVE 103","src/WAVE.mp3",0},
    {"V-ROCK","src/VROCK.mp3",0},
    {"VICE CITY PUBLIC RADIO","src/VCPR.mp3",0},
    {"VICE CITY FOR LOVERS","src/KCHAT.mp3",0},
    {"FLASH FM","src/FLASH_VCS.mp3",0},
    {"FRESH FM","src/FEVER.mp3",0},
    {"ESPANTOSO","src/ESPANT.mp3",0},
    {"EMOTION 98.3","src/EMOTION.mp3",0},
    -]]
}
radoPtr = nil
isUIWaitforCancelEvent = false
isInTuningDelay = false
setRadioChannel(0)
setPlayerHudComponentVisible( "radio", false )
currentStation = 0
function switchRadio(newval)
    if not isPedInVehicle(localPlayer) then
        return
    end
    stopRadio()
    select_radio = select_radio + newval
    if select_radio +1 > MAX_RADIO_ID+1 then
        select_radio  = 0
    elseif select_radio -1 < 0 then
        select_radio  = MAX_RADIO_ID
    end


    playSoundFrontEnd (34)
    updateRadioText()

    if not isInTuningDelay then
        isInTuningDelay = true
        setTimer(function()
            playRadio(select_radio)
            isInTuningDelay = false
        end,2000,1)
    end

end
function switchRandomRadio()
    select_radio = math.random(1,table.getn(radioStations))
    playSoundFrontEnd (34)
    updateRadioText()
    stopRadio()
    if not isInTuningDelay then
        isInTuningDelay = true
        setTimer(function()
            playRadio(select_radio)
            isInTuningDelay = false
        end,2000,1)
    end
end
function stopRadio()
    if radoPtr then
        --取得电台播放进度
            local pos = getSoundPosition(radoPtr)
            radioStations[currentStation][3] = pos
        stopSound(radoPtr)
        radoPtr = nil
    end

end
function playRadio(id)
    stopRadio()
    currentStation = id
    playSoundFrontEnd (35)
    --[[
    if not isPedInVehicle(localPlayer) then
        return
    end
    --]]

    local vol = 0.5
    if id == 0 then
        return
    end
    -- 随机播放位置w
    radoPtr = playSound(radioStations[id][2],true)
    local len = getSoundLength(radoPtr)
    local pos = 0
    if radioStations[id][3] == 0 then
        pos = math.random(0,len)
        radioStations[id][3] = pos
    else
        pos = radioStations[id][3]
    end

        setSoundVolume(radoPtr,vol)
        setSoundPosition (radoPtr, pos)
        --outputChatBox("[电台]: 切换->"..radioStations[id][1])
        updateRadioText()
    end

function updateRadioText()
    if not isUIWaitforCancelEvent then
        addEventHandler("onClientRender", getRootElement(), drawRadioText)
        isUIWaitforCancelEvent = true
        setTimer(function()
            removeEventHandler("onClientRender",root,drawRadioText)
            isUIWaitforCancelEvent = false
        end,5000,1)
    end

end
addEventHandler( "onClientKey", root, function(button,press)
    if button == "mouse_wheel_up" and press or button == "r" and press then
        switchRadio(1)
    elseif button == "mouse_wheel_down" and press then
        switchRadio(-1)
    end
end )

local screenW, screenH = guiGetScreenSize()

function drawRadioText()
    local name = ""
    if select_radio == 0 then
        name = "RADIO OFF"
    else
        name = radioStations[select_radio][1]
    end
    dxDrawText(name, (screenW * 0.4006) + 1, (screenH * 0.0420) + 1, (screenW * 0.5994) + 1, (screenH * 0.1113) + 1, tocolor(0, 0, 0, 255), 1.50, "bankgothic", "center", "center", false, false, false, false, false)
    dxDrawText(name, screenW * 0.4006, screenH * 0.0420, screenW * 0.5994, screenH * 0.1113, tocolor(206, 238, 245, 255), 1.50, "bankgothic", "center", "center", false, false, false, false, false)
end


addEventHandler("onClientVehicleStartEnter", getRootElement(), function(thePlayer)
    if thePlayer == localPlayer then
        setRadioChannel(0)
    end

end)
addEventHandler("onClientVehicleEnter", getRootElement(), function(thePlayer)
    if thePlayer == localPlayer then
        switchRandomRadio()
    end
end)

addEventHandler("onClientVehicleExit", getRootElement(), function(thePlayer,seat)
    if thePlayer == localPlayer then
        stopRadio()
    end
end)

function radio_onExitVehicle()
    stopRadio()
end
addEvent( "radio_onExitVehicle", true )
addEventHandler( "radio_onExitVehicle", localPlayer, radio_onExitVehicle )
addEventHandler("onClientPlayerRadioSwitch", getRootElement(), function(stationID)
    cancelEvent()
end)