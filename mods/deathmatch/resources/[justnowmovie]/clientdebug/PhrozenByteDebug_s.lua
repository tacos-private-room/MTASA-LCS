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

DEBUG_LEVEL_SERVER = 0
DEBUG_LEVEL_CLIENT = 0

addEventHandler("onResourceStart", resourceRoot,
    function ()
        -- update server debug level on startup
        local level = getServerConfigSetting("scriptdebugloglevel")
        DEBUG_LEVEL_SERVER = math.max(DEBUG_LEVEL_SERVER, (tonumber(level) or 0))

        notice("PhrozenByte Debug: Starting with server debug level " .. level)
    end
)

addEvent("onDebugLevelUpdate", true)
addEventHandler("onDebugLevelUpdate", resourceRoot,
    function (level)
        if (client and hasObjectPermissionTo(client, "command.debugscript")) then
            level = (tonumber(level) or 0)
            if ((level >= 0) and (level <= 3)) then
                setElementData(client, "debugLevel", level, false)
                updateClientDebugLevel()

                notice("PhrozenByte Debug: " .. getPlayerName(client) .. "'s debug level is now " .. level)
            end
        end
    end
)

addEventHandler("onPlayerQuit", resourceRoot,
    function ()
        if (DEBUG_LEVEL_CLIENT > 0) then
            setElementData(client, "debugLevel", 0, false)
            updateClientDebugLevel()
        end
    end
)

function updateClientDebugLevel()
    DEBUG_LEVEL_CLIENT = 0

    local players = getElementsByType("player")
    for _,player in ipairs(players) do
        local level = getElementData(player, "debugLevel", false)
        level = (tonumber(level) or 0)

        DEBUG_LEVEL_CLIENT = math.max(DEBUG_LEVEL_CLIENT, level)
    end
end

addCommandHandler("license",
    function (playerSource, commandName, resourceName)
        outputChatBox(" ", playerSource)
        outputChatBox("PhrozenByte Debug", playerSource, 233, 100, 100)
        outputChatBox("Copyright (C) 2015-2016  Daniel Rudolf <http://www.daniel-rudolf.de/>", playerSource, 225, 170, 90)
        outputChatBox("This MTA resource is free software under the terms of the GNU AGPL version 3. It comes with ABSOLUTELY NO WARRANTY.  "
            .. "See MTA's console (press the F8 or ~ key) for details.", playerSource)

        outputConsole(" ", playerSource)
        outputConsole("Please refer to the \"README.md\" and \"DOWNLOAD.md\" files for details. You should have received a copy "
            .. "of them along with the client-side files of this resource (see MTA's resources download directory, usually the "
            .. "\"mods/deathmatch/resources/phrozenbyte-debug/\" folder in the installation path of MTA).", playerSource)
        outputConsole(" ", playerSource)
        outputConsole("This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero "
            .. "General Public License as published by the Free Software Foundation, version 3 of the License only.", playerSource)
        outputConsole(" ", playerSource)
        outputConsole("This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the "
            .. "implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License "
            .. "for more details.", playerSource)
        outputConsole(" ", playerSource)
        outputConsole("You should have received a copy of the GNU Affero General Public License along with this program.  "
            .. "If not, see <http://www.gnu.org/licenses/>.", playerSource)
        outputConsole(" ", playerSource)
    end
)

--
-- returns the current debug level of the server [exported function]
--
function getDebugLevel()
    return math.max(DEBUG_LEVEL_SERVER, DEBUG_LEVEL_CLIENT)
end

--
-- outputs a server debug string only if the specified level is lower or
-- equal to the current debug level of the server [exported function]
--
function log(level, player, text, red, green, blue)
    if ((not isElement(player)) and (type(player) == "string")) then
        -- player argument is optional
        player, text, red, green, blue = nil, player, text, red, green
    end

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

    if (isElement(player) and (getElementType(player) == "player")) then
        text = "[" .. getPlayerName(player) .. "] " .. text
    end

    if (level <= getDebugLevel()) then
        outputDebugString(text, level, red, green, blue)
    end
    return true
end

-- log() aliases [exported functions]
function error(player, text, red, green, blue) return log(1, player, text, red, green, blue) end
function warn(player, text, red, green, blue) return log(2, player, text, red, green, blue) end
function notice(player, text, red, green, blue) return log(3, player, text, red, green, blue) end

--
-- client triggered event: returns whether the client can use debugscript
--
addEvent("onRequestDebugPermission", true)
addEventHandler("onRequestDebugPermission", resourceRoot,
    function (callbackElement, callbackEventName)
        if (client and isElement(callbackElement) and callbackEventName) then
            local hasDebugPermission = hasObjectPermissionTo(client, "command.debugscript")
            triggerClientEvent(client, tostring(callbackEventName), callbackElement, hasDebugPermission)
        end
    end
)

--
-- client triggered event: sends the current debug level of the server to a client
--
addEvent("onRequestDebugLevel", true)
addEventHandler("onRequestDebugLevel", resourceRoot,
    function (callbackElement, callbackEventName)
        if (client and hasObjectPermissionTo(client, "command.debugscript")) then
            if (isElement(callbackElement) and callbackEventName) then
                triggerClientEvent(client, tostring(callbackEventName), callbackElement, getDebugLevel())
            end
        end
    end
)

--
-- client triggered event: outputs a client-side debug string globally
--
addEvent("onOutputServerLog", true)
addEventHandler("onOutputServerLog", resourceRoot,
    function (level, text, red, green, blue)
        if (client and hasObjectPermissionTo(client, "command.debugscript")) then
            log(level, client, text, red, green, blue)
        end
    end
)
