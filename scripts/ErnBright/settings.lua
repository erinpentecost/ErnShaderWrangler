--[[
ErnBright for OpenMW.
Copyright (C) 2025 Erin Pentecost

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]
local interfaces = require("openmw.interfaces")
local storage = require("openmw.storage")
local MOD_NAME = "ErnBright"

interfaces.Settings.registerPage {
    key = MOD_NAME,
    l10n = MOD_NAME,
    name = "name",
    description = "description"
}
interfaces.Settings.registerGroup {
    key = "Settings" .. MOD_NAME,
    page = MOD_NAME,
    l10n = MOD_NAME,
    name = "settings",
    permanentStorage = true,
    settings = {
        {
            key = "disableAt",
            renderer = "number",
            name = "disableAtName",
            description = "disableAtDesc",
            default = 20,
            argument = {
                min = 1,
                max = 200,
                integer = true,
            },
        },
        {
            key = "enableAt",
            renderer = "number",
            name = "enableAtName",
            description = "enableAtDesc",
            default = 30,
            argument = {
                min = 1,
                max = 200,
                integer = true,
            },
        },
    }
}

return storage.playerSection("Settings" .. MOD_NAME)
