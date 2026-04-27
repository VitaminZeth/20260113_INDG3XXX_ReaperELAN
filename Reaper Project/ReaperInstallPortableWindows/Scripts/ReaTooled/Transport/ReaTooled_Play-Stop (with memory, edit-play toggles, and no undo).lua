-- @description ReaTooled - Play/Stop with memory and unlinking play and edit cursor
-- @version 1.3.1
-- @date 2024.12.19
-- @author Brendan Baker
-- @link http://brendanpatrickbaker.com/reatooled/
-- @about
--   # This script controls the transport in coordination with two scripts, which control the stop behavior and unlinks the play and edit cursors, 
--   # giving similar functionality to ProTools transport with the "link timeline and edit cursor" and "Insertion follows playback" options.
--   # Keeping both options "on" will result in the typical Reaper behavior
--   # This script was inspired by and builds upon amagalma's script to toggle the behavior of play stop buttons and is built on top of that essential functionality.
--  CHANGELOG
--   v1.3.1 - Further refinements when regions exist in project
--   v1.3 - Revisions to fix creation of unwanted play markers when regions are present in the project, removing old code
--   v1.2 - Time selection is retained when "Cursor follows playback on stop" is disabled
--   v1.1 - add remove razor area and time selection on stop
--   v1.0 - intial release

-- VARIABLES

local reaper = reaper
local init = 0
local markerIndex = -1
  -- Check the toggle state of Ruler script 
local link_state = reaper.GetToggleCommandStateEx(0, reaper.NamedCommandLookup("_RSed328eb507619b18c1154efa1b048d816cfc2d0c"))
    
-- check if Script: ReaTooled_Toggle Edit Cursor follows Playback on Stop.lua is enabled "_RSe16d9e990f3d5fcec42256f63e00086d75b71288" state
local script_state = reaper.GetToggleCommandStateEx(0, reaper.NamedCommandLookup("_RSe16d9e990f3d5fcec42256f63e00086d75b71288"))
local playstate = reaper.GetPlayState()   
local play_marker = "▶"
local marker_color = reaper.ColorToNative(159, 140, 81) |0x1000000
reaper.SetExtState("Play-Stop with memory", "Markername", tostring(play_marker), 0)
local markerName = reaper.GetExtState("Play-Stop with memory", "Markername")
local storedMarkerPosition = nil
local _, num_markers, _ = reaper.CountProjectMarkers(0)

--Gets the current and previous positions of the Edit cursor, Play Cursor, and Play Marker (play marker is set to 0 if not present)
local current_edit_pos = reaper.GetCursorPosition()
reaper.SetExtState("Play-Stop with memory", "CurrentEditPosition", tostring(current_edit_pos), false)
local current_play_pos = reaper.GetPlayPosition()
reaper.SetExtState("Play-Stop with memory", "CurrentPlayPosition", tostring(current_play_pos), false)
local prev_edit_pos = reaper.GetExtState("Play-Stop with memory", "PrevEditPosition") or tonumber(current_edit_pos)


-- FUNCTIONS


-- Gets the position of the Play Marker by its name and saves it as "CurrentMarkerPosition"
function GetPlayMarkerPositionByName(play_marker)
    local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
    
    for i = 0, num_markers + num_regions - 1 do
        local _, isrgn, position, _, name, _ = reaper.EnumProjectMarkers3(0, i)
        
        -- Check if it's a marker (not a region) and if the name matches the play_marker
        if not isrgn and name == play_marker then
            -- Save the position to a variable
            reaper.SetExtState("Play-Stop with memory", "CurrentMarkerPosition", tostring(position), false)
            
            -- Exit the loop after finding the first matching marker
            break
        end
    end
end

