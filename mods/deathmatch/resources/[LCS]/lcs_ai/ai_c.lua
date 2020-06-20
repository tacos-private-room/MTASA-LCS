
sensorOffset =2
sensorOffsetZ =0
sensorOffsetY =1
sensorDetectLength =5
speedLimit =10
enableAiDebug = false


status = {"DRIVENORMAL","BACKREVERSE","DIRVESTUCK","WAITOBS"}
aiStatus = "DRIVENORMAL"
aiDriveDecision = "IDLE"

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

function getPointFromDistanceRotation(element, dist, angle)
    local x,y,z = getElementPosition(element)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy,z;
end
function getPointFromDistanceRotationEx(x,y,z, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy,z;
end
function coords2Vector(x1,y1,z1,x2,y2,z2)
    x,y,z = x2-x1,y2-y1,z2-z1
    return x,y,z
end
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
function angleBetween2Vec(v1x,v1y,v1z,v2x,v2y,v2z)
    -- DOT PODUCT : cos(o) = a . b / |a| |b|
    local x = (v1x * v2x) + (v1y * v2y) + (v1z * v2z) -- a . b
    local y = math.sqrt( (v1x*v1x) + (v1y*v1y) + (v1z*v1z))  * math.sqrt( (v2x*v2x) + (v2y*v2y)  + (v2z*v2z))
    if x > 1 then x = 1 end
    if x < -1 then x = 1 end
    if y > 1 then y = 1 end
    if y < -1 then y = 1 end
    x = round(x,2)
    y = round(y,2)
    --print(y)
    return math.acos(  x / y ) * 180 / math.pi
end
function angleBetween2Vec2D(v1x,v1y,v2x,v2y)
    -- DOT PODUCT : cos(o) = a . b / |a| |b|
    local x = (v1x * v2x) + (v1y * v2y)  -- a . b
    local y = math.sqrt( (v1x*v1x) + (v1y*v1y) )  * math.sqrt( (v2x*v2x) + (v2y*v2y) )
    return math.acos(  x / y ) * 180 / math.pi
end
function coordRotZAxes(x,y,angle)
    -- Convert to rad
    local a = math.rad(angle)
    local x2 = x * math.cos(a) - y * math.sin(a)
    local y2 = x * math.sin(a) + y * math.cos(a)
    return x2,y2
end

function isObstcle(a)
    if a < 5 then
        return true
    end
    return false
end

function aiDebug ()
    if isPedInVehicle ( localPlayer ) then

        local vehPtr = getPedOccupiedVehicle(localPlayer)

        local x0, y0, z0, x1, y1, z1 = getElementBoundingBox( vehPtr )
        local vWidth = math.abs(y0 - y1)
        local vHeight = math.abs(x0 -x1)

        local raycast_lx,raycast_ly,raycast_lz = getPositionFromElementOffset(vehPtr,-sensorOffset,vWidth,sensorOffsetZ)
        local raycast_mx,raycast_my,raycast_mz = getPositionFromElementOffset(vehPtr,0,vWidth,sensorOffsetZ)
        local raycast_rx,raycast_ry,raycast_rz = getPositionFromElementOffset(vehPtr,sensorOffset,vWidth,sensorOffsetZ)
        -- Side sensors
        local raycast_slx,raycast_sly,raycast_slz = getPositionFromElementOffset(vehPtr, -vHeight,0,sensorOffsetZ)
        local raycast_srx,raycast_sry,raycast_srz = getPositionFromElementOffset(vehPtr, vHeight,0,sensorOffsetZ)
        -- back sensors
        local raycast_bx,raycast_by,raycast_bz = getPositionFromElementOffset(vehPtr, 0,-(vWidth/2+1),sensorOffsetZ)

        local x,y,z = getElementPosition(vehPtr)

        -- raycasts

        local raycast_l, _, _, _, surface,raycast_lnx,raycast_lny,raycast_lnz = processLineOfSight (x,y,z+sensorOffsetZ,raycast_lx,raycast_ly,raycast_lz,true,true,true,true,false,true,true,false,vehPtr,true)
        local raycast_m, _, _, _, surface,raycast_mnx,raycast_mny,raycast_mnz = processLineOfSight (x,y,z+sensorOffsetZ,raycast_mx,raycast_my,raycast_mz,true,true,true,true,false,true,true,false,vehPtr,true)
        local raycast_r, _, _, _, surface,raycast_rnx,raycast_rny,raycast_rnz = processLineOfSight (x,y,z+sensorOffsetZ,raycast_rx,raycast_ry,raycast_rz,true,true,true,true,false,true,true,false,vehPtr,true)
        local raycast_sl, _, _, _,surface,raycast_slnx,raycast_slny,raycast_slnz = processLineOfSight (x,y,z+sensorOffsetZ,raycast_slx,raycast_sly,raycast_slz,true,true,true,true,false,true,true,false,vehPtr,true)
        local raycast_sr, _, _, _,surface,raycast_srnx,raycast_srny,raycast_srnz = processLineOfSight (x,y,z+sensorOffsetZ,raycast_srx,raycast_sry,raycast_srz,true,true,true,true,false,true,true,false,vehPtr,true)
        local raycast_b , _, _, _,surface,raycast_bnx,raycast_bny,raycast_bnz = processLineOfSight (x,y,z+sensorOffsetZ,raycast_bx,raycast_by,raycast_bz,true,true,true,true,false,true,true,false,vehPtr,true)

        -- calc normal vector
        --local raycast_lnx,raycast_lny,raycast_lnz = coords2Vector(raycast_lnx,raycast_lny,raycast_lnz,0,0,0)

        local angle2Normal = 0

        -- calculate raycast status
        raycast_l = not raycast_l
        raycast_m = not raycast_m
        raycast_r = not raycast_r
        raycast_sl = not raycast_sl
        raycast_sr = not raycast_sr
        raycast_b = not raycast_b

        -- check is slop
        if not raycast_m or not raycast_l or not raycast_r then
            local vRay_x,vRay_y,vRay_z = 0,0,0
            local vNor_x,vNor_y,vNor_z = 0,0,0
            local dL,dM,dR = false,false,false
            if not raycast_m then
                vRay_x,vRay_y,vRay_z = coords2Vector(raycast_mx,raycast_my,raycast_mz,raycast_mx+raycast_mnx,
                        raycast_my+ raycast_mny,raycast_mz)
                vNor_x,vNor_y,vNor_z = coords2Vector(raycast_mx,raycast_my,raycast_mz,raycast_mx+raycast_mnx,
                        raycast_my+raycast_mny,raycast_mz+raycast_mnz)

                angle2Normal = angleBetween2Vec(vNor_x,vNor_y,vNor_z,vRay_x,vRay_y,vRay_z)
                dxDrawLine3D ( raycast_mx,raycast_my,raycast_mz,raycast_mx+raycast_mnx, raycast_my+raycast_mny,
                        raycast_mz+raycast_mnz,tocolor ( 255, 255, 0, 230 ), 1)

                if not isObstcle(angle2Normal) then
                    raycast_m = true
                    dM = true

                end
            end

            if not raycast_l then
                vRay_x,vRay_y,vRay_z = coords2Vector(raycast_lx,raycast_ly,raycast_lz,raycast_lx+raycast_lnx,
                        raycast_ly+ raycast_lny,raycast_lz)
                vNor_x,vNor_y,vNor_z = coords2Vector(raycast_lx,raycast_ly,raycast_lz,raycast_lx+raycast_lnx,
                        raycast_ly+raycast_lny,raycast_lz+raycast_lnz)

                angle2Normal = angleBetween2Vec(vNor_x,vNor_y,vNor_z,vRay_x,vRay_y,vRay_z)
                dxDrawLine3D ( raycast_lx,raycast_ly,raycast_lz,raycast_lx+raycast_lnx, raycast_ly+raycast_lny,raycast_lz+raycast_lnz,tocolor ( 255, 255, 0, 230 ), 1)
                if not isObstcle(angle2Normal) then
                    raycast_l = true
                    dL = true
                end

            end

            if not raycast_r then
                vRay_x,vRay_y,vRay_z = coords2Vector(raycast_rx,raycast_ry,raycast_rz,raycast_rx+raycast_rnx,
                        raycast_ry+ raycast_rny,raycast_rz)
                vNor_x,vNor_y,vNor_z = coords2Vector(raycast_rx,raycast_ry,raycast_rz,raycast_rx+raycast_rnx,
                        raycast_ry+raycast_rny,raycast_rz+raycast_rnz)

                dxDrawLine3D ( raycast_rx,raycast_ry,raycast_rz,raycast_rx+raycast_rnx, raycast_ry+raycast_rny,
                        raycast_rz+raycast_rnz,tocolor ( 255, 255, 0, 230 ), 1)
                angle2Normal = angleBetween2Vec(vNor_x,vNor_y,vNor_z,vRay_x,vRay_y,vRay_z)
                if not isObstcle(angle2Normal) then
                    raycast_r = true
                    dR = true
                end
            end


            local msg = string.format("Obstacle Check: %s|%s|%s",dL and "NO" or "YES",dM and "NO" or "YES",dR and
                    "NO" or "YES")
            dxDrawTextOnElement(vehPtr,msg,1.6,20,0,255,255,255,1.5,"Default")
        end


        --debug line

        local l_color = raycast_l == true and tocolor ( 0, 255, 0, 230 ) or tocolor ( 255, 0, 0, 230 )
        dxDrawLine3D ( x,y,z+sensorOffsetZ,raycast_lx,raycast_ly,raycast_lz,l_color, 1) -- left
        l_color = raycast_m == true and tocolor ( 0, 255, 0, 230 ) or tocolor ( 255, 0, 0, 230 )
        dxDrawLine3D ( x,y,z+sensorOffsetZ,raycast_mx,raycast_my,raycast_mz, l_color, 1) -- Middle
        l_color = raycast_r == true  and tocolor ( 0, 255, 0, 230 ) or tocolor ( 255, 0, 0, 230 )
        dxDrawLine3D ( x,y,z+sensorOffsetZ,raycast_rx,raycast_ry,raycast_rz, l_color, 1) -- righ
        l_color = raycast_sl == true and  tocolor ( 0, 255, 0, 230 ) or tocolor ( 255, 0, 0, 230 )
        dxDrawLine3D ( x,y,z+sensorOffsetZ,raycast_slx,raycast_sly,raycast_slz, l_color, 1) -- side left
        l_color = raycast_sr == true and  tocolor ( 0, 255, 0, 230 ) or tocolor ( 255, 0, 0, 230 )
        dxDrawLine3D ( x,y,z+sensorOffsetZ,raycast_srx,raycast_sry,raycast_srz, l_color, 1) -- side right
        l_color = raycast_b == true and  tocolor ( 0, 255, 0, 230 ) or tocolor ( 255, 0, 0, 230 )
        dxDrawLine3D ( x,y,z+sensorOffsetZ,raycast_bx,raycast_by,raycast_bz, l_color, 1) -- side right
        local status = string.format("Decision:%s\nPresskey:%s\nStuck Turning Decition:%d\nslop angle:%f",aiStatus,
                aiDriveDecision,suckTurn,angle2Normal)
        --debug status
        dxDrawTextOnElement(vehPtr,status,1,20,255,255,255,255,1.5,"Default")


        -- ai logic
        aiDebugLogic(raycast_l,raycast_m,raycast_r,raycast_sl,raycast_sr,raycast_b)
    end
end
addEventHandler ( "onClientRender", root, aiDebug )

ignoreCollision = false

addEventHandler("onClientVehicleCollision", root,
    function(collider,force, bodyPart, x, y, z, nx, ny, nz)
        if not ignoreCollision and bodyPart == 3 then
            --outputChatBox(bodyPart)
            if ( source == getPedOccupiedVehicle(localPlayer) ) then
                ignoreCollision = true
                aiStatus = status[2]
                setTimer(function()
                    aiStatus = status[1]
                    ignoreCollision = false
                end,2000,1)

                -- force does not take into account the collision damage multiplier (this is what makes heavy vehicles take less damage than banshees for instance) so take that into account to get the damage dealt
                local fDamageMultiplier = getVehicleHandling(source).collisionDamageMultiplier
                -- Create a marker (Scaled down to 1% of the actual damage otherwise we will get huge markers)
                local m = createMarker(x, y, z, "corona", force * fDamageMultiplier * 0.01, 231,0 , 0)
                -- Destroy the marker in 2 seconds
                setTimer(destroyElement, 2000, 1, m)
            end
        end

    end
)

function aiStatusBackwards(raycast_l,raycast_m,raycast_r,raycast_sl,raycast_sr,raycast_b)
    if not raycast_b then
        aiStatus = status[1]
        controlForward(localPlayer)
        return
    end

    controlBackward(player)
    if not raycast_sl and not raycast_sr then
        local selection = math.random(0, 1)
        if selection == 0 then
            controlRight(localPlayer)
        end
        if selection == 1 then
            controlLeft(localPlayer)
        end
    elseif raycast_sl then
        controlRight(localPlayer)
    elseif raycast_sr then
        controlLeft(localPlayer)
    end

end
suckTurn = 0
function aiStatusStucked(raycast_l,raycast_m,raycast_r,raycast_sl,raycast_sr,raycast_b)
    -- When stucked, check coresponding sensors for where we can drive around outputChatBox
    controlForward(localPlayer)
    if suckTurn == 0 then
        if not raycast_sl then
            suckTurn = 1
        elseif not raycast_sr then
            suckTurn = 2
        end
    end
    if suckTurn == 1 then
        controlRight(localPlayer)

    end
    if suckTurn == 2 then
        controlLeft(localPlayer)
    end
end
function aiDebugLogic(raycast_l,raycast_m,raycast_r,raycast_sl,raycast_sr,raycast_b)
    if not enableAiDebug then return end
        if aiStatus == status[3] then
            aiStatusStucked(raycast_l,raycast_m,raycast_r,raycast_sl,raycast_sr,raycast_b)
        end
        if aiStatus == status[2] then
            aiStatusBackwards(raycast_l,raycast_m,raycast_r,raycast_sl,raycast_sr,raycast_b)
        end
        if aiStatus == status[1] then
            if not raycast_l and not raycast_m and not raycast_r and raycast_b then -- When Drive backwords
                --check if can go left or right in side sensor

                if  raycast_sl then
                    controlRight(localPlayer)
                elseif raycast_sr then
                    controlLeft(localPlayer)
                else
                    aiStatus = status[2]
                    setTimer(function()
                        aiStatus = status[1]
                    end,2000,1)
                end
            elseif not raycast_m and not raycast_b then -- When getting stucked
                aiStatus = status[3]
                setTimer(function()
                    aiStatus = status[1]
                    suckTurn = 0
                end,3000,1)
            end

            if raycast_m then
                controlForward(localPlayer)
            else
                --controlBackward(player)
            end

            if raycast_l and raycast_r and raycast_sl and raycast_sr then
                setControlState ("vehicle_left", false )
                setControlState ("vehicle_right", false )

            else
                if not raycast_l or not raycast_l and not raycast_m then
                    controlForward(localPlayer)
                    controlRight(localPlayer)
                end
                if not raycast_r  or not raycast_r and not raycast_m  then
                    controlForward(localPlayer)
                    controlLeft(localPlayer)
                end

                if not raycast_sl then
                    controlRight(localPlayer)
                end
                if not raycast_sr then
                    controlLeft(localPlayer)
                end
            end
    end
end

function controlForward(player)
    local vehPtr = getPedOccupiedVehicle(player)
    if getElementSpeed(vehPtr) < speedLimit then
        --outputChatBox("[AI]: w")
        setControlState ('accelerate', true)
        setControlState ("brake_reverse", false )
        setControlState ("handbrake", false )
        aiDriveDecision = "FORWARD HOLD"
    else
        --outputChatBox("[AI]: s")
        setControlState ('accelerate', false)
        setControlState ("brake_reverse", false )
        setControlState ("handbrake", false )
        --setControlState ("brake_reverse", true )
        --setControlState ("handbrake", true )
        aiDriveDecision = "FORWARD RELE"
    end
end
function controlBreak(player)
    local vehPtr = getPedOccupiedVehicle(player)
    if getElementSpeed(vehPtr) > 0 then
        --outputChatBox("[AI]: w")
        setControlState ('accelerate', false)
        setControlState ("brake_reverse", true )
        setControlState ("handbrake", true )
        aiDriveDecision = "BRAKE HOLD"
    end
end
function controlLeft(player)
    setControlState ("vehicle_left", true )
    setControlState ("vehicle_right ", false )
    aiDriveDecision = "LEFT HOLD"
end
function controlRight(player)
    setControlState ("vehicle_right", true )
    setControlState ("vehicle_left", false )
    aiDriveDecision = "RIGHT HOLD"
end

function controlBackward(player)
    setControlState ("brake_reverse", true )
    setControlState ('accelerate', false)
    aiDriveDecision = "BACKWARD HOLD"
    --outputChatBox("[AI]:s back")
end

function toogleAiDebug(cmd)
    enableAiDebug = not enableAiDebug
    if enableAiDebug then
        outputChatBox("[AI]: 切换-> YES")
    else
        outputChatBox("[AI]: 切换-> NO")
        setControlState ('accelerate', false)
        setControlState ("brake_reverse", false )
        setControlState ("handbrake", false )
        setControlState ("vehicle_right", false )
        setControlState ("vehicle_left", false )
    end
end
addCommandHandler ( "ai", toogleAiDebug )


-- Helper functions
function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function dxDrawTextOnElement(TheElement,text,height,distance,R,G,B,alpha,size,font)
    dxDrawTextOnElementEx(TheElement,text,height,distance,0,0,0,255,size,font)
    local x, y, z = getElementPosition(TheElement)
    local x2, y2, z2 = getCameraMatrix()
    local distance = distance or 20
    local height = height or 1

    if (isLineOfSightClear(x, y, z+2, x2, y2, z2)) then
        local sx, sy = getScreenFromWorldPosition(x, y, z+height)
        if(sx) and (sy) then
            local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
            if(distanceBetweenPoints < distance) then
                dxDrawText(text, sx+2, sy+2, sx, sy, tocolor(R or 255, G or 255, B or 255, alpha or 255), (size or 1)-(distanceBetweenPoints / distance), font or "arial", "center", "center")
            end
        end
    end
end

function dxDrawTextOnElementEx(TheElement,text,height,distance,R,G,B,alpha,size,font)
    local x, y, z = getElementPosition(TheElement)
    local x2, y2, z2 = getCameraMatrix()
    local distance = distance or 20
    local height = height or 1

    if (isLineOfSightClear(x, y, z+2, x2, y2, z2)) then
        local sx, sy = getScreenFromWorldPosition(x, y, z+height-0.01)
        if(sx) and (sy) then
            local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
            if(distanceBetweenPoints < distance) then
                dxDrawText(text, sx+2, sy+2, sx, sy, tocolor(R or 255, G or 255, B or 255, alpha or 255), (size or 1)-(distanceBetweenPoints / distance), font or "arial", "center", "center")
            end
        end
    end
end