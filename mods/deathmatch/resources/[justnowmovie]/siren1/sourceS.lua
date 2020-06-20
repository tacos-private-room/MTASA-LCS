local attachedLightbars = {}

addEventHandler("onResourceStart", resourceRoot, function()
	for k, v in pairs(getElementsByType("vehicle")) do
		removeVehicleSirens(v)
	end
end)

addEventHandler("onElementDestroy", root, function()
	if getElementType(source) == "vehicle" then
		attachedLightbars[source] = nil
	end
end)

addEvent("requestAttachedLightbarsS", true)
addEventHandler("requestAttachedLightbarsS", root, function()
	triggerClientEvent(source, "receiveAttachedLightbarsC", source, attachedLightbars)
end)

addEvent("attachLightbarS", true)
addEventHandler("attachLightbarS", root, function(data)
	attachedLightbars[source] = data
	triggerClientEvent("attachLightbarC", source, data)

	if sirenPositions[data[1]] then
		addVehicleSirens(source, #sirenPositions[data[1]], 2, false, true, true, true)

		local x, y, z = data[2], data[3], data[4]
		local rx, ry, rz = data[5], data[6], data[7]

		for i = 1, #sirenPositions[data[1]] do
			local value = sirenPositions[data[1]][i]
			
			if value then
				local matrix = createMatrix(x, y, z, rx, ry, rz)
				local ox, oy, oz = getMatrixOffset(matrix, value.x or 0, value.y or 0, value.z or 0)
					
				setVehicleSirens(source, i, ox, oy, oz, value.r, value.g, value.b, value.mina or 180, value.maxa or 200)
			end
		end
	end
end)

addEvent("detachLightbarS", true)
addEventHandler("detachLightbarS", root, function(data)
	attachedLightbars[source] = nil

	triggerClientEvent("detachLightbarC", source, data)
	removeVehicleSirens(source, false)
	setVehicleSirensOn(source, false)
end)

function getMatrixOffset(m, x, y, z)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
			x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
			x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end

function createMatrix(x, y, z, rx, ry, rz)
	rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
	return {
		[1] = {
			[1] = math.cos(rz) * math.cos(ry) - math.sin(rz) * math.sin(rx) * math.sin(ry),
			[2] = math.cos(ry) * math.sin(rz) + math.cos(rz) * math.sin(rx) * math.sin(ry),
			[3] = -math.cos(rx) * math.sin(ry),
			[4] = 1
		},
		[2] = {
			[1] = math.cos(rx) * math.sin(rz),
			[2] = math.cos(rz) * math.cos(rx),
			[3] = math.sin(rx),
			[4] = 1
		},
		[3] = {
			[1] = math.cos(rz) * math.sin(ry) + math.cos(ry) * math.sin(rz) * math.sin(rx),
			[2] = math.sin(rz) * math.sin(ry) - math.cos(rz) * math.cos(ry) * math.sin(rx),
			[3] = math.cos(rx) * math.cos(ry),
			[4] = 1
		},
		[4] = {
			[1] = x,
			[2] = y,
			[3] = z,
			[4] = 1
		}
	}
end