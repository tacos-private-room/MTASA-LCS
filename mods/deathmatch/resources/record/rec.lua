recordings = { }
recordingsTime = { }
recordingsPosrot = { }

states = { }
states2 = { }
ticks = { }
delayTicks = { }
finalString = ""
finalPosRotString = ""

--[[states[1] = false
states[2] = false
states[3] = false
states[4] = false

states2[1] = false
states2[2] = false
states2[3] = false
states2[4] = false]]

outputChatBox ( "REC v0.1 loaded. Record with /rstart" )
outputChatBox ( "Please do not exit your vehicle while recording." )
setElementData ( getLocalPlayer(), "rec.busy", false )

function rec ( )
	--[[local thisFrameTick = getTickCount ( )
	states[1] = getControlState ( "accelerate" )
	states[2] = getControlState ( "brake_reverse" )
	states[3] = getControlState ( "vehicle_left" )
	states[4] = getControlState ( "vehicle_right" )
	for i=1, 4 do
		if not states2[i] == states[i] then
			if states[i] == false then
				local thisAction;
				if i == 1 then thisAction = "accelerate" 
				elseif i == 2 then thisAction = "brake_reverse" 
				elseif i == 3 then thisAction = "vehicle_left" 
				elseif i == 4 then thisAction = "vehicle_right" end
				local thisFinalTick = thisFrameTick
				local finalTick = thisFinalTick - ticks[i]
				local beginningTick = ticks[i] - firstTick
				finalString = finalString .. thisAction .. "," .. beginningTick .. "," .. finalTick .. "."
				outputDebugString ( "Tecla: "..i..". Comienza en: "..beginningTick.. "ms. Dura: " .. finalTick .. " ms."  )
			else
				ticks[i] = thisFrameTick
			end
		end
	end
	for i=1, 4 do states2[i] = states[i] end]]
end

function renderRec ( )
	local cx, cy, cz = getElementPosition ( getPedOccupiedVehicle ( getLocalPlayer() ) )
	local crx, cry, crz = getElementRotation ( getPedOccupiedVehicle ( getLocalPlayer() ) ) 
	local cvx, cvy, cvz = getElementVelocity ( getPedOccupiedVehicle ( getLocalPlayer() ) ) 
	local ctvx, ctvy, ctvz = getVehicleTurnVelocity ( getPedOccupiedVehicle ( getLocalPlayer() ) ) 
	finalPosRotString = finalPosRotString .. "_" .. cx .. "," .. cy .. "," .. cz .. "," .. crx .. "," .. cry .. "," .. crz .. "," .. cvx .. "," .. cvy .. "," .. cvz .. "," .. ctvx .. "," .. ctvy .. "," .. ctvz
end

