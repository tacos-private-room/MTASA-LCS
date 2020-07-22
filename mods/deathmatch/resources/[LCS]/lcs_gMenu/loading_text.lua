DGS = exports.dgs

interval = 1000
step = 0
animationTimer = nil
label = nil


function showLoadingLabel() 
    if label == nil then
        label = DGS:dgsCreateLabel(-0.02,0.02,1,1,"LOADING...",true)
        DGS:dgsSetProperty(label,"alignment",{"right","top"})
        DGS:dgsSetProperty(label,"font","bankgothic")
        DGS:dgsSetProperty(label,"textSize",{0.9,1.5})
        DGS:dgsSetProperty(label,"shadow",{2,2,tocolor(0,0,0,255),1})
        DGS:dgsSetAlpha(label,0)
    end
    animationTimer = setTimer(function()
        if step == 0 then
            DGS:dgsSetAlpha(label,0)
            DGS:dgsAlphaTo(label,1,false,"OutQuad",interval) 
            step = 1
        elseif step == 1 then 
            DGS:dgsSetAlpha(label,1)
            DGS:dgsAlphaTo(label,0,false,"OutQuad",interval) 
            step = 0
        end
    end,interval,0)
end


function hideLoadingLabel() 
    if not animationTimer == nil then 
        killTimer(animationTimer)    
    end
    destroyElement(label)
end
