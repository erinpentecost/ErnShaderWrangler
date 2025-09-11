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
local postprocessing = require('openmw.postprocessing')
local core = require('openmw.core')
local onlineStats = require("scripts.ErnBright.onlineStats")
local settings = require("scripts.ErnBright.settings")
local async = require("openmw.async")

local shader = postprocessing.load("bright")
shader:enable()

local inExterior = false

local disableShaderAtFrameDuration = 1.0 / settings:get('disableAt')
local enableShaderAtFrameDuration = 1.0 / settings:get('enableAt')

settings:subscribe(async:callback(function(_, key)
    print("Settings changed.")
    disableShaderAtFrameDuration = 1.0 / settings:get('disableAt')
    enableShaderAtFrameDuration = 1.0 / settings:get('enableAt')
end))

local enabled = true

local frameDuration = onlineStats.NewSampleCollection(180)

local function disableShader(dt)
    enabled = false
    shader:disable()
end

local function enableShader(dt)
    enabled = true
    shader:enable()
end

enableShader(0)

local function onFrame(dt)
    -- don't do anything while paused.
    if dt == 0 then
        return
    end

    local frameDur = core.getRealFrameDuration()
    -- update running average
    frameDuration:add(frameDur)
    local stats = frameDuration:calculate()
    if stats == nil then
        return
    end

    if stats.variance > 2.5e-05 then
        -- stdev over 0.015 is variance > 0.000225
        -- this is basically +or- .02 seconds per frame
        --print("Detected FPS instability. FrameDuration: " ..
        --    string.format("%.3f", stats.mean) .. " StdDev: " .. string.format("%.3f", math.sqrt(stats.variance)))
        -- fps is too wild. do nothing.
        return
    end

    -- if FPS drops below 20, turn the shader off.
    if (stats.mean >= disableShaderAtFrameDuration) and enabled then
        print("Disabling bright shader. FrameDuration: " ..
            string.format("%.3f", stats.mean) ..
            " Threshold: " ..
            string.format("%.3f", enableShaderAtFrameDuration) ..
            " StdDev: " .. string.format("%.3f", math.sqrt(stats.variance)))
        disableShader(frameDur)
        return
    end
    if (stats.mean <= enableShaderAtFrameDuration) and not enabled then
        -- we are fast and not using the shader, so enable it
        print("Enabling bright shader. FrameDuration: " ..
            string.format("%.3f", stats.mean) ..
            " Threshold: " ..
            string.format("%.3f", enableShaderAtFrameDuration) ..
            " StdDev: " .. string.format("%.3f", math.sqrt(stats.variance)))
        enableShader(frameDur)
        return
    end
end

return {
    engineHandlers = {
        onFrame = onFrame
    }
}
