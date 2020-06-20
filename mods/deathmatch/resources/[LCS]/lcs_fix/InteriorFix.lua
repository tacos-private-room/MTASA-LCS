function clientRender()
    local x,y,z = getElementPosition(localPlayer)

    local hit,x,y,z,hitele = processLineOfSight(x,y,z+5,x,y,z-5,true,false,false)
    --修正LCS存档屋1碰撞实体BUG
    if count(getElementID(hitele),'TonisAptInterior1')  and getElementInterior (localPlayer ) == 1 then
        setElementCollisionsEnabled( getElementByID("ind_land097"),false)
    else
        setElementCollisionsEnabled( getElementByID("ind_land097"),true)
    end

    if count(getElementID(hitele),'izzy_mariaaptint')  and getElementInterior (localPlayer ) == 2 then
        setElementCollisionsEnabled( getElementByID("ind_mainten3"),false)
    else
        setElementCollisionsEnabled( getElementByID("ind_mainten3"),true)
    end

    if count(getElementID(hitele),'iz_shrsdplcrm')  and getElementInterior (localPlayer ) == 2 then
        setElementCollisionsEnabled( getElementByID("police_station_sub"),false)
    else
        setElementCollisionsEnabled( getElementByID("police_station_sub"),true)
    end

    if count(getElementID(hitele),'izzy_churchint')  and getElementInterior (localPlayer ) == 2 then
        setElementCollisionsEnabled( getElementByID("clnm_cthdrlfcde"),false)
    else
        setElementCollisionsEnabled( getElementByID("clnm_cthdrlfcde"),true)
    end


    -- fix collision
    if count(getElementID(hitele),'jm_sawmill_inside')  and getElementInterior (localPlayer ) == 3 then
        setElementCollisionsEnabled( getElementByID("jm_sawmill_inside"),true)
    else
        setElementCollisionsEnabled( getElementByID("jm_sawmill_inside"),false)
    end
    if count(getElementID(hitele),'bigship_hold')  and getElementInterior (localPlayer ) == 2 then
        setElementCollisionsEnabled( getElementByID("bigship_hold"),true)
    else
        setElementCollisionsEnabled( getElementByID("bigship_hold"),false)
    end
    if getElementInterior (localPlayer ) == 2 then
        setElementCollisionsEnabled( getElementByID("donlove_building"),true)
    else
        setElementCollisionsEnabled( getElementByID("donlove_building"),false)
    end


end


--[[
function onClientColShapeHit( theElement, matchingDimension )
    if ( theElement == localPlayer ) then  -- Checks whether the entering element is the local player
        outputChatBox( "In." )  --Outputs.
    end
end
--]]
addEventHandler("onClientColShapeHit", root, clientRender)
-- Fix light
for iA,vA in pairs(getElementsByType('object')) do
    if getElementType( vA ) == "object" then
        if getElementID(vA) == "doublestreetlght1" then
            local x,y,z = getElementPosition(vA)
            setElementPosition(vA,x,y,z+4)
        end
    end
end