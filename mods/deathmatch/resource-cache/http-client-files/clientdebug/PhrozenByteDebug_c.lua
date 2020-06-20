-- PhrozenByte Debug
--
-- Copyright (C) 2015-2018  Daniel Rudolf <http://www.daniel-rudolf.de/>
--
-- This program is free software: you can redistribute it and/or modify it
-- under the terms of the GNU Affero General Public License as published
-- by the Free Software Foundation, version 3 of the License only.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

DEBUG_LEVEL = 0

onScreenLog = {
    ["_index"] = 0,
    ["_length"] = 0,
    ["_columnLength"] = { ["left"] = 0, ["center"] = 0, ["right"] = 0 },
    ["_sources"] = {},
    ["_simple"] = {}
}

-- extend the functionality of the debugscript command
addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        if (isDebugViewActive()) then
            -- MTA provides no way to determine the current debug level of a client,
            -- assume a active debug view means level 3...
            outputChatBox("debugscript: Starting PhrozenByte Debug", 255, 165, 0)

            DEBUG_LEVEL = 3
            updateDebugLevel()
        end
		function (commandName, level)
        level = tonumber(level)
        if (level == nil) then
            -- executing /debugscript without a argument outputs the server's debug level
            -- we don't have to request the permission, we're checking the ACL server-side anyway
            requestServerDebugLevel("onOutputServerDebugLevel")
        else
            DEBUG_LEVEL = level
            triggerServerEvent("onRequestDebugPermission", resourceRoot, resourceRoot, "onReturnDebugPermission")
        end
    end
    end
)

addEvent("onDebugLevelUpdate")
function updateDebugLevel()
    notice("PhrozenByte Debug: Client-side debug level is now " .. DEBUG_LEVEL)

    triggerServerEvent("onDebugLevelUpdate", resourceRoot, DEBUG_LEVEL)
    triggerEvent("onDebugLevelUpdate", resourceRoot, DEBUG_LEVEL)

    requestServerDebugLevel("onOutputServerDebugLevel")
end

addCommandHandler("debugscript",
    function (commandName, level)
        level = tonumber(level)
        if (level == nil) then
            -- executing /debugscript without a argument outputs the server's debug level
            -- we don't have to request the permission, we're checking the ACL server-side anyway
            requestServerDebugLevel("onOutputServerDebugLevel")
        else
            DEBUG_LEVEL = level
            triggerServerEvent("onRequestDebugPermission", resourceRoot, resourceRoot, "onReturnDebugPermission")
        end
    end
)

addEvent("onReturnDebugPermission", true)
addEventHandler("onReturnDebugPermission", resourceRoot,
    function (hasDebugPermission)
        if (hasDebugPermission) then
            updateDebugLevel()
        else
            -- no permission to change the debug level
            DEBUG_LEVEL = 0
        end
    end
)

addEvent("onOutputServerDebugLevel", true)
addEventHandler("onOutputServerDebugLevel", resourceRoot,
    function (level)
        outputChatBox("debugscript: The server's debug mode is " .. tonumber(level), 255, 165, 0)
    end
)

--
-- returns the current debug level of this client [exported function]
--
function getDebugLevel()
    return DEBUG_LEVEL
end

--
-- outputs a client debug string only if the specified level is lower or
-- equal to the current debug level of the client [exported function]
--
function log(level, text, red, green, blue)
    level = (tonumber(level) or 3)
    red, green, blue = (tonumber(red) or 255), (tonumber(green) or 255), (tonumber(blue) or 255)

    if ((level < 1) or (level > 3)) then
        error("PhrozenByte Debug: Bad argument @ 'log' [Expected integers 1, 2 or 3 at argument 2, got " .. level .."]")
        return false
    end
    if (type(text) ~= "string") then
        error("PhrozenByte Debug: Bad argument @ 'log' [Expected string at argument 1, got " .. type(text) .."]")
        return false
    end

    if (level <= getDebugLevel()) then
        outputDebugString(text, level, red, green, blue)
    end
    return true
end

-- log() aliases [exported functions]
function error(text, red, green, blue) return log(1, text, red, green, blue) end
function warn(text, red, green, blue) return log(2, text, red, green, blue) end
function notice(text, red, green, blue) return log(3, text, red, green, blue) end