function renderPlay ( )
	local posRotMinData = split ( posRotData[nowPlayingPosrotSlot], string.byte(",") )
	local px, py, pz = getElementPosition ( getLocalPlayer() )
	--if getDistanceBetweenPoints3D ( px, py, pz, posRotMinData[1], posRotMinData[2], posRotMinData[3] ) < 300  then
		setElementPosition ( playVehicle, posRotMinData[1], posRotMinData[2], posRotMinData[3] )
		setElementRotation ( playVehicle, posRotMinData[4], posRotMinData[5], posRotMinData[6] )
		setElementVelocity ( playVehicle, posRotMinData[7], posRotMinData[8], posRotMinData[9] )
		setVehicleTurnVelocity ( playVehicle, posRotMinData[10], posRotMinData[11], posRotMinData[12] )
	--end
	if ( nowPlayingPosrotSlot == #posRotData ) then
		removeEventHandler ( "onClientPreRender", getRootElement(), renderPlay )
		outputChatBox ( "Playback finished." )
		setElementData ( getLocalPlayer(), "rec.busy", false )
	else
		nowPlayingPosrotSlot = nowPlayingPosrotSlot + 1
	end	
end
	
function beginRec ( )
	if ( isPedInVehicle(getLocalPlayer()) == true ) then
		if ( getElementData(getLocalPlayer(),"rec.busy") == false ) then
			firstTick = getTickCount ( )
			outputChatBox ( "Now Recording. To stop, use /rstop" )
			--addEventHandler ( "onClientRender", getRootElement(), rec )
			x, y, z = getElementPosition ( getPedOccupiedVehicle ( getLocalPlayer() ) )
			rx, ry, rz = getElementRotation ( getPedOccupiedVehicle ( getLocalPlayer() ) )
			model = getElementModel ( getPedOccupiedVehicle ( getLocalPlayer() ) )
			--[[posRotTimer = setTimer ( function() 
				local cx, cy, cz = getElementPosition ( getPedOccupiedVehicle ( getLocalPlayer() ) )
				local crx, cry, crz = getElementRotation ( getPedOccupiedVehicle ( getLocalPlayer() ) ) 
				local cvx, cvy, cvz = getElementVelocity ( getPedOccupiedVehicle ( getLocalPlayer() ) ) 
				local ctvx, ctvy, ctvz = getVehicleTurnVelocity ( getPedOccupiedVehicle ( getLocalPlayer() ) ) 
				finalPosRotString = finalPosRotString .. "_" .. cx .. "," .. cy .. "," .. cz .. "," .. crx .. "," .. cry .. "," .. crz .. "," .. cvx .. "," .. cvy .. "," .. cvz .. "," .. ctvx .. "," .. ctvy .. "," .. ctvz
			end, 50, 0 )]]
			addEventHandler ( "onClientRender", getRootElement(), renderRec )
			setElementData ( getLocalPlayer(), "rec.busy", true )
		else
			outputChatBox ( "You are recording or playing a record. Please stop this operation before playing." )
		end
	else
		outputChatBox ( "Only vehicle path recording is supported at the moment." )
	end
end

addCommandHandler ( "rstart", beginRec )

function stopRec ( )
	if ( getElementData(getLocalPlayer(),"rec.busy") == true ) then
		lastTick = getTickCount ( )
		local rectime = lastTick - firstTick
		--removeEventHandler ( "onClientRender", getRootElement(), rec )
		--finalString = finalString .. "_" .. firstTick .. "," .. lastTick
		finalString = x .. "," .. y .. "," .. z .. "," .. rx .. "," .. ry .. "," .. rz .. "," .. model .. "," .. rectime
		--finalString = string.gsub ( finalString, "./", "/" )
		local thisRecId = #recordings+1
		recordings[thisRecId] = finalString
		recordingsPosrot[thisRecId] = finalPosRotString
		--killTimer ( posRotTimer )
		removeEventHandler ( "onClientRender", getRootElement(), renderRec )
		outputChatBox ( "Recording done. To play, use /pstart "..#recordings )
		local data = string.format("%s\n%s",finalString,finalPosRotString)
		triggerServerEvent ( "saveRecord", resourceRoot, data )

		print (data)
		finalString = ""
		finalPosRotString = ""
		setElementData ( getLocalPlayer(), "rec.busy", false )
	else
		outputChatBox ( "You are not recording. To record, use /rstart" )
	end
end

addCommandHandler ( "rstop", stopRec )

function playRec ( commandName, idx )
	if ( getElementData(getLocalPlayer(),"rec.busy") == false ) then
		if playVehicle then outputChatBox ( "Previous vehicle found, destroying." ); destroyElement ( playVehicle ) end
		outputChatBox ( "Sending playback request." )
		id = tonumber(idx)
		beginData = split ( recordings[id], string.byte(",") )
		posRotData = split ( recordingsPosrot[id], string.byte("_") )
		--setElementPosition ( getLocalPlayer(), beginData[1], beginData[2], beginData[3]+5 )
		callServerFunction ( "setUpRec", beginData[7], beginData[1], beginData[2], beginData[3], beginData[4], beginData[5], beginData[6], getLocalPlayer() )
		--addEventHandler ( "onClientPreRender", getRootElement(), renderPlay )
		--setTimer ( removeEventHandler, beginData[8], 1, "onClientRender", getRootElement(), renderPlay )
		--setTimer ( function()
		--nowPlayingPosrotSlot = 1
		--[[nowPlayingTimer = setTimer ( function() 
			local posRotMinData = split ( posRotData[nowPlayingPosrotSlot], string.byte(",") )
			setElementPosition ( getPedOccupiedVehicle ( getLocalPlayer() ), posRotMinData[1], posRotMinData[2], posRotMinData[3] )
			setElementRotation ( getPedOccupiedVehicle ( getLocalPlayer() ), posRotMinData[4], posRotMinData[5], posRotMinData[6] )
			setElementVelocity ( getPedOccupiedVehicle ( getLocalPlayer() ), posRotMinData[7], posRotMinData[8], posRotMinData[9] )
			setVehicleTurnVelocity ( getPedOccupiedVehicle ( getLocalPlayer() ), posRotMinData[10], posRotMinData[11], posRotMinData[12] )
			nowPlayingPosrotSlot = nowPlayingPosrotSlot + 1
		end, 50, 0 )
		local playData = split ( splitSlash[1], string.byte(".") )
		for i=1, #playData do
			delayTicks[i] = getTickCount ( )
			local thisData = split ( playData[i], string.byte(",") )
			local thisDelay = 0
			if ( i > 1 ) then thisDelay = getTickCount() - delayTicks[i-1] end
			setTimer ( function() if ( i == #playData ) then killTimer ( nowPlayingTimer ) end setControlState ( thisData[1], true ); setTimer ( setControlState, thisData[3]-thisDelay, 1, thisData[1], false ); end, thisData[2]-thisDelay, 1 )
		end
		end, 4000, 1 )]]
	else
		outputChatBox ( "You are recording or playing a record. Please stop this operation before playing." )
	end
end

function startPlaying ( vehicle )
	playVehicle = vehicle
	addEventHandler ( "onClientPreRender", getRootElement(), renderPlay )
	outputChatBox ( "Now playing ID "..#recordings..". To stop, use /pstop" )
	nowPlayingPosrotSlot = 1
	setElementData ( getLocalPlayer(), "rec.busy", true )
end

function stopPlayback ( )
	if ( getElementData(getLocalPlayer(),"rec.busy") == true ) then
		removeEventHandler ( "onClientPreRender", getRootElement(), renderPlay )
		setElementData ( getLocalPlayer(), "rec.busy", false )
		outputChatBox ( "Vehicle damaged, stopping playback." )
	end
end

addCommandHandler ( "pstart", playRec )
addCommandHandler ( "pstop", function() setElementData ( getLocalPlayer(), "rec.busy", false ) outputChatBox ( "Playback stopped.") removeEventHandler ( "onClientPreRender", getRootElement(), renderPlay ) end )

function callServerFunction(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    triggerServerEvent("onClientCallsServerFunction", root, funcname, unpack(arg))
end

function callClientFunction(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do arg[key] = tonumber(value) or value end
    end
    loadstring("return "..funcname)()(unpack(arg))
end
addEvent("onServerCallsClientFunction", true)
addEventHandler("onServerCallsClientFunction", root, callClientFunction)