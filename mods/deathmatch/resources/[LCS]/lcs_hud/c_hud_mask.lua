--
-- c_hud_mask.lua
--

----------------------------------------------------------------
-- onClientResourceStart
----------------------------------------------------------------
showHUD = true
addEventHandler( "onClientResourceStart", resourceRoot,
	function()
		setPlayerHudComponentVisible ( "radar", false )
		-- Create things
        hudMaskShader = dxCreateShader("hud_mask.fx")
		radarTexture = dxCreateTexture("images/radar.jpg")
		maskTexture1 = dxCreateTexture("images/circle_mask.png")
		maskTexture2 = dxCreateTexture("images/sept_mask.png")

		-- Check everything is ok
		bAllValid = hudMaskShader and radarTexture and maskTexture1 and maskTexture2

		if not bAllValid then
			outputChatBox( "Could not create some things. Please use debugscript 3" )
		else
			dxSetShaderValue( hudMaskShader, "sPicTexture", radarTexture )
			dxSetShaderValue( hudMaskShader, "sMaskTexture", maskTexture1 )
		end
	end
)

-----------------------------------------------------------------------------------
-- onClientRender
-----------------------------------------------------------------------------------

addEventHandler( "onClientRender", root,
    function()
		if not bAllValid then return end
		if not showHUD then return end

		--
		-- Switch between mask textures every few seconds for DEMO
		--
		dxSetShaderValue( hudMaskShader, "sMaskTexture", maskTexture1 )

		--
		-- Transform world x,y into -0.5 to 0.5
		--
		local x,y = getElementPosition(localPlayer)
		x = ( x ) / 4000
		y = ( y ) / -4000
		dxSetShaderValue( hudMaskShader, "gUVPosition", x,y )

		--
		-- Zoom
		--
		local zoom = 8
		---zoom = zoom + math.sin( getTickCount() / 500 ) * 3		-- Zoom animation for DEMO
		dxSetShaderValue( hudMaskShader, "gUVScale", 1/zoom, 1/zoom )

		--
		-- Rotate to camera direction - OPTIONAL
		--
		local _,_,camrot = getElementRotation( getCamera() )
		dxSetShaderValue( hudMaskShader, "gUVRotAngle", math.rad(-camrot) )

		--
		-- Draw
		--

		local mWidth = 250
		local mx = 70
		local my = 780

		local aX, aY, aW, aH = convertFitRatio(mx, my, mWidth, mWidth)

		dxDrawImage(aX, aY, aW, aH, hudMaskShader, 0,0,0 )
		dxDrawImage (aX, aY, aW, aH, 'images/radardisc.png', 0, 0, -120 )
		local cX, cY, cW, cH = convertFitRatio(mWidth/2 + mx -17.5, mWidth/2 + my -17.5, 35, 35)
		local player_angle = getPlayerRotation(localPlayer)

		dxDrawImage (cX, cY, cW, cH, 'images/radar_centre.png', camrot + (360-player_angle)  , 0, 0 )
		--绘制North
		local angle = (-camrot +180) * math.pi / 180
		local radius = mWidth / 2 -5
		local x1 = radius * math.sin(angle)
		local y1 = radius * math.cos(angle)
		local nX, nY, nW, nH = convertFitRatio(mx + mWidth/2 -17.5 + x1 , my + mWidth/2 -17.5 + y1 , 35, 35)

		dxDrawImage ( nX, nY, nW, nH, 'images/radar_north.png', 0, 0, -120 )

    end
)


function convertFitRatio(gX, gY, gW, gH)
	local myX, myY = 1920, 1080 -- The resolution you've used for making the guis
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

function showHud(status) 
	showHUD = status
end