--
-- calls the defined callback with the server's current debug level as argument [exported function]
--
function requestServerDebugLevel(callbackElement, callbackEventName)
    if ((callbackElement ~= nil) and (callbackEventName == nil)) then
        callbackEventName = callbackElement
        callbackElement = resourceRoot
    end

    triggerServerEvent("onRequestDebugLevel", resourceRoot, callbackElement, callbackEventName)
end

--
-- outputs a debug string the same way as log() does, except for the fact,
-- that it outputs it globally (= on the server) [exported function]
--
function serverLog(level, text, red, green, blue)
    level = (tonumber(level) or 3)
    red, green, blue = (tonumber(red) or 255), (tonumber(green) or 255), (tonumber(blue) or 255)

    if ((level < 1) or (level > 3)) then
        error("PhrozenByte Debug: Bad argument @ 'serverLog' [Expected integers 1, 2 or 3 at argument 2, got " .. level .."]")
        return false
    end
    if (type(text) ~= "string") then
        error("PhrozenByte Debug: Bad argument @ 'serverLog' [Expected string at argument 1, got " .. type(text) .."]")
        return false
    end

    triggerServerEvent("onOutputServerLog", resourceRoot, level, text, red, green, blue)
    return true
end

-- serverLog() aliases [exported functions]
function serverError(text, red, green, blue) return serverLog(1, text, red, green, blue) end
function serverWarn(text, red, green, blue) return serverLog(2, text, red, green, blue) end
function serverNotice(text, red, green, blue) return serverLog(3, text, red, green, blue) end

--
-- returns the number of reserved on-screen log rows [exported function]
--
function getOnScreenLogCount(column)
    if (not column) then
        return onScreenLog._length
    elseif ((column == "left") or (column == "center") or (column == "right")) then
        return onScreenLog._columnLength[column]
    else
        return nil
    end
end

--
-- initializes a new on-screen log [exported function]
--
function initOnScreenLog(source, message, pauseUpdate, textAlign, red, green, blue, alpha)
    if (getDebugLevel() < 3) then return false end

    if (not isElement(source)) then source, message, pauseUpdate, textAlign, red, green, blue, alpha = nil, source, message, pauseUpdate, textAlign, red, green, blue end

    source = (isElement(source) and (getElementType(source) == "resource") and getElementID(source) or nil)
    message = (message and tostring(message) or "")
    pauseUpdate = (tonumber(pauseUpdate) or 0)
    textAlign = (textAlign and tostring(textAlign) or "center")
    red, green, blue, alpha = (tonumber(red) or 255), (tonumber(green) or 255), (tonumber(blue) or 255), (tonumber(alpha) or 255)

    notice("PhrozenByte Debug: initOnScreenLog(" .. (source or "nil") .. ", \"" .. message .. "\", " .. pauseUpdate .. ", "
        .. textAlign .. ", " .. red .. ", " .. green .. ", " .. blue .. ", " .. alpha .. ")")

    -- prepare log data
    onScreenLog._index = onScreenLog._index + 1
    local logID = onScreenLog._index

    logData = {}
    logData.source = source
    logData.message = message
    logData.textAlign = textAlign
    logData.textColor = tocolor(red, green, blue, alpha)
    logData.pauseUpdate = pauseUpdate
    logData.nextUpdate = 0
    logData.data = nil
    logData.calc = nil

    -- remember what resource registered this on-screen log
    if (source) then
        if (not onScreenLog._sources[source]) then onScreenLog._sources[source] = {} end
        table.insert(onScreenLog._sources[source], logID)
    end

    -- store log data
    onScreenLog[logID] = logData

    -- increment log length
    onScreenLog._length = onScreenLog._length + 1
    if (onScreenLog._columnLength[logData.textAlign]) then
        onScreenLog._columnLength[logData.textAlign] = onScreenLog._columnLength[logData.textAlign] + 1
    end

    return logID
end

