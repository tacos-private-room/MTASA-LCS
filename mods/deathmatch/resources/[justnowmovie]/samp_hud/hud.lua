
function draw()
    dxDrawProgressBar( 10, 10, 200, 200, 50, tocolor( 250, 50, 50, 255), tocolor( 255, 255, 255, 255) )
end
addEventHandler("onClientRender", root, draw)  -- Keep everything visible with onClientRender.
local unlerp = function(from,to,lerp) return (lerp-from)/(to-from) end
function dxDrawProgressBar( startX, startY, width, height, progress, color, backColor )
    local progress = math.max( 0, (math.min( 100, progress) ) )
    local wBar = width*.18
    for i = 0, 4 do
        --back
        local startPos = (wBar*i + (width*.025)*i) + startX
        dxDrawRectangle( startPos, startY, wBar, height, backColor )
        --progress
        local eInterval = (i*20)
        local localProgress = math.min( 1, unlerp( eInterval, eInterval + 20, progress ) )
        if localProgress > 0 then
            dxDrawRectangle( startPos, startY, wBar*localProgress, height, color )
        end
    end
end