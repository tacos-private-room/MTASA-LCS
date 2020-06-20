----------------------------------------------------------------
---------------------------- SETTINGS --------------------------
----------------------------------------------------------------

settings = {
['autoPosOnOpen'] = true, -- Get Position Automatically on Open
['DeletePosOnClose'] = true -- Delete Position Automatically on Close
}

----------------------------------------------------------------
----------------------- CREATE THE WINDOW ----------------------
----------------------------------------------------------------

    Window = guiCreateWindow(983, 515, 252, 173, "Get Position | By SimplyMods", false)
    guiWindowSetSizable(Window, false)
	guiSetVisible (Window, false )
    GetPos = guiCreateButton(17, 124, 103, 26, "Get my Positions", false, Window)
    Close = guiCreateButton(130, 124, 103, 26, "Close", false, Window)
    X = guiCreateLabel(17, 31, 15, 15, "X:", false, Window)
    Y = guiCreateLabel(17, 61, 15, 15, "Y:", false, Window)
    Z = guiCreateLabel(17, 91, 15, 15, "Z:", false, Window)
    XE = guiCreateEdit(42, 30, 196, 19, "", false, Window)
    YE = guiCreateEdit(42, 60, 196, 19, "", false, Window)
    ZE = guiCreateEdit(42, 90, 196, 19, "", false, Window) 
	CreatedBy = guiCreateLabel(105, 151, 67, 15, "Created by:", false, Window)
    SimplyMods = guiCreateLabel(172, 151, 86, 15, "SimplyMods", false, Window)
    guiLabelSetColor(SimplyMods, 232, 44, 44)		

----------------------------------------------------------------
--------------------------- OPEN GUI ---------------------------
----------------------------------------------------------------

bindKey("l", "down",
	function()
		if getKeyState("lalt") then
			switch()
		end
	end
)
bindKey("lalt", "down",
	function()
		if getKeyState("l") then
			switch()
		end
	end
)
function switch()
	if Enabled then
	if settings['DeletePosOnClose'] == true then
		guiSetText (XE, "" )
		guiSetText (YE, "" )
		guiSetText (ZE, "" )	
		Enabled = false
		guiSetVisible (Window, false )
		showCursor(false)
	elseif settings['DeletePosOnClose'] == false then
		Enabled = false
		guiSetVisible (Window, false )
		showCursor(false)
	end
	else
	if settings['autoPosOnOpen'] == true then
		local x,y,z = getElementPosition (getLocalPlayer())
		Enabled = true
		guiSetVisible (Window, true )
		showCursor(true)	
		guiSetText (XE, x )
		guiSetText (YE, y )
		guiSetText (ZE, z )		
	elseif settings['autoPosOnOpen'] == false then
		Enabled = true
		guiSetVisible (Window, true )
		showCursor(true)
	end
	end
end
addCommandHandler("pos", switch)

----------------------------------------------------------------
------------------------ BUTTON SCRIPTS ------------------------
----------------------------------------------------------------

function onGuiClick (button)
if (source == GetPos) then
	local x,y,z = getElementPosition (getLocalPlayer())
    guiSetText (XE, x )
    guiSetText (YE, y )
    guiSetText (ZE, z )
end

if (source == Close) then
	guiSetText (XE, "" )
	guiSetText (YE, "" )
	guiSetText (ZE, "" )	
	Enabled = false
	guiSetVisible (Window, false )
	showCursor(false)
end
end
addEventHandler ("onClientGUIClick", getRootElement(), onGuiClick)
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------