-- Function to check if Ripple editing per-track mode is enabled
function isRipplePerTrackEnabled()
    local enabled = reaper.GetToggleCommandState(40310) -- Ripple editing per-track mode action ID
    return enabled == 1
end

-- Function to check if Ripple editing all tracks mode is enabled
function isRippleAllTracksEnabled()
    local enabled = reaper.GetToggleCommandState(40311) -- Ripple editing all tracks mode action ID
    return enabled == 1
end

-- Function to check if Ripple edit mode is completely off
function isRippleOff()
    local enabled = reaper.GetToggleCommandState(40309) -- Ripple edit mode off action ID
    return enabled == 1
end

-- Function to set toolbar button state
function setToolbarButtonState(state)
    local commandId = reaper.NamedCommandLookup("_RS92db63d6237bd397c8fb2e69d1bfa8978dbf559f")
    reaper.SetToggleCommandState(0, commandId, state)
    reaper.set_action_options(3)-- | (is_set and 4 or 8))
    reaper.RefreshToolbar2(0, commandId)
end

-- Main function to report all Ripple mode statuses to the console
function reportRippleStatus()
    local ripplePerTrackEnabled = isRipplePerTrackEnabled()
    local rippleAllTracksEnabled = isRippleAllTracksEnabled()
    local rippleOff = isRippleOff()

    if ripplePerTrackEnabled or rippleAllTracksEnabled then
        -- Any Ripple mode is enabled, toolbar button should be OFF
        setToolbarButtonState(0) -- OFF
    else
        -- No Ripple modes are enabled, toolbar button should be ON
        setToolbarButtonState(1) -- ON
    end

    -- Run this script again in 1 second
    reaper.defer(reportRippleStatus)
end

-- Initial run of the function
reportRippleStatus()

-- Execute Ripple edit mode off command at the end
reaper.Main_OnCommand(40309, 0) -- Ripple edit mode off command ID