-- Function to delete all markers with the label "▶"
function DeleteMarkersByName(play_marker)
    -- Get the number of project markers
    local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
    -- Iterate through all markers and regions
    for i = num_markers + num_regions - 1, 0, -1 do
        local _, is_region, position, _, name, marker_index = reaper.EnumProjectMarkers(i)
        -- Check if the marker is not a region and matches the label "▶"
        if not is_region and name == "▶" then
            reaper.DeleteProjectMarker(0, marker_index, false)
        end
    end

    -- Refresh the arrange view to reflect changes
    reaper.UpdateArrange()
end

--Function to play the transport from the location of the edit cursor
function PlayFromEditCursor()
  DeleteMarkersByName(play_marker)
  reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tostring(current_edit_pos), 0)
  reaper.SetEditCurPos2(0, tonumber(current_edit_pos) or tonumber(init), false, false)
  reaper.AddProjectMarker2(0, false, tostring(reaper.GetExtState("Play-Stop with memory", "NextPlayPosition")), 0, markerName, 0, tostring(marker_color))
  reaper.Main_OnCommand(1007, 0) -- Transport: Play
  reaper.SetExtState("Play-Stop with memory", "PrevEditPosition", tostring(reaper.GetCursorPosition()), 0)
  GetPlayMarkerPositionByName(play_marker)
  reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
end

--Function to play the transport from the location of the last play cursor position
function PlayFromLastPlayPosition()
  DeleteMarkersByName(play_marker)
  -- Set the next play position to the last known play position
  reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tonumber(reaper.GetExtState("Play-Stop with memory", "CurrentPlayPosition")) or tonumber(current_edit_pos), 0)
  -- Set the edit cursor position to the last known play position
  reaper.SetEditCurPos2(0, tonumber(reaper.GetExtState("Play-Stop with memory", "CurrentPlayPosition")) or tonumber(current_edit_pos), false, false)
  -- Add a project marker at the last known play position
  reaper.AddProjectMarker2(0, false, tostring(reaper.GetExtState("Play-Stop with memory", "NextPlayPosition")), 0, markerName, 0, tostring(marker_color))
  -- Start playback
  reaper.Main_OnCommand(1007, 0) -- Transport: Play
  reaper.SetExtState("Play-Stop with memory", "PrevEditPosition", tostring(reaper.GetCursorPosition()), 0)
  GetPlayMarkerPositionByName(play_marker)
  reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
end

--Function to play the transport from the location of the Play Marker
function PlayFromPlayMarker()
  GetPlayMarkerPositionByName(play_marker)
  local current_marker_pos = reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition") or tonumber(current_edit_pos)
  reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tonumber(current_marker_pos) or tonumber(current_edit_pos), 0)
  DeleteMarkersByName(play_marker)
  reaper.AddProjectMarker2(0, false, tostring(reaper.GetExtState("Play-Stop with memory", "NextPlayPosition")), 0, markerName, 0, tostring(marker_color))
  reaper.SetEditCurPos2(0, tonumber(current_marker_pos) or tonumber(current_edit_pos), false, false)
  -- Start playback
  reaper.Main_OnCommand(1007, 0) -- Transport: Play
  reaper.SetExtState("Play-Stop with memory", "PrevEditPosition", tostring(reaper.GetCursorPosition()), 0)
  GetPlayMarkerPositionByName(play_marker)
  reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
end

--Function to play the transport from the location of the last play marker
function PlayFromLastMarker()
  DeleteMarkersByName(play_marker)
  -- Set the next play position to the last marker position
  reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tonumber(reaper.GetExtState("Play-Stop with memory", "PrevMarkerPosition")) or tonumber(current_edit_pos), 0)
  -- Set the edit cursor position to the last marker position
  reaper.SetEditCurPos2(0, tonumber(reaper.GetExtState("Play-Stop with memory", "PrevMarkerPosition")) or tonumber(current_edit_pos), false, false)
  -- Add a project marker at the last marker position
  reaper.AddProjectMarker2(0, false, tostring(reaper.GetExtState("Play-Stop with memory", "NextPlayPosition")), 0, markerName, 0, tostring(marker_color))
  -- Start playback
  reaper.Main_OnCommand(1007, 0) -- Transport: Play
  reaper.SetExtState("Play-Stop with memory", "PrevEditPosition", tostring(reaper.GetCursorPosition()), 0)
  GetPlayMarkerPositionByName(play_marker)
  reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
