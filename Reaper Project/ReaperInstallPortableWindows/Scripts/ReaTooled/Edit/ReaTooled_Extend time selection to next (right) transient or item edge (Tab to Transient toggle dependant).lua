-- @description ReaTooled - Extend time selection + razor area to next (right) transient or item edge
-- @version 1.1
-- @date 2024.11.18
-- @author Brendan Baker
-- @link https://brendanpatrickbaker.com/reatooled/
-- @about
--   # Depending on the state of the ReaTooled Toggle Tab to Transient button,
--   # this script creates or extends a time selection + razor area to the next (right) transient or item edge.
--   # It is meant to replicate the behavior of SHIFT+TAB or SHIFT+' in Pro Tools.
-- CHANGELOG
-- v1.0 - Initial release
-- v1.1 - omit uneeded defer line and correct undo block and selection undo 

function main()
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)

  -- Save the initial time selection to allow undo restoration
  local orig_time_sel_start, orig_time_sel_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)

  -- Begin the script logic
  local cmd_id = reaper.NamedCommandLookup("_RSf475a3ed46e25a1ef9d2a8b4ad6aab87c94102a1")  -- Get ID of ReaTooled Toggle Tab to Transient
  local transient = reaper.GetToggleCommandStateEx(0, cmd_id)  -- Get command state

  reaper.Main_OnCommand(41229, 0)  -- "Selection set: Save set #01"
  reaper.Main_OnCommand(40421, 0)  -- "Item: Select all items in track"

  -- Get the current time selection (start and end)
  local time_sel_start, time_sel_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)

  -- Get current edit cursor position
  local cursor_pos = reaper.GetCursorPosition()

  -- Record Location 1 as the current edit cursor position
  local location_1 = cursor_pos
  local location_2, location_3  -- Declare variables for future positions

  if transient == 1 then
    reaper.Main_OnCommand(40802, 0)  -- "Time selection: Extend time selection to next transient in items"
    reaper.Main_OnCommand(41239, 0)  -- "Selection set: Load set #01"
  else
    if time_sel_start == time_sel_end then
      -- No time selection, move cursor to right edge of the nearest item (Location 2)
      reaper.Main_OnCommand(40319, 0)  -- "Move cursor right to edge of item"
      location_2 = reaper.GetCursorPosition()

      -- Create time selection between Location 1 and Location 2
      reaper.GetSet_LoopTimeRange(true, false, location_1, location_2, false)

      -- Move the edit cursor back to Location 1
      reaper.SetEditCurPos2(0, location_1, false, false)
    else
      -- Time selection exists, move the cursor to the end of the time selection
      reaper.SetEditCurPos2(0, time_sel_end, false, false)

      -- Move cursor to right edge of the nearest item (Location 3)
      reaper.Main_OnCommand(40319, 0)  -- "Move cursor right to edge of item"
      location_3 = reaper.GetCursorPosition()

      -- Create time selection between Location 1 and Location 3
      reaper.GetSet_LoopTimeRange(true, false, location_1, location_3, false)

      -- Move the edit cursor back to Location 1
      reaper.SetEditCurPos2(0, location_1, false, false)
    end
  end

  -- Select all items within the new time selection
  reaper.Main_OnCommand(40718, 0)  -- "Select all items within the time selection"

  -- Convert the current time selection into a Razor Edit area
  local time_start, time_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  if time_start == time_end then return false end

  local count_sel_tracks = reaper.CountSelectedTracks(0)
  local count_tracks = reaper.CountTracks(0)

  

  for i = 0, count_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    if count_sel_tracks == 0 or reaper.IsTrackSelected(track) then
      local razor_str = time_start .. " " .. time_end .. ' ""'
      reaper.GetSetMediaTrackInfo_String(track, "P_RAZOREDITS", razor_str, true)
    end
  end

  reaper.PreventUIRefresh(-1)

  -- End undo block (Reaper's undo system will restore time selection automatically when undone)
  reaper.Undo_EndBlock("Create rightward time selection and razor edit area", -1)
end

main()

