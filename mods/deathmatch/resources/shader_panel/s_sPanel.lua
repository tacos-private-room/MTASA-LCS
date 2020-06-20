--
-- s_sPanel.lua
--

function onEventStart()
	if getElementType ( source ) == "player" then
		local account = getPlayerAccount ( source )
		if account and not isGuestAccount ( account ) then
			if getAccountData ( account, "spl.on" ) then
				setElementData ( source, "spl_logged", true )
				setElementData ( source, "spl_water", getAccountData ( account, "spl.water" ) )
				setElementData ( source, "spl_carpaint", getAccountData ( account, "spl.carpaint" ) )
				setElementData ( source, "spl_bloom", getAccountData ( account, "spl.bloom" ) )
				setElementData ( source, "spl_blur", getAccountData ( account, "spl.blur" ) )
				setElementData ( source, "spl_detail", getAccountData ( account, "spl.detail" ) )
				setElementData ( source, "spl_palette", getAccountData ( account, "spl.palette" ) )
			end
		else
			setElementData ( source, "spl_logged", false )
		end
	end
end

function splsave ( water, carpaint, bloom, blur, palette,detail )
	local account = getPlayerAccount ( source )
	if account and not isGuestAccount ( account ) then
	    setAccountData ( account, "spl.on",true )
		setAccountData ( account, "spl.water", water )
		setAccountData ( account, "spl.carpaint", carpaint )
		setAccountData ( account, "spl.bloom", bloom )
		setAccountData ( account, "spl.blur", blur )
		setAccountData ( account, "spl.detail", detail )
		setAccountData ( account, "spl.palette", palette )
		outputChatBox ( "SP: Your graphics settings have been saved!", source )
		else
	outputChatBox ( "SP: Login to save graphics settings !", source )
	end
	setElementData ( source, "spl_water", water )
	setElementData ( source, "spl_carpaint", carpaint )
	setElementData ( source, "spl_bloom", bloom )
	setElementData ( source, "spl_blur", blur )
	setElementData ( source, "spl_detail", detail )
	setElementData ( source, "spl_palette", palette )
end

addEvent ( "splSave", true )
addEventHandler ( "splSave", root, splsave )
addEventHandler ( "onPlayerLogin", root, onEventStart )
addEventHandler ( "onPlayerLogin", root, function() triggerClientEvent ( "onClientPlayerLogin", source ) end )