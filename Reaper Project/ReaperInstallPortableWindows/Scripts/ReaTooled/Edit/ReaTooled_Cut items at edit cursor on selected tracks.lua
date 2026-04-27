--[[
-- @description ReaTooled Split Item at Time Selection, otherwise Mouse Cursor
-- @version 1.5
-- @date 2024.02.15
-- @author Brendan Baker modified from TJF/Tim Farrell (http://github.com/sonictim/TJF-Scripts/)
-- @link http://brendanpatrickbaker.com/reatooled/
-- @about
  # Adjusted to work with the modified ReaTooled Hover Edit Mode script ("_RS7cb08a92f7a211ce66734644b4fbe99a91bd42f5")
  # Modified from TJF to resepct grouping 
  # TJF Split Item at Time Selection, otherwise Mouse Cursor
  # CHANGELOG:
  # - v1.5 Added functionality to split items on all tracks intersecting with play cursor when no tracks are selected
  # - v1.4 Added functionality to split items on selected tracks intersecting with play cursor when no selected items intersect with play cursor
  # - v1.3 Added a step to split on selected tracks if no items are selected
  # - v1.2 Default (not hover) split changed to SWS smart split
  
  
  Will also not split if no item is selected.
  Mimics "B" in protools
  Adds Hover Mode Support
  
--]]
reaper.Undo_BeginBlock()

local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds

if start_time ~= end_time then -- if there is a time selection
    reaper.Main_OnCommand(40061, 0) -- Item: Split items at time selection
else
    local cmd_id = reaper.NamedCommandLookup("_RS7cb08a92f7a211ce66734644b4fbe99a91bd42f5") -- get ID of Hover Mode
    local state = reaper.GetToggleCommandStateEx(0,cmd_id) -- get command state

    if state == 1 then
        local current_pos =  reaper.GetCursorPosition()
        local window, segment, details = reaper.BR_GetMouseCursorContext()
        local item = reaper.BR_GetMouseCursorContext_Item()

        if item then
            selected = reaper.IsMediaItemSelected( item )
            
            if not selected then    
                reaper.Main_OnCommand(42575, 0) -- Split Item under mouse cursor
            else
                if reaper.GetSelectedMediaItem(0,0) then  
                    reaper.Main_OnCommand(40514, 0)  -- View: Move edit cursor to mouse cursor (no snapping)
                    reaper.Main_OnCommand(40757, 0)  -- Item: Split items at edit cursor (no change selection)
                    reaper.SetEditCurPos(current_pos, 1, 0)
                end
            end
        end
    else
        local selectedItems = reaper.CountSelectedMediaItems(0)
        local selectedTracks = reaper.CountSelectedTracks(0)
        
        if selectedItems == 0 then
            -- Check if the transport is playing and no tracks are selected
            local playState = reaper.GetPlayState()
            local playCursorPos = reaper.GetPlayPosition()

            if playState & 1 == 1 then -- If playing
                if selectedTracks == 0 then
                    local trackCount = reaper.CountTracks(0)

                    for i = 0, trackCount - 1 do
                        local track = reaper.GetTrack(0, i)
                        local itemCount = reaper.CountTrackMediaItems(track)

                        for j = 0, itemCount - 1 do
                            local item = reaper.GetTrackMediaItem(track, j)
                            local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                            local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

                            if playCursorPos >= itemPos and playCursorPos <= itemPos + itemLength then
                                reaper.SplitMediaItem(item, playCursorPos)
                            end
                        end
                    end
                end
            else
                reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SMARTSPLIT",0),0)
            end
        else
            -- Check if the transport is playing and no selected items intersect with play cursor
            local playState = reaper.GetPlayState()
            local playCursorPos = reaper.GetPlayPosition()

            if playState & 1 == 1 then -- If playing
                for i = 0, selectedTracks - 1 do
                    local track = reaper.GetSelectedTrack(0, i)
                    local itemCount = reaper.CountTrackMediaItems(track)

                    for j = 0, itemCount - 1 do
                        local item = reaper.GetTrackMediaItem(track, j)
                        local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                        local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

                        if playCursorPos >= itemPos and playCursorPos <= itemPos + itemLength then
                            reaper.SplitMediaItem(item, playCursorPos)
                        end
                    end
                end
            else
                reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SMARTSPLIT",0),0)
            end
        end
    end
end

reaper.UpdateArrange() 

reaper.Undo_EndBlock("Split Item(s)", 0)