--
-- removes a on-screen log [exported function]
--
function clearOnScreenLog(logID)
    local logData = onScreenLog[logID]
    if (logData) then
        notice("PhrozenByte Debug: clearOnScreenLog(" .. logID .. ")")

        -- update list of on-screen logs used by the source resource
        if (logData.source and onScreenLog._sources[logData.source]) then
            for key,checkLogID in ipairs(onScreenLog._sources[logData.source]) do
                if (checkLogID == logID) then
                    table.remove(onScreenLog._sources[logData.source], key)
                    break
                end
            end

            if (#onScreenLog._sources[logData.source] == 0) then
                onScreenLog._sources[logData.source] = nil
            end
        end

        -- decrement log length
        onScreenLog._length = onScreenLog._length - 1
        if (onScreenLog._columnLength[logData.textAlign]) then
            onScreenLog._columnLength[logData.textAlign] = onScreenLog._columnLength[logData.textAlign] - 1
        end

        -- clear log data
        onScreenLog[logID] = nil
    end
end

addEventHandler("onClientResourceStop", getRootElement(),
    function (resource)
        -- clear all on-screen logs of this resource
        local resourceName = getResourceName(resource)
        if (onScreenLog._sources[resourceName]) then
            for _,logID in ipairs(onScreenLog._sources[resourceName]) do
                if (onScreenLog[logID]) then
                    onScreenLog[logID].source = nil
                    clearOnScreenLog(logID)
                end
            end

            onScreenLog._sources[resourceName] = nil
        end
    end
)

--
-- updates the data of a initialized on-screen log [exported function]
--
function updateOnScreenLog(logID, data, calcMode)
    data = ((type(data) == "table") and data or {})

    local logData = onScreenLog[logID]
    if (not logData) then return false end

    if (calcMode == nil) then
        if (getTickCount() >= logData.nextUpdate) then
            logData.nextUpdate = getTickCount() + logData.pauseUpdate

            -- draw unchanged data
            logData.data = data
            logData.calc = nil
        end
    else
        -- malicious calc
        if (logData.calc and (logData.calc.mode == false)) then
            return false
        end

        if ((logData.calc == nil) or (logData.calc.mode ~= calcMode)) then
            -- prepare new calc data
            logData.calc = {}
            logData.calc.mode = calcMode
            logData.calc.count = 0

            logData.calc.data = {}
            for key,value in ipairs(data) do
                -- use numeric values for calculations only
                value = tonumber(value)
                if (value ~= nil) then
                    logData.calc.data[key] = value
                end
            end

            logData.data = data
        else
            -- update calc data
            if (calcMode == "avg") then
                for key,value in ipairs(logData.calc.data) do
                    local newValue = tonumber(data[key])
                    if (newValue ~= nil) then
                        logData.calc.data[key] = (((value * logData.calc.count) + newValue) / (logData.calc.count + 1))
                    end
                end
            elseif (calcMode == "total") then
                for key,value in ipairs(logData.calc.data) do
                    logData.calc.data[key] = (value + (tonumber(data[key]) or 0))
                end
            elseif (calcMode == "count") then
                for key,value in ipairs(logData.calc.data) do
                    if (logData.calc.count == 0) then
                        value = tonumber(value)
                        logData.calc.data[key] = ((value and (value > 0)) and 1 or 0)
                        value = logData.calc.data[key]
                    end

                    local newValue = tonumber(data[key])
                    logData.calc.data[key] = (value + ((newValue and (newValue > 0)) and 1 or 0))
                end
            else
                error("Bad argument @ 'updateOnScreenLog' [Expected string 'avg', 'total' or 'count' at argument 3, got " .. calcMode .. "]")
                logData.calc.mode = false
                return false
            end
        end

        -- increment calc count
        logData.calc.count = logData.calc.count + 1

        -- draw calculated data
        if (getTickCount() >= logData.nextUpdate) then
            logData.nextUpdate = getTickCount() + logData.pauseUpdate

            logData.calc.count = 0
            for key,value in ipairs(data) do
                if (logData.calc.data[key] ~= nil) then
                    logData.data[key] = logData.calc.data[key]
                    logData.calc.data[key] = tonumber(value)
                else
                    logData.data[key] = value
                end
            end
        end
    end

    return true
end

--
-- shows a simple on-screen log; no need for init and clear calls, however, no calcs,
-- no update pause and the function must be called for every frame [exported function]
--
function simpleOnScreenLog(message, data, textAlign, red, green, blue, alpha)
    if (getDebugLevel() < 3) then return false end

    message = (message and tostring(message) or "")
    data = ((type(data) == "table") and data or {})
    textAlign = (textAlign and tostring(textAlign) or "center")
    red, green, blue, alpha = (tonumber(red) or 255), (tonumber(green) or 255), (tonumber(blue) or 255), (tonumber(alpha) or 255)

    local logData = {}
    logData.message = (data and (#data > 0) and string.format(message, unpack(data)) or message)
    logData.textAlign = textAlign
    logData.textColor = tocolor(red, green, blue, alpha)

    table.insert(onScreenLog._simple, logData)
    return true
end

--
-- draw on-screen log
--
function drawOnScreenLog()
    local rowCount = { ["left"] = 0, ["center"] = 0, ["right"] = 0 }

    for logID = 1, onScreenLog._index do
        local logData = onScreenLog[logID]
        if (logData) then
            local message = logData.message
            if (logData.data and (#logData.data > 0)) then
                message = string.format(message, unpack(logData.data))
            end

            if (rowCount[logData.textAlign]) then rowCount[logData.textAlign] = rowCount[logData.textAlign] + 1 end
            drawOnScreenText(message, rowCount[logData.textAlign], logData.textAlign, logData.textColor)
        end
    end

    for _,logData in ipairs(onScreenLog._simple) do
        if (rowCount[logData.textAlign]) then rowCount[logData.textAlign] = rowCount[logData.textAlign] + 1 end
        drawOnScreenText(logData.message, rowCount[logData.textAlign], logData.textAlign, logData.textColor)
    end
    onScreenLog._simple = {}
end
addEventHandler("onClientRender", root, drawOnScreenLog, true, "low-10")

function drawOnScreenText(message, textRow, textAlign, textColor)
    textRow = (tonumber(textRow) or 0)
    if (textAlign == nil) then textAlign = "center" end
    if (textColor == nil) then textColor = tocolor(255, 255, 255, 255) end

    local textScale = 1
    local width, height = dxGetTextWidth(message, textScale), dxGetFontHeight(textScale)
    local offsetX, offsetY = dxGetTextWidth("X", textScale), (height * 0.25)

    local positionX, positionY = 0, 0
    if (type(textAlign) == "table") then
        positionX, positionY = textAlign
    else
        if (textAlign == "left") then
            positionX = offsetX
        elseif (textAlign == "center") then
            local screenWidth, screenHeight = guiGetScreenSize()
            positionX = ((screenWidth - width) / 2)
        elseif (textAlign == "right") then
            local screenWidth, screenHeight = guiGetScreenSize()
            positionX = (screenWidth - width - offsetY)
        else
            positionX = (tonumber(textAlign) or 0)
        end

        if (textRow > 0) then
            positionY = ((textRow - 1) * (height + 2 * offsetY))
            if (textAlign == "center" ) then positionY = 50 + positionY end
        else
            positionY = offsetY
        end
    end

    dxDrawRectangle((positionX - offsetX), (positionY - offsetY), (width + (2 * offsetX)), (height + (2 * offsetY)), tocolor(0, 0, 0, 100))
    dxDrawText(message, positionX, positionY, positionX, positionY, textColor, textScale)
end

--
-- built-in debug info: client speed and current fps
--
builtInOnScreenDebugID = nil
builtInOnScreenDebugLastUpdate = 0

function updateBuiltInOnScreenDebug()
    local element = getPedOccupiedVehicle(localPlayer)
    if (not element) then element = localPlayer end

    local currentTick = getTickCount()

    local velocityX, velocityY, velocityZ = getElementVelocity(element)
    local currentSpeed = math.sqrt(velocityX ^ 2 + velocityY ^ 2 + velocityZ ^ 2) * 180
    local currentFps = (1000 / (currentTick - builtInOnScreenDebugLastUpdate))
    updateOnScreenLog(builtInOnScreenDebugID, { currentSpeed, currentFps })

    builtInOnScreenDebugLastUpdate = currentTick
end

addEventHandler("onDebugLevelUpdate", resourceRoot,
    function (level)
        if ((builtInOnScreenDebugID == nil) and (level >= 3)) then
            builtInOnScreenDebugID = initOnScreenLog("Speed: %.0f km/h; FPS: %d", 60, "right")
            if (builtInOnScreenDebugID) then addEventHandler("onClientRender", root, updateBuiltInOnScreenDebug) end
        elseif (builtInOnScreenDebugID and (level < 3)) then
            clearOnScreenLog(builtInOnScreenDebugID)
            removeEventHandler("onClientRender", root, updateBuiltInOnScreenDebug)
        end
    end
)
