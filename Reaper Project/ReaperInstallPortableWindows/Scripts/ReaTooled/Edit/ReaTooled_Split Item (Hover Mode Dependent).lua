--[[
-- @description ReaTooled Split Item at Time Selection, otherwise Mouse Cursor
-- @version 1.4
-- @date 2024.12.02
-- @author Brendan Baker modified from TJF/Tim Farrell (http://github.com/sonictim/TJF-Scripts/)
-- @link http://brendanpatrickbaker.com/reatooled/
-- @about
  # Adjusted to work with the modified ReaTooled Hover Edit Mode script ("_RS7cb08a92f7a211ce66734644b4fbe99a91bd42f5")
  # Modified from TJF to resepct grouping 
  # TJF Split Item at Time Selection, otherwise Mouse Cursor
  # CHANGELOG:
  # - 1.4 - Obey Snapping
  # - 1.3 - change back to select right
  # - v1.1 Default (not hover) split changed to SWS smart split
  
  
  Will also not split if no item is selected.
  Mimics "B" in protools
  Adds Hover Mode Support
  
--]]
reaper.Undo_BeginBlock()

local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds

  if start_time ~= end_time   -- if there is a time selection
  then
          reaper.Main_OnCommand(40061, 0) -- Item: Split items at time selection
  else
      


          local cmd_id = reaper.NamedCommandLookup("_RS7cb08a92f7a211ce66734644b4fbe99a91bd42f5")  --get ID of Hover Mode
          local state = reaper.GetToggleCommandStateEx(0,cmd_id)  -- get command state
                
              if  state==1
              then
              
                       local current_pos =  reaper.GetCursorPosition()
                       local window, segment, details = reaper.BR_GetMouseCursorContext()
                       local item = reaper.BR_GetMouseCursorContext_Item()
                       
                       
                        if item then
                      
                            selected = reaper.IsMediaItemSelected( item )
                            
                            if not  selected 
                            then    
                                    reaper.Main_OnCommand(42575, 0) -- Split Item under mouse cursor
                            else -- (if selected)
                                    if    reaper.GetSelectedMediaItem(0,0)  --check if something is selected
                                    then  
                            
                                        reaper.Main_OnCommand(40513, 0)  -- View: Move edit cursor to mouse cursor
                                        reaper.Main_OnCommand(40759, 0) -- Item: Split items at edit cursor (select right)
                                        --reaper.Main_OnCommand(40757, 0)  -- Item: Split items at edit cursor (no change selection)
                                        reaper.SetEditCurPos(current_pos, 0, 0)
                                    end--if
                            end--if
                            
                        end
                         
              
              else
              
                  --reaper.Main_OnCommand(40759, 0) -- Item: Split items at edit cursor (select right)
                  reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SMARTSPLIT",0),0)
              
              end--if
      
    end--if
    

    
reaper.Undo_EndBlock("Split Item(s)", 0)
