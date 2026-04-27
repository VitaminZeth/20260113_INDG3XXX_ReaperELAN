-- @description ReaTooled - Toggle Link Play Cursor to Edit Cursor
-- @version 1.3
-- @date 2024.11.30
-- @author Brendan Baker
-- @link http://brendanpatrickbaker.com/reatooled/
-- @about
--  This script is meant to mimic the PT toggle "Link Timeline and Edit Selection." 
--  When enabled, the play and edit cursors are "linked" (Reaper's default behavior or un-linked. 
--  When disabled, this toggle works with ReaTooled_Play-Stop (with memory, edit-play toggles, and no undo).lua to create a "play marker," which represents the playhead's next play position after the transport is stopped
--  If you move this Play Marker, the ReaTooled_Play-Stop will play from the last marker position.
--
--  CHANGELOG
--   v1.3 - Change Ruler Left Click to "Custom: Deselect everything (unselect time seleciton and loop points AND clear all razor edit areas AND unselect all tracks/items/envelope points) and move edit cursor"
--   v1.2 - Adds ReaTooled ExtState for later recall
--   v1.1 - updated with script info
--   v1.0 - intial release


local reaper = reaper


local cmdID = reaper.NamedCommandLookup("_RSed328eb507619b18c1154efa1b048d816cfc2d0c")
local script_state = reaper.GetToggleCommandStateEx(0,cmdID)
local play_marker = "▶"
local marker_color = reaper.ColorToNative(159, 140, 81) |0x1000000
local markerIndex = -1
local current_play_pos = reaper.GetPlayPosition()
local markerName = reaper.GetExtState("Play-Stop with memory", "Markername") 

function DeleteMarkersByColor(targetColor)
  local _, num_markers, _ = reaper.CountProjectMarkers(0)
                            
    for i = num_markers - 1, 0, -1 do
        local _, isrgn, _, _, _, _, color = reaper.EnumProjectMarkers3(0, i)
                                
        -- Check if it's a marker (not a region) and if the color matches the target color
        if not isrgn and color == targetColor then
            reaper.DeleteProjectMarkerByIndex(0, i)
        end
    end
end


if script_state < 1 then 
  script_state = 1
  
  reaper.SetMouseModifier('MM_CTX_RULER_CLK',0,'_9666c9bb52a6499facd6a038b11d0f66') -- Custom: Deselect everything (unselect time seleciton and loop points AND clear all razor edit areas AND unselect all tracks/items/envelope points)
  --reaper.Main_OnCommand(42328, 0) 
  --reaper.Main_OnCommand(40749, 1)
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWCLRTIMESELCLKON"), 1)
  DeleteMarkersByColor(marker_color)
  reaper.SetExtState("ReaTooled", "PlayCursorLinkState", tonumber(1), true)            
  
  
  
else
  script_state = 0
  
  DeleteMarkersByColor(marker_color)
  reaper.AddProjectMarker2(0, false, tonumber(current_play_pos), 0, markerName, 0, tostring(marker_color))
  reaper.SetMouseModifier('MM_CTX_RULER_CLK', 0, '6 m')
  --reaper.Main_OnCommand(42328, 1)
  --reaper.Main_OnCommand(40750, 1)
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWCLRTIMESELCLKOFF"), 1)
  reaper.SetExtState("ReaTooled", "PlayCursorLinkState", tonumber(0), true)
  
end


reaper.SetToggleCommandState(0,cmdID, script_state)
reaper.RefreshToolbar2(0,cmdID)



-- No undo point
function NoUndoPoint() end reaper.defer(NoUndoPoint)