end

--
-- MAIN FUNCTION 
--

function Main()
  -- Find the marker by name
  markerIndex = -1 -- Reset markerIndex in each call
  for i = 0, num_markers - 1 do
      local _, isrgn, position, _, _, name, markrgnindexnumber, _ = reaper.EnumProjectMarkers3(0, i)
      if not isrgn and name == markerName then
          markerIndex = markrgnindexnumber
          storedMarkerPosition = position
          break
      end
  end 

  
GetPlayMarkerPositionByName(play_marker)
local current_marker_pos = reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition") or tonumber(current_edit_pos)
local prev_marker_pos = reaper.GetExtState("Play-Stop with memory", "PrevMarkerPosition") or tonumber(current_edit_pos)
   
  -- If Ruler Script is on, then
  if link_state == 1 then
    local playstate = reaper.GetPlayState()
    --If playing (various stop options)
    if playstate > 0 then
 
      
      -- Mode where edit cursor follows the position/play marker, so the edit cursor jumps to the current play marker unless the play marker is moved
      if script_state == 1 then
      
        --if play marker has been moved
        if current_marker_pos ~= prev_marker_pos then 
          DeleteMarkersByName(play_marker)
          --stop
          reaper.Main_OnCommand(1016, 0) -- Transport: stop
          reaper.Main_OnCommand(42406, 0) -- Remove Razor Edit area
          reaper.Main_OnCommand(40635, 0) -- Remove time selection
          --move edit cursor where it needs to go
          reaper.SetEditCurPos2(0, tonumber(current_marker_pos), false, false)
          reaper.AddProjectMarker2(0, false, tonumber(current_marker_pos), 0, markerName, 0, tostring(marker_color))
          GetPlayMarkerPositionByName(play_marker)
          reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
          DeleteMarkersByName(play_marker) -- POTENTIALLY DELETE THIS
          
        --NOTE: there is no dedicated "follow edit cursor" in this mode
      
        else --play marker follows edit
          DeleteMarkersByName(play_marker)
          reaper.SetExtState("Play-Stop with memory", "PrevEditPosition", tostring(current_edit_pos), 0) -- save edit pos for later recall
          reaper.Main_OnCommand(40434, 0) -- View: Move edit cursor to play cursor
          reaper.Main_OnCommand(1016, 0) -- Transport: Stop
          reaper.Main_OnCommand(42406, 0) -- Remove Razor Edit area
          reaper.Main_OnCommand(40635, 0) -- Remove time selection
          local new_play_pos = reaper.GetCursorPosition() -- get position of cursor where it stops
          reaper.AddProjectMarker2(0, false, tonumber(new_play_pos), 0, markerName, 0, tostring(marker_color)) -- sets marker to new cursor position
          GetPlayMarkerPositionByName(play_marker)
          reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0) -- saves marker position for later recall
          reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)  -- saves next play position for later recall    
          DeleteMarkersByName(play_marker) -- POTENTIALLY DELETE THIS
        end
      
      -- Mode where the transport position returns to its original play position  
      else --if script_state == 0 then
      
        if current_marker_pos ~= prev_marker_pos then -- edit follows play marker
          DeleteMarkersByName(play_marker)
          --keep play cursor at new location by not deleting it
          --set next play position to current play marker
          --reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tonumber(current_marker_pos), 0)
          --stop
          reaper.Main_OnCommand(1016, 0) -- Transport: stop
          reaper.Main_OnCommand(42406, 0) -- Remove Razor Edit area
          --reaper.Main_OnCommand(40635, 0) -- Remove time selection
          --move edit cursor where it needs to go
          reaper.SetEditCurPos2(0, tonumber(current_marker_pos), false, false)
          reaper.AddProjectMarker2(0, false, tonumber(current_marker_pos), 0, markerName, 0, tostring(marker_color))
          GetPlayMarkerPositionByName(play_marker)
          reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0) -- saves marker position for later recall
          reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
          DeleteMarkersByName(play_marker)
        else
        -- stop-like stop
          DeleteMarkersByName(play_marker)
          reaper.Main_OnCommand(1016, 0) -- Transport: Stop
          reaper.Main_OnCommand(42406, 0) -- Remove Razor Edit area
          --reaper.Main_OnCommand(40635, 0) -- Remove time selection
          reaper.SetExtState("Play-Stop with memory", "PrevEditPosition", tostring(current_edit_pos), 0)
          reaper.SetExtState("Play-Stop with memory", "CurrentPlayPosition", tostring(current_play_pos), 0)
          reaper.AddProjectMarker2(0, false, reaper.GetExtState("Play-Stop with memory", "PrevEditPosition"), 0, markerName, 0, tostring(marker_color))
          GetPlayMarkerPositionByName(play_marker)
          reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
          reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
          DeleteMarkersByName(play_marker)
        end
      end
      
    -- IF TRANSPORT IS STOPPED -- (Play transport logic)  
      
    else 
      
      -- if Play Marker has moved
      if current_marker_pos ~= prev_marker_pos then
        PlayFromPlayMarker()
        DeleteMarkersByName(play_marker)
      -- if marker stays but edit cursor is moved
      elseif current_marker_pos == prev_marker_pos and current_edit_pos ~= prev_edit_pos then
        PlayFromEditCursor()
        DeleteMarkersByName(play_marker)
      else
        PlayFromEditCursor()
        DeleteMarkersByName(play_marker)
      end
    end
    
  -- EDIT/PLAY MODE: UNLINKED
    
  else --if link_state == 0
    GetPlayMarkerPositionByName(play_marker)
    local current_marker_pos = reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")
    local current_edit_pos = reaper.GetCursorPosition()
    local prev_marker_pos = reaper.GetExtState("Play-Stop with memory", "PrevMarkerPosition")
    
    -- IF TRANSPORT IS PLAYING (Stop transport logic)
    
    if playstate > 0 then 
      
      --if Script is ON, mode where edit cursor is unlinked from the play marker, so the edit cursor returns to its last position
      if script_state == 1 then
      
        if current_marker_pos ~= prev_marker_pos then 
          DeleteMarkersByName(play_marker)
          --stop
          reaper.Main_OnCommand(1016, 0) -- Transport: stop
          reaper.Main_OnCommand(42406, 0) -- Remove Razor Edit area
          --reaper.Main_OnCommand(40635, 0) -- Remove time selection
          reaper.AddProjectMarker2(0, false, tonumber(current_marker_pos), 0, markerName, 0, tostring(marker_color))
          GetPlayMarkerPositionByName(play_marker)
          reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
          reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
          reaper.SetEditCurPos2(0, tonumber(current_edit_pos), false, false)
        else --play marker follows edit
          DeleteMarkersByName(play_marker)
          reaper.SetExtState("Play-Stop with memory", "PrevEditPosition", tostring(current_edit_pos), 0) -- save edit pos for later recall
          reaper.Main_OnCommand(40434, 0) -- View: Move edit cursor to play cursor
          reaper.Main_OnCommand(1016, 0) -- Transport: Stop
          reaper.Main_OnCommand(42406, 0) -- Remove Razor Edit area
          reaper.Main_OnCommand(40635, 0) -- Remove time selection
          local new_play_pos = reaper.GetCursorPosition() -- get position of cursor where it stops
          reaper.AddProjectMarker2(0, false, tonumber(new_play_pos), 0, markerName, 0, tostring(marker_color)) -- sets marker to new cursor position
          GetPlayMarkerPositionByName(play_marker)
          reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0) -- saves marker position for later recall
          reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)  -- saves next play position for later recall    
          reaper.SetEditCurPos2(0, tonumber(current_edit_pos), false, false)
        end
  
      --if script is OFF
      else --if script_state == 0
        
        --if play marker moves, edit follows play marker
        if current_marker_pos ~= prev_marker_pos then 
          DeleteMarkersByName(play_marker)
          reaper.Main_OnCommand(1016, 0) -- Transport: stop
          reaper.Main_OnCommand(42406, 0) -- Remove Razor Edit area
          --reaper.Main_OnCommand(40635, 0) -- Remove time selection
          reaper.SetEditCurPos2(0, tonumber(current_marker_pos), false, false)
          reaper.AddProjectMarker2(0, false, tonumber(current_marker_pos), 0, markerName, 0, tostring(marker_color))
          GetPlayMarkerPositionByName(play_marker)
          reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0) -- saves marker position for later recall
          reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
          reaper.SetEditCurPos2(0, tonumber(current_edit_pos), false, false)
        else -- if play marker hasn't moved
          DeleteMarkersByName(play_marker)
          reaper.Main_OnCommand(1016, 0) -- Transport: Stop
          reaper.Main_OnCommand(42406, 0) -- Remove Razor Edit area
          --reaper.Main_OnCommand(40635, 0) -- Remove time selection
          reaper.SetExtState("Play-Stop with memory", "PrevEditPosition", tostring(current_edit_pos), 0)
          reaper.SetExtState("Play-Stop with memory", "CurrentPlayPosition", tostring(current_play_pos), 0)
          reaper.AddProjectMarker2(0, false, reaper.GetExtState("Play-Stop with memory", "PrevMarkerPosition"), 0, markerName, 0, tostring(marker_color))
          GetPlayMarkerPositionByName(play_marker)
          reaper.SetExtState("Play-Stop with memory", "PrevMarkerPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
          reaper.SetExtState("Play-Stop with memory", "NextPlayPosition", tostring(reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")), 0)
          reaper.SetEditCurPos2(0, tonumber(current_edit_pos), false, false)
        end
      end
    
    -- play transport if stopped, then play logic unlinked from edit cursor  
    else --if playstate == 0 then 
            
      -- checks for play markers and gets position
      GetPlayMarkerPositionByName(play_marker)
      local current_marker_pos = reaper.GetExtState("Play-Stop with memory", "CurrentMarkerPosition")
      local prev_marker_pos = reaper.GetExtState("Play-Stop with memory", "PrevMarkerPosition")
      reaper.SetExtState("Play-Stop with memory", "CurrnetEditPosition", tostring(current_edit_pos), 0)
      reaper.SetExtState("Play-Stop with memory", "CurrentPlayPosition", tostring(current_play_pos), 0)
      local old_edit_pos = reaper.GetExtState("Play-Stop with memory", "EditPosition")
      local old_play_pos = reaper.GetExtState("Play-Stop with memory", "PlayPosition")
      local cmdID = reaper.NamedCommandLookup("_RSe16d9e990f3d5fcec42256f63e00086d75b71288")
      local script_state = reaper.GetToggleCommandStateEx(0, cmdID)
            
      if script_state == 1 then 
                
        if current_marker_pos ~= old_play_pos then -- if marker has been moved, play from new marker position
          PlayFromPlayMarker()
          reaper.SetEditCurPos2(0, tonumber(current_edit_pos), false, false)
        else -- if marker hasn't been moved, play from last play position
          PlayFromLastPlayPosition()
          reaper.SetEditCurPos2(0, tonumber(current_edit_pos), false, false)
        end
          
      else --if script_state == 0 then
        if current_marker_pos ~= prev_marker_pos then -- if marker has been moved, play from new marker position
          PlayFromPlayMarker()
          reaper.SetEditCurPos2(0, tonumber(current_edit_pos), false, false)   
        else -- if marker hasn't been moved, play from previous play position
          PlayFromLastMarker()
          reaper.SetEditCurPos2(0, tonumber(current_edit_pos), false, false)
        end
      end
    end
  end
end
    
-- Schedule the script to run again aftelink_stater a 5-millisecond delay
reaper.defer(Main)


