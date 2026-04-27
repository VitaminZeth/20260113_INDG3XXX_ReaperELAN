--[[
-- @description ReaTooled - Toggle Layered Editing (Trim Content Behind Media Items)
-- @version 1.0
-- @date 2024-03-18
-- @author Your Name
-- @link https://www.brendanpatrickbaker.com/reatooled
@about
  Toggles "Trim Content Behind Media Items" on and off, with extstate for later recall
--]]

local reaper = reaper

local cmdID = reaper.NamedCommandLookup("_RS6edf5b85f2b775c4062a4ec0e30bcfabec3c3832") -- Replace with your script's command ID
local script_state = reaper.GetToggleCommandStateEx(0, cmdID)

if script_state < 1 then 
  script_state = 1
  reaper.Main_OnCommand(41121, 0)  -- Disable trim
  reaper.Main_OnCommand(40507, 0)  -- Options: Offset overlapping media items vertically
  reaper.SetExtState("ReaTooled", "LayeredEditingOn", "1", true)            
else
  script_state = 0
  reaper.Main_OnCommand(41120, 0)  -- Enable trim
  reaper.Main_OnCommand(40507, 1)  -- Options: Offset overlapping media items vertically
  reaper.SetExtState("ReaTooled", "LayeredEditingOn", "0", true)
end

reaper.SetToggleCommandState(0, cmdID, script_state)
reaper.RefreshToolbar2(0, cmdID)

-- No undo point
function NoUndoPoint() end
reaper.defer(NoUndoPoint)

