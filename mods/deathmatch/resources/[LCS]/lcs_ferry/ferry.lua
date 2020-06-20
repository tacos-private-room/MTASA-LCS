routes = {
    {380.933,223.322,0.0},
    {404.512,221.911,0.0},
    {434.0,219.867,0.0},
    {464.382,216.313,0.0},
    {492.281,209.785,0.0},
    {519.786,199.963,0.0},
    {546.461,190.908,0.0},
    {573.041,185.162,0.0},
    {601.039,180.494,0.0},
    {626.771,177.163,0.0},
    {646.291,175.636,0.0},
    {658.467,175.574,0.0},
    {667.518,175.56,0.0},
    {673.95,175.55,0.0},
    {685.839,175.544,0.0},
    {687.41,175.54,0.0},
    {688.141,175.539,0.0},
    {687.483,175.539,0.0},
    {685.808,175.542,0.0},
    {673.71,175.548,0.0},
    {667.063,175.558,0.0},
    {657.851,175.573,0.0},
    {645.616,175.594,0.0},
    {627.266,175.631,0.0},
    {603.744,175.709,0.0},
    {577.781,175.856,0.0},
    {552.14,176.113,0.0},
    {524.814,177.364,0.0},
    {495.916,180.259,0.0},
    {468.617,184.934,0.0},
    {441.257,191.628,0.0},
    {412.905,199.697,0.0},
    {384.692,208.173,0.0},
    {357.644,216.115,0.0},
    {332.792,222.581,0.0},
    {311.258,226.604,0.0},
    {294.093,227.466,0.0},
    {282.076,227.462,0.0},
    {274.486,227.455,0.0},
    {262.225,227.447,0.0},
    {260.423,227.441,0.0},
    {260.003,227.437,0.0},
    {261.376,227.439,0.0},
    {276.125,227.449,0.0},
    {286.419,227.46,0.0},
    {298.197,227.466,0.0},
    {309.92,227.362,0.0},
    {321.837,227.017,0.0},
    {334.467,226.432,0.0},
    {348.329,225.609,0.0}
}
waitTime = 10 * 1000
speed = 4000
ferry_1 = exports.Objs:JcreateObject('ferry',0,0,3.0,0,0,90)

board_markers = {nil,nil}
current_waypoint = 1

wave_sin = 0
wave_steps = 0

runTimer = nil
waitTimer = nil

function GetRotation2( x1, y1, z1, x2, y2, z2 )
    local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
    rotx = math.deg(rotx)
    local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    rotz = rotz < 0 and rotz + 360 or rotz
    return rotx, 0,rotz
end
--[[
setTimer ( function()
    if wave_steps > 360 then wave_steps = 1 end
    wave_steps = wave_steps +1
    wave_sin = math.sin(wave_steps)
    --outputChatBox (wave_sin)
    local rx,ry,rz = getElementRotation(ferry_1)
    setElementRotation(ferry_1,rx+wave_sin,ry,rz )
end, 70, 0 )

--]]
function ferryRunRoute()

    runTimer = setTimer ( function()
        --判断到站
        if current_waypoint == 17 or current_waypoint == 42  then
            if current_waypoint == 17 then --station portland
                board_markers [1] = createMarker ( 711.40924072266, 175.56321716309, 2.6302380561829, "cylinder", 4.0, 255, 255, 0, 170 )
            elseif current_waypoint == 42 then -- station statun
                board_markers [2] = createMarker ( 235.69682312012, 227.52537536621, 2.7293152809143, "cylinder", 4.0, 255, 255, 0, 170 )
            end

            killTimer(runTimer)
            runTimer =nil
            --outputChatBox ("Wait for pessenger")
            if current_waypoint == 17 then
                unloadPessengers(1)
            elseif current_waypoint == 42 then
                unloadPessengers(2)
            end


            waitTimer = setTimer ( function()
                if  board_markers [1]  then
                    destroyElement(board_markers [1])
                    board_markers [1] = nil
                end
                if  board_markers [2] then
                    destroyElement(board_markers [2])
                    board_markers [2] = nil
                end


                --outputChatBox ("GO")
                killTimer(waitTimer)
                waitTimer = nil
                ferryRunRoute()
            end, waitTime, 1 )
        end
        if current_waypoint < #routes then

            local x,y,z = getElementPosition(ferry_1)
            angle = math.atan( x - routes[current_waypoint+1][1] / y- routes[current_waypoint+1][2] )
            --判断朝向左边还是右边
            if x - routes[current_waypoint+1][1] < 0 then
                angle = -angle
            else
                angle = angle
            end
            current_waypoint = current_waypoint + 1
        else
            current_waypoint = 1
            angle = 0
        end

        --计算轮船朝向角
        local rx,ry,rz = getElementRotation(ferry_1)
        --setElementPosition(ferry_1,routes[current_waypoint][1],routes[current_waypoint][2],routes[current_waypoint][3]+5)
        moveObject ( ferry_1, speed, routes[current_waypoint][1],routes[current_waypoint][2],routes[current_waypoint][3]+5 )

    end, speed, 0 )
end

function onPlayerHitCheckpoint(markerHit,matchingDimension)
    if markerHit == board_markers [1] then
        exports.lcs_ui:showTextBox(source,"Ferry to Staunton \nPress 2 or TAB to buy a ticket.",5000)
    elseif markerHit == board_markers [2] then
        exports.lcs_ui:showTextBox(source,"Ferry to Portland \nPress 2 or TAB to buy a ticket.",5000)
    end
end
addEventHandler("onPlayerMarkerHit",getRootElement(),onPlayerHitCheckpoint)

function isElementInRange(ele, x, y, z, range)
    if isElement(ele) and type(x) == "number" and type(y) == "number" and type(z) == "number" and type(range) == "number" then
        return getDistanceBetweenPoints3D(x, y, z, getElementPosition(ele)) <= range -- returns true if it the range of the element to the main point is smaller than (or as big as) the maximum range.
    end
    return false
end
function unloadPessengers(station_id)
    local attachedElements = getAttachedElements ( ferry_1 )
    for _,v in  ipairs ( attachedElements ) do
        -- Rest Camera
        triggerClientEvent ( v, "clientFerryCamera", v, false )
        setTimer ( function(source)
            detachElements ( v ,ferry_1 )
            local x,y,z = getElementPosition(board_markers [station_id])
            setElementPosition(v, x,y,z+2)
        end, 1000, 1, v )
    end
end

function boardFerry(playerid)
    triggerClientEvent ( playerid, "clientFerryCamera", playerid, true )
    setTimer ( function(source) attachElements ( source, ferry_1, 0, 0, 0 ) end, 1000, 1, playerid )



end
function reqboardFerry(playerid)

    local x, y, z = getElementPosition (playerid)
    if isElementInRange (board_markers [1], x, y, z, 2) or isElementInRange (board_markers [2], x, y, z, 4) then
        boardFerry(playerid)
    else
       --outputChatBox ("Too far",playerid)
    end
end
addEvent( "requestServerBoardFerry", true )
addEventHandler( "requestServerBoardFerry", resourceRoot, reqboardFerry )

ferryRunRoute()
