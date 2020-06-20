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

--
-- dumps a variable to the console [exported function]
--
function dump(variable, name, level)
    name = ((type(name) == "string") and name or nil)
    level = (tonumber(level) or 3)

    local debugStrings = {}
    innerDump(debugStrings, 0, name, variable, true)

    log(level, "PhrozenByte Debug: dump(" .. (name or "") .. ")")

    if (triggerClientEvent ~= nil) then
        local players = getElementsByType("player")
        for _,player in ipairs(players) do
            if (level <= getElementData(player, "debugLevel", false)) then
                outputConsole("--[[", player)
                for _,line in ipairs(debugStrings) do
                    outputConsole(line, player)
                end
                outputConsole("--]]", player)
            end
        end
    else
        if (level <= getDebugLevel()) then
            outputConsole("--[[")
            for _,line in ipairs(debugStrings) do
                outputConsole(line)
            end
            outputConsole("--]]")
        end
    end
end

function innerDump(debugStrings, indent, name, variable, isLastValue)
    local indentOutput = string.rep("  ", indent)
    local nameOutput = (name and ("[\"" .. name .. "\"] = ") or "")
    local isLastValueOutput = ((not isLastValue) and "," or "")

    if (type(variable) == "userdata") then
        local typeOutput, valueOutput = "userdata", ""
        if (isElement(variable)) then typeOutput, valueOutput = getElementType(variable), getElementID(variable) end
        table.insert(debugStrings, indentOutput .. nameOutput .. typeOutput .. "(" .. valueOutput .. ")" .. isLastValueOutput)
    elseif (type(variable) == "table") then
        local innerDebugStrings = {}
        local itemCount = 0
        for key,value in pairs(variable) do
            innerDump(innerDebugStrings, indent + 1, key, value, (next(variable, key) == nil))
            itemCount = itemCount + 1
        end

        local typeNameOutput = "table(" .. itemCount .. ", " .. #variable .. ")"
        if (#innerDebugStrings > 0) then
            table.insert(debugStrings, indentOutput .. nameOutput .. typeNameOutput .. " {")
            for _,debugString in ipairs(innerDebugStrings) do table.insert(debugStrings, debugString) end
            table.insert(debugStrings, indentOutput .. "}" .. isLastValueOutput)
        else
            table.insert(debugStrings, indentOutput .. nameOutput .. typeNameOutput .. " {}" .. isLastValueOutput)
        end
    elseif ((type(variable) == "nil") or (type(variable) == "boolean") or (type(variable) == "number")) then
        table.insert(debugStrings, indentOutput .. nameOutput .. tostring(variable) .. isLastValueOutput)
    elseif (type(variable) == "string") then
        table.insert(debugStrings, indentOutput .. nameOutput .. "\"" .. variable .. "\"" .. isLastValueOutput)
    else
        table.insert(debugStrings, indentOutput .. nameOutput .. type(variable) .. "(" .. tostring(variable) .. ")" .. isLastValueOutput)
    end
end

--
-- returns a string representation of a variable [exported function]
--
function get(variable)
    local debugStrings, debugString = {}, ""
    innerDump(debugStrings, 0, nil, variable, true)

    for _,line in ipairs(debugStrings) do
        debugString = debugString .. " " .. line
    end

    return string.sub(debugString, 2)
end
