local ping = getPlayerPing(getLocalPlayer())
local x, y = guiGetScreenSize ( )

r,g,b=0,0,0
alpha=150


local root = getRootElement()
local player = getLocalPlayer()
local counter = 0
local starttick
local currenttick
addEventHandler("onClientRender",root,
	function()
		if not starttick then
			starttick = getTickCount()
		end
		counter = counter + 1
		currenttick = getTickCount()
		if currenttick - starttick >= 1000 then
			setElementData(player,"FPS",counter)
			counter = 0
			starttick = false
		end
	end
)

function drawStates ()
    addEventHandler ( "onClientRender", root, pingState )
	addEventHandler ( "onClientRender", root, fpsState )
end
addEventHandler ( "onClientResourceStart", resourceRoot, drawStates )



function pingState()
    posx= x-30
    posy= 20

    dxDrawRectangle ( posx, posy, 4, 4, tocolor ( r, g, b, alpha ) )
	dxDrawRectangle ( posx+5, posy-4, 4,8, tocolor ( r, g, b, alpha ) )
	dxDrawRectangle ( posx+10, posy-8, 4,12, tocolor ( r, g, b, alpha ) )
	dxDrawRectangle ( posx+15, posy-12, 4,16, tocolor ( r, g, b, alpha ) )
	dxDrawRectangle ( posx+20, posy-16, 4,20, tocolor ( r, g, b, alpha ) )

	r2,g2,b2=255,255,255
    alpha2=255

if ping <= 100 then

    dxDrawRectangle ( posx, posy, 4, 4, tocolor ( r2, g2, b2, alpha2 ) )
	dxDrawRectangle ( posx+5, posy-4, 4,8, tocolor ( r2, g2, b2, alpha2 ) )
	dxDrawRectangle ( posx+10, posy-8, 4,12, tocolor ( r2, g2, b2, alpha2 ) )
	dxDrawRectangle ( posx+15, posy-12, 4,16, tocolor ( r2, g2, b2, alpha2 ) )
	dxDrawRectangle ( posx+20, posy-16, 4,20, tocolor ( r2, g2, b2, alpha2 ) )

elseif ping >=101 and ping <= 200 then

    dxDrawRectangle ( posx, posy, 4, 4, tocolor ( r2, g2, b2, alpha2 ) )
	dxDrawRectangle ( posx+5, posy-4, 4,8, tocolor ( r2, g2, b2, alpha2 ) )
	dxDrawRectangle ( posx+10, posy-8, 4,12, tocolor ( r2, g2, b2, alpha2 ) )
	dxDrawRectangle ( posx+15, posy-12, 4,16, tocolor ( r2, g2, b2, alpha2 ) )

elseif ping >=201 and ping <= 300 then

    dxDrawRectangle ( posx, posy, 4, 4, tocolor ( r2, g2, b2, alpha2 ) )
	dxDrawRectangle ( posx+5, posy-4, 4,8, tocolor ( r2, g2, b2, alpha2 ) )
	dxDrawRectangle ( posx+10, posy-8, 4,12, tocolor ( r2, g2, b2, alpha2 ) )

elseif ping >=301 and ping <= 400 then

    dxDrawRectangle ( posx, posy, 4, 4, tocolor ( r2, g2, b2, alpha2 ) )
	dxDrawRectangle ( posx+5, posy-4, 4,8, tocolor ( r2, g2, b2, alpha2 ) )

elseif ping >=401 and ping <= 500 then

    dxDrawRectangle ( posx, posy, 4, 4, tocolor ( r2, g2, b2, alpha2 ) )

end

end

function fpsState()
    posx2= x-55
    posy2= 13

    dxDrawText ( getElementData(getLocalPlayer(),"FPS"), posx2-12, posy2-6, x, y, tocolor ( 255, 255, 255, 255 ), 1.4, "default-bold" )

	dxDrawText ( "FPS", posx2-13, posy2+10, x, y, tocolor ( 255, 255, 255, 255 ), 1.0, "default-bold" )
	dxDrawText ( "PING", posx2+23, posy2+10, x, y, tocolor ( 255, 255, 255, 255 ), 1.0, "default-bold" )
end
