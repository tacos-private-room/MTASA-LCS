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
cameramode = false

function dxDrawCircle3D( x, y, z, radius, segments, color, width )
    segments = segments or 16; -- circle is divided into segments -> higher number = smoother circle = more calculations
    color = color or tocolor( 255, 255, 0 );
    width = width or 1;
    local segAngle = 360 / segments;
    local fX, fY, tX, tY; -- drawing line: from - to
    for i = 1, segments do
        fX = x + math.cos( math.rad( segAngle * i ) ) * radius;
        fY = y + math.sin( math.rad( segAngle * i ) ) * radius;
        tX = x + math.cos( math.rad( segAngle * (i+1) ) ) * radius;
        tY = y + math.sin( math.rad( segAngle * (i+1) ) ) * radius;
        dxDrawLine3D( fX, fY, z, tX, tY, z, color, width );
    end
end
function createLine ( )
    if cameramode then
        local x,y,z = getElementPosition( getLocalPlayer ( ))
        setCameraMatrix( x-35,y+35,z+10, x,y,z)
    end
    --drawDebugRouteLine()
end
addEventHandler("onClientRender", root, createLine)

addEventHandler( "onClientKey", root, function(button,press)
    -- Since mouse_wheel_up and mouse_wheel_down cant return a release, we dont have to check the press.
    if button == "2" and press then
        triggerServerEvent ( "requestServerBoardFerry", resourceRoot, getLocalPlayer ( ) )
        return true
    end
    return false
end )
function drawDebugRouteLine()
    for i= 1,#routes do
        if  i+1 < #routes -1  then
            dxDrawLine3D(routes[i][1],routes[i][2],routes[i][3],routes[i+1][1],routes[i+1][2],routes[i+1][3], tocolor ( 0, 255, 0, 230 ),2.0)
            dxDrawCircle3D(routes[i][1],routes[i][2],routes[i][3],1)
            outputConsole(routes[i][3].."load")
        end
    end
end
function toogleClientFerryCamera(toggle)
    cameramode = toggle

    fadeCamera(false, 1)
    setTimer ( function()
        fadeCamera(true, 1)
        exports.lcs_radio:playRadio(9)
        if cameramode == false then
            setCameraTarget( getLocalPlayer ( ), getLocalPlayer ( ))
            exports.lcs_radio:stopRadio()
        end
    end, 1000, 1, source )
end
addEvent( "clientFerryCamera", true )
addEventHandler( "clientFerryCamera", localPlayer, toogleClientFerryCamera )