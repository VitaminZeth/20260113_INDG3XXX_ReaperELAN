--[[
    Description: Toggle through different item view modes: Peaks, Spectral Peaks, Spectrogram, Peaks + Spectrogram
    Instructions:
        - Run the script to cycle through different item view modes for selected items
        - Each time you run the script, it will switch to the next view mode
]]

-- Define the list of item view modes to cycle through
local itemViewModes = {
    { name = "Normal Peaks", commandID = 42301 },
    { name = "Normal Peaks + LUFS-S Graph", commandID = 43148 },
    { name = "Spectral Peaks", commandID = 42073 },
    { name = "Spectrogram", commandID = 42294 },
    { name = "Peaks + Spectrogram", commandID = 42295 },
}

-- Function to get the current item view mode index
local function getCurrentItemViewModeIndex()
    for i, viewMode in ipairs(itemViewModes) do
        if reaper.GetToggleCommandState(viewMode.commandID) > 0 then
            return i
        end
    end
    -- If none of the known modes are active, default to the first one
    return 1
end

-- Function to toggle to the next item view mode
local function toggleNextItemViewMode()
    local currentIndex = getCurrentItemViewModeIndex()
    local nextIndex = currentIndex + 1
    if nextIndex > #itemViewModes then
        nextIndex = 1
    end
    local nextMode = itemViewModes[nextIndex]

    -- Send the command to toggle to the next item view mode
    reaper.Main_OnCommand(nextMode.commandID, 0)
    reaper.defer(function() end) -- Prevent REAPER from stopping the script prematurely
    --reaper.ShowConsoleMsg("Item View Mode: " .. nextMode.name .. "\n")
end

-- Toggle to the next item view mode
toggleNextItemViewMode()

