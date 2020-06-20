pVehStatus = {
    flycar = false,
    hovercar = false
}

pvehicle = {}

function flycar()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then 
        outputChatBox("[错误]: 你不在车里",255,100,100)
    end
    pVehStatus.flycar = not pVehStatus.flycar
    setWorldSpecialPropertyEnabled( "aircars",pVehStatus.flycar )
end
addCommandHandler('flycar',flycar,false,false)

function hovercar()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then
        outputChatBox("[错误]: 你不在车里",255,100,100)
    end
    pVehStatus.hovercar = not pVehStatus.hovercar
    setWorldSpecialPropertyEnabled( "hovercars", pVehStatus.hovercar )
end
addCommandHandler('hovercar',hovercar,false,false)


function toggleNOS(btn, state)
	local veh = getPedOccupiedVehicle(localPlayer)
	if veh and getVehicleController(veh) == localPlayer then
		local doesVehicleHaveNitro = getVehicleUpgradeOnSlot(veh, 8)
		if doesVehicleHaveNitro and doesVehicleHaveNitro ~= 0 then
			if state == "up" then
				if isVehicleNitroActivated(veh) then
					setVehicleNitroActivated (veh, false)
				end
			end
		end
	end
end
bindKey ("vehicle_fire", "both", toggleNOS)

local resetNitroCount
function onNitroStateChange(state)
    if state then
		if isPedDoingGangDriveby(getVehicleController(source)) then
			setVehicleNitroActivated(source, false)
			return
		end
		if isTimer (resetNitroCount) then killTimer (resetNitroCount) end
		resetNitroCount = setTimer (function (veh)
			if veh and isElement(veh) and getElementType(veh) == "vehicle" and getVehicleController (veh) == localPlayer then
                setVehicleNitroLevel (veh, 1.0)
			else
				killTimer (resetNitroCount)
			end
		end, 1000, 0, source)
	else
		local doesVehicleHaveNitro = getVehicleUpgradeOnSlot(source, 8)
		removeVehicleUpgrade(source, doesVehicleHaveNitro)
		setTimer(addVehicleUpgrade, 200, 1, source, doesVehicleHaveNitro)
	end
end
addEventHandler("onClientVehicleNitroStateChange", root, onNitroStateChange)