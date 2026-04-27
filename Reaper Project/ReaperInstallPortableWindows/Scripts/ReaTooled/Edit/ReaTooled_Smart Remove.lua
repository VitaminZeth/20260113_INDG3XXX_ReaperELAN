-- @description ReaTooled - Smart Remove
-- @version 1.6
-- @date 2024.12.22
-- @author Brendan Baker - but really modified from Smart remove by Rodrigo Diaz (aka Rodilab)
-- @link https://brendanpatrickbaker.com/reatooled/
-- @about
--   If time selection is set and last focus on items, then cut selected area of items. ReaTooled Added: also clear time selection and loop points
--   ReaTooled Added: Else if time selection is not set and last focus is on items, remove item and move edit cursor to left edge of item
--   Else, remove items/tracks/envelope points (depending on focus)
--   ## bugfix to move edit cursor to item start in corner cases 
--   ## v1.4 change "cut" to "remove"
--   ## v1.5 Disable move cursor to item (PT-like cursor movement is handled via Mouse Modifiers)
--   ## v1.6 Revise edit cursor behavior to move edit cursor to item's former start position if item was selected

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

local time_sel_start, time_sel_end = reaper.GetSet_LoopTimeRange(false,false,0,0,false)
local focus = reaper.GetCursorContext2(true)
local window, segment, details = reaper.BR_GetMouseCursorContext()

if time_sel_end - time_sel_start > 0 and focus == 1 then --If there's a time selection and item is selected
  -- Cut selected area of items
  reaper.Main_OnCommand(40312,0) -- remove selected area
  reaper.Main_OnCommand(40020,0) -- remove time selection
elseif time_sel_end - time_sel_start == 0 and focus == 1 then
    reaper.Main_OnCommand(41173,0) -- Item navigation: move cursor to item
    reaper.Main_OnCommand(40697,0) -- Remove items/tracks/envelope points (depending on focus)
else
  if window == "tcp" and segment == "envelope" then
    
    reaper.Main_OnCommand(40065,0) -- Remove envelope
  else
    
    reaper.Main_OnCommand(40697,0) -- Remove items/tracks/envelope points (depending on focus)
  end
end

reaper.Undo_EndBlock("Smart remove",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
