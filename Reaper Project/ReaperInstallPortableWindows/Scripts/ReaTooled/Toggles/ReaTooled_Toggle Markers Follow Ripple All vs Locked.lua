--[[
-- @description ReaTooled - Toggle Markers Follow Ripple All vs Locked
-- @version 1.1
@date 2024 03 12
-- @author Brendan Baker
-- @link http://brendanpatrickbaker.com/reatooled/
@about
  Toggles wither markers are locked when Ripple All is activated
  CHANGELOG
  v1.1 + Adds ReaTooled ExtState for later recall
--]]

local reaper = reaper


local cmdID = reaper.NamedCommandLookup("_RSfddebd265f81f5d37380924290732ca9deb3ccee")
local script_state = reaper.GetToggleCommandStateEx(0,cmdID)

if script_state < 1 then 
  script_state = 1
  reaper.Main_OnCommand(40590, 1) -- Clear marker lock 
  reaper.Main_OnCommand(40570, 1) -- Disable lock
  reaper.SetExtState("ReaTooled", "MarkersLockedState", tonumber(1), true)            
else
  script_state = 0
  reaper.Main_OnCommand(40589, 1) -- Set marker lock
  reaper.Main_OnCommand(40569, 1) -- Enable lock
  reaper.SetExtState("ReaTooled", "MarkersLockedState", tonumber(0), true)
  
end


reaper.SetToggleCommandState(0,cmdID, script_state)
reaper.RefreshToolbar2(0,cmdID)



-- No undo point
function NoUndoPoint() end reaper.defer(NoUndoPoint)





