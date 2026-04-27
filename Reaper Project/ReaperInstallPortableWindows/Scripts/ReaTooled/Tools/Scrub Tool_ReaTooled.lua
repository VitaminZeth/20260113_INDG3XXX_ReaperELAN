-- @description ReaTooled - Scrub Tool
-- @version 1.0
-- @date 2024.03.16
-- @author Brendan Baker
-- @link https://brendanpatrickbaker.com/reatooled/
-- @about
--   # This script loads ReaTooled's Scrub Tool

local CMD_ID_1 = reaper.NamedCommandLookup("_RS21aa0b14cf72a27be535d32efe0d05513523aec9")
local CMD_ID_2 = reaper.NamedCommandLookup("_RSd77ea649952c67db183a19cece290cf3e1b3d49d")
local CMD_ID_3 = reaper.NamedCommandLookup("_RSb08c9a159d1a7537eda8df72b777b1cc4c9422e8")
local CMD_ID_4 = reaper.NamedCommandLookup("_RSc2c7d733888679038b4a4341074dc703d0f7f9c2")
local CMD_ID_7 = reaper.NamedCommandLookup("_RS5e85a066efd01fde2482832bf4a3502dce0427b6")

was_set=-1

reaper.Main_OnCommand(42632, 0)

-- Set toolbar button states for additional scripts/buttons
reaper.SetToggleCommandState(0, CMD_ID_1, 0) -- Turn off button 1
reaper.SetToggleCommandState(0, CMD_ID_2, 0) -- Turn off button 2
reaper.SetToggleCommandState(0, CMD_ID_3, 0) -- Turn off button 3
reaper.SetToggleCommandState(0, CMD_ID_4, 0) -- Turn off button 4
reaper.SetToggleCommandState(0, CMD_ID_7, 0) -- Turn off button 7
reaper.SetToggleCommandState(0, reaper.NamedCommandLookup("_RS27973b4ea6ddfabb982b8206b117b31843c68991"), 1) -- scrub tool
reaper.SetToggleCommandState(0, reaper.NamedCommandLookup("_RSb90cf42a9ad3d180fdab1c2fbe82e70a76347b1f"), 0) -- TCE tool
reaper.RefreshToolbar(0)
