function gadget:GetInfo()
    return {
        name    = "Ice Handler",
        desc    = "Handles dynamic ice surfaces and transitions",
        author  = "SignedAdam",
        date    = "2025-11-21",
        license = "GPLv2",
        layer   = 0,
        enabled = true
    }
end

-- Only run in synced (game) code
if not gadgetHandler:IsSyncedCode() then
    return
end

-- Alias Spring functions for efficiency
local spGetFeatureDefID      = Spring.GetFeatureDefID
local spGetFeaturePosition   = Spring.GetFeaturePosition
local spCreateFeature        = Spring.CreateFeature
local spGetUnitsInCylinder   = Spring.GetUnitsInCylinder
local spDestroyUnit          = Spring.DestroyUnit

function gadget:FeatureDestroyed(featureID, allyTeam)
    -- When an ice feature is destroyed, spawn the next state and handle units
    local defID = spGetFeatureDefID(featureID)
    if not defID then return end

    local def = FeatureDefs[defID]
    if not def or not def.customParams then return end

    local iceState = def.customParams.ice_state
    if not iceState then return end

    local x, y, z = spGetFeaturePosition(featureID)
    if iceState == "normal" then
        -- initial ice tile destroyed -> spawn broken ice
        spCreateFeature("broken_ice", x, y, z, 0, -1)
    elseif iceState == "broken" then
        -- broken ice destroyed -> kill units and spawn solid block
        -- destroy units on this tile (radius roughly one tile width)
        local units = spGetUnitsInCylinder(x, z, 48) -- 48 elmos ~ 1 footprint
        for i = 1, #units do
            spDestroyUnit(units[i], false, true) -- explode units
        end
        spCreateFeature("ice_block", x, y, z, 0, -1)
    end
end
