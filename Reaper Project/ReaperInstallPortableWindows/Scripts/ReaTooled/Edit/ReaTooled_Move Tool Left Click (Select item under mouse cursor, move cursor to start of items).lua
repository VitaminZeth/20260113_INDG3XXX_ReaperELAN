--[[
-- @description ReaTooled - Move Tool Left Click (Group Aware)
-- @version 1.1
-- @date 2024.12.05
-- @author Brendan Baker adapted from TJF/Tim Farrell
-- @link http://brendanpatrickbaker.com/reatooled/
-- @about
   Reaper script to select all items in the group under the mouse cursor and move the edit cursor to the start of the first item without changing the view
  CHANGELOG
  v1.1 Revise to allow for item group selection
--]]

reaper.Undo_BeginBlock()

-- Select item under mouse cursor
reaper.Main_OnCommand(40528, 0)

-- Get the first selected item
local item = reaper.GetSelectedMediaItem(0, 0)

if item then
    -- Select all items in the same group
    reaper.Main_OnCommand(40034, 0) -- Item: Select all items in group
    
    -- Get the start position of the first selected item
    local item_start_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    
    -- Get the current view position
    local original_view_start, original_view_end = reaper.GetSet_ArrangeView2(0, false, 0, 0)
    
    -- Move edit cursor to the start position of the item
    reaper.SetEditCurPos(item_start_pos, false, false)
    
    -- Restore the original view
    reaper.GetSet_ArrangeView2(0, true, 0, 0, original_view_start, original_view_end)
end

reaper.Undo_EndBlock("Select group under mouse and move cursor to start", 0)

