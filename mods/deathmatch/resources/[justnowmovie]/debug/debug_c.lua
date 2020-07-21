--[[
function objdebug(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
    if(clickedElement) then
        --if getElementType(clickedElement) == "Object" then
            local eid = getElementID(clickedElement)
            outputChatBox("[DEBUG]: OBJ->"..eid)

            showCursor ( false )
       -- end
    end
end

addEventHandler ( "onClientClick", getRootElement(), objdebug )

function cursor()
    showCursor ( true )
end
addCommandHandler ( "objdebug", cursor )

function objrot (cmd,rotx,roty,rotz)
    setElementRotation("sawmill",rotx,roty,rotx)
end
addCommandHandler ( "objrot", objrot )
--]]