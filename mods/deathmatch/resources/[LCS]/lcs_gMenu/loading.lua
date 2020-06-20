
isPlay = false
function downloadGUI()
    if not isPlay then
        bgm = playSound("lcs_theme.mp3",true)
        isPlay = true
    end
    local x,y = guiGetScreenSize ()
    dxDrawImage ( 0, 0, x, y, "loadsc0.png")
end
addEventHandler("onClientRender", root, downloadGUI)

function checkTransfer()
    if isTransferBoxActive() then
        --[[
        DGS = exports.dgs
        local aX, aY, aW, aH = convertFitRatio(100, 790, 440, 30)
        progressbar = DGS:dgsCreateProgressBar(aX, aY, aW, aH, false,nil,nil,tocolor(0, 0, 0, 150),nil,tocolor(142, 0, 0, 255))
        number = 0
        setTimer(function ()
            number = number + 1
            DGS:dgsProgressBarSetProgress(progressbar,number)
            if number == 100 then
                number = 0
            end
        end,3000,0)
        --]]
        setElementFrozen ( getLocalPlayer(), true )
        setTimer(checkTransfer,2000,1) -- Check again after 2 seconds
    else
        if bgm then stopSound(bgm) end
        --destroyElement (progressbar )
        removeEventHandler("onClientRender", root, downloadGUI)
        setElementFrozen ( getLocalPlayer(), false )
    end

end
addEventHandler("onClientResourceStart",resourceRoot,checkTransfer)


function convertFitRatio(gX, gY, gW, gH)
    local myX, myY = 1600, 900 -- The resolution you've used for making the guis
    local sX, sY = guiGetScreenSize() -- The resolution of the player
    local rX = gX / myX -- (0.3906) We obtain the relative position, for making it equal in all screen resolutions
    local rY = gY / myY -- (0.4883)
    local rW = gW / myX -- (0.1953)
    local rH = gH / myY -- (0.0488)

    local aX = sX * rX -- Now we multiply the relative position obtained previously by the client resolution for having an absolute position from the client screen
    local aY = sY * rY
    local aW = sX * rW
    local aH = sY * rH
    return aX, aY, aW, aH
end
