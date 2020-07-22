setPlayerHudComponentVisible ("area_name", false )
setPlayerHudComponentVisible ("vehicle_name", false )

function calcWrapLines(str)
    local idx = 0
    local words = 0
    for c in string.gmatch(str, ".") do
        words = words +1

        if words >= 27 or  c == '\n' then
            idx = idx +1
            words = 0
        end
    end
    return idx
end
isTextBoxShow = false
message = ""
timerPtr = nil
function showTextBox(msg,time)
    message = msg
    time = time or 3000
    isTextBoxShow = true
    playSound("blip.wav")
    if not timerPtr == nil then
        killTimer(timerPtr)
        timerPtr = nil
    end
    timerPtr = setTimer (function()
        isTextBoxShow = false

    end, time, 1)
end

addEvent( "showClientTextBox", true )
addEventHandler( "showClientTextBox", localPlayer, showTextBox )


addEventHandler("onClientRender", root,
    function()
        if isTextBoxShow then
            local lines = calcWrapLines(message) + 1
            local height = dxGetFontHeight ( 1.7, "sans")
            startx = 178
            dxDrawRectangle(10, startx, 314, height * lines + 20 , tocolor(0, 0, 0, 180), false)
            dxDrawText(message, 19, 188, 314, 283, tocolor(255, 255, 255, 255), 1.7, "sans", "left", "top", false, true, false, false, false)
        end
    end
)

