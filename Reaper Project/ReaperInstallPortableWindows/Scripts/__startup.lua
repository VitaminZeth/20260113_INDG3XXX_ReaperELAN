--[[
-- @description ReaTooled - Startup Script
-- @version 1.3
-- @date 2024.12.19
-- @author Brendan Baker
-- @link http://brendanpatrickbaker.com/reatooled/
-- @about
    # Recalls ReaTooled Shortcut State
    CHANGELOG
    v 1.3 - revised script to correctly turn ripple options on
    v 1.2 - Add Options: "Ripple edit when editing media item edges" and "Options: Ripple per-track when ripple is enabled"
    v 1.1 - Revise script logic to recall ReaTooled ExtStates
--]]


reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS28b2f63ccd2b4bcf1f44d9a3a17d59a2212aa5be"), 0) -- Script: ReaTooled_Recall ReaTooled Button States.lua

reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS5e85a066efd01fde2482832bf4a3502dce0427b6"), 0) -- Script: Default Multi Tool (Smart)_ReaTooled.lua

reaper.Main_OnCommand(43467, 1) -- Options: Ripple per-track when ripple is enabled

reaper.Main_OnCommand(43475, 1) -- Options: Ripple edit when editing media item edges