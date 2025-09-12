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
local shader = require("scripts.ErnBright.shader")
local pself = require("openmw.self")
local async = require("openmw.async")

local interiorShaders = {}
local exteriorShaders = {}

local function loadShaders(nameCSV)
    local out = {}
    for elem in string.gmatch(nameCSV, "[^,]+") do
        print("Loading shader " .. tostring(elem) .. ".")
        table.insert(out, shader.NewShader(elem))
    end
    return out
end

local function enableShaders(shaderCollection, enable)
    for _, s in ipairs(shaderCollection) do
        s:enable(enable)
    end
end

local disableShaderAtFrameDuration = 0
local enableShaderAtFrameDuration = 0
local interiorCondition = ""
local exteriorCondition = ""

local inExterior = nil

-- Ensure settings are re-applied.
local function applySettings()
    disableShaderAtFrameDuration = 1.0 / settings:get('disableAt')
    enableShaderAtFrameDuration = 1.0 / settings:get('enableAt')
    interiorCondition = settings:get('interior')
    exteriorCondition = settings:get('exterior')

    enableShaders(interiorShaders, false)
    enableShaders(exteriorShaders, false)
    print("Interior Shaders:" .. tostring(settings:get('interiorShaders')))
    interiorShaders = loadShaders(settings:get('interiorShaders'))
    print("Exterior Shaders:" .. tostring(settings:get('exteriorShaders')))
    exteriorShaders = loadShaders(settings:get('exteriorShaders'))

    -- even though this is not a setting, we reset it to nil
    -- so the shaders will re-apply later.
    inExterior = nil
end

applySettings()
settings:subscribe(async:callback(function(_, key)
    print("Settings changed.")
    applySettings()
end))

local frameDuration = onlineStats.NewSampleCollection(180)

--local enabled = false

local function onFrame(dt)
    -- don't do anything while paused.
    if dt == 0 then
        return
    end

    -- update running average
    local frameDur = core.getRealFrameDuration()
    frameDuration:add(frameDur)
end

local function onUpdate(dt)
    -- We moved between interior and exterior.
    local swapped = pself.cell.isExterior ~= inExterior or inExterior == nil
    if swapped then
        -- Ensure the old set of shaders is disabled.
        inExterior = pself.cell.isExterior
        if inExterior then
            enableShaders(interiorShaders, false)
        else
            enableShaders(exteriorShaders, false)
        end
    end

    -- Absolutist overrides.
    if inExterior then
        if exteriorCondition == "never" then
            --enabled = false
            enableShaders(exteriorShaders, false)
            return
        elseif exteriorCondition == "always" or swapped then
            --enabled = true
            enableShaders(exteriorShaders, true)
            return
        end
    else
        if interiorCondition == "never" then
            --enabled = false
            enableShaders(interiorShaders, false)
            return
        elseif interiorCondition == "always" or swapped then
            --enabled = true
            enableShaders(interiorShaders, true)
            return
        end
    end

    -- We're going to dynamically enable the shader now.
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
    if (stats.mean >= disableShaderAtFrameDuration) then
        --[[print("Disabling shaders. FrameDuration: " ..
            string.format("%.3f", stats.mean) ..
            " Threshold: " ..
            string.format("%.3f", enableShaderAtFrameDuration) ..
            " StdDev: " .. string.format("%.3f", math.sqrt(stats.variance)))]]
        if inExterior then
            enableShaders(exteriorShaders, false)
        else
            enableShaders(interiorShaders, false)
        end
        --enabled = false
        return
    end
    if (stats.mean <= enableShaderAtFrameDuration) then
        -- we are fast and not using the shader, so enable it
        --[[print("Enabling shaders. FrameDuration: " ..
            string.format("%.3f", stats.mean) ..
            " Threshold: " ..
            string.format("%.3f", enableShaderAtFrameDuration) ..
            " StdDev: " .. string.format("%.3f", math.sqrt(stats.variance)))]]
        if inExterior then
            enableShaders(exteriorShaders, true)
        else
            enableShaders(interiorShaders, true)
        end
        --enabled = true
        return
    end
end

return {
    engineHandlers = {
        onFrame = onFrame,
        onUpdate = onUpdate
    }
}
