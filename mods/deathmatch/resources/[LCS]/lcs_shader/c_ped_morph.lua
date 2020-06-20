--
-- c_ped_morph.lua
--

local myShader
local size = 0.03

addEventHandler( "onClientResourceStart", resourceRoot,
	function()

		-- Version check
		if getVersion ().sortable < "1.3.1-9.04939" then
			outputChatBox( "Resource is not compatible with this client." )
			outputChatBox( "Please update MTA:SA." )
			return
		end

		-- Create shader
		myShader, tec = dxCreateShader ( "fx/ped_morph.fx", 1, 0, false, "all")

		if not myShader then
			outputChatBox( "Could not create shader. Please use debugscript 3" )
		else
			outputChatBox( "Using technique " .. tec )

			-- Get current ped model
			local modelID = getElementModel ( getLocalPlayer() )

			-- Apply shader to local player
			engineApplyShaderToWorldTexture ( myShader, "coronastar" )

			outputChatBox( "Press 'k' and 'l' to change size" )

			-- Start effect at startup
			changeSize("",nil,0);
		end
	end
)


----------------------------------------------------------------
-- Do change
----------------------------------------------------------------
function changeSize(key, state, dir)
	size = size + 0.005 * dir
	dxSetShaderValue( myShader, "sMorphSize", size, size, size )
end

bindKey("k", "down", changeSize, -1 )
bindKey("l", "down", changeSize, 1 )
