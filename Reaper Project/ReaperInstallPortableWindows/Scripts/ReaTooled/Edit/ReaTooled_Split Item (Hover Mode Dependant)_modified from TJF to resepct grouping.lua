--[[
@description TJF Split Item at Time Selection, otherwise Mouse Cursor
@version 2.01
@author Tim Farrell (Edited by Brendan Baker 2023.11.08)
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Split Item at Time Selection, otherwise Mouse Cursor
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
                            else
                                    if    reaper.GetSelectedMediaItem(0,0)  --check if something is selected
                                    then  
                            
                                        reaper.Main_OnCommand(40514, 0)  -- View: Move edit cursor to mouse cursor (no snapping)
                                        --reaper.Main_OnCommand(40759, 0) -- Item: Split items at edit cursor (select right)
                                        reaper.Main_OnCommand(40757, 0)  -- Item: Split items at edit cursor (no change selection)
                                        reaper.SetEditCurPos(current_pos, 1, 0)
                                    end--if
                            end--if
                            
                        end
                         
              
              else
              
                  reaper.Main_OnCommand(40759, 0) -- Item: Split items at edit cursor (select right)
              
              end--if
      
    end--if
    

    
reaper.Undo_EndBlock("Split", 0)
