--[[
-- @description ReaTooled - Link Track and Item and Razor Selection (Main Function)
-- @version 1.10
-- @date 2024-03-14
-- @author copied from Lokasenna and TJF/Tim Farrell: http://github.com/sonictim/TJF-Scripts/, modified by Brendan Baker
-- @about
--   THIS IS AN UPDATE OF TJF's UPDATE OF Lokasenna_Track selection follows item selection.lua
--   Updated by TJF to now work with Razor Edits
--   Runs in the background and allows you to replicate a behavior
--   from Cubase or Protools - when selecting items, the track selection is
--   changed to match and the mixer view is scrolled to show the first
--   selected track.
--
--   To exit, open the Actions menu, and click on:
--   Running script: Lokasenna_Track selection follows item selection.lua
--   down at the bottom.
--
--   Note: This script is a rewrite of:
--   tritonality_X-Raym_Cubase_Style_SelectTrack_On_ItemSelect.lua
--
--   It had a few bugs and I couldn't understand the original code
--   well enough to fix them, so I opted to rewrite it from scratch.
--
-- Changes in this version (1.10):
--   - Sets ReaTooled ExtState to 1 when the script is running, 0 when manually disabled
--   - Toolbar button state now reflects script state: on when running, off when disabled
--   - Added mixer scroll to show first selected track (Optional: Comment out if not needed)
--]]

-- Licensed under the GNU GPL v3

local function Msg(str)
  reaper.ShowConsoleMsg(tostring(str).."\n")
end

local sel_items, sel_tracks, sel_razor = {}, {}, {}
local firstselitemtrack = reaper.GetSelectedTrack(0, 0)
local cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script

-- Very limited - no error checking, types, hash tables, etc
local function shallow_equal(t1, t2)
  if #t1 ~= #t2 then return false end
  for k, v in pairs(t1) do
    if v ~= t2[k] then return false end
  end
  return true
end

local function GetRazorTracks()
  local tracks = {}
  for i = 0, reaper.CountTracks(0) - 1 do
    local track = reaper.GetTrack(0, i)
    local _, str = reaper.GetSetMediaTrackInfo_String(track, "P_RAZOREDITS", "", false)
    if str ~= "" then
      table.insert(tracks, track)
    end
  end
  return tracks
end

local function ProcessTracks(tracks)
  if #tracks > 0 then
    reaper.PreventUIRefresh(1)
    -- Unselect all tracks
    reaper.Main_OnCommand(40297, 0)
    reaper.SetOnlyTrackSelected(tracks[1])
    for _, v in pairs(tracks) do
      reaper.SetTrackSelected(v, true)
    end
    -- "Touch" the first track so we don't mess up things like pasting items over multiple tracks
    reaper.Main_OnCommand(40914, 0)
    reaper.PreventUIRefresh(-1)
    reaper.UpdateArrange()
  end
end

local function Main()
  local ext_state = reaper.GetExtState("ReaTooled", "LinkTrackItemState")
  local script_running = (ext_state == "1")

  if script_running then
    -- Update ExtState to 1 when the script is running
    -- reaper.SetExtState("ReaTooled", "LinkTrackItemState", "1", true)

    local num_tracks = reaper.CountSelectedTracks(0)
    local cur_tracks = {}
    for i = 1, num_tracks do
      cur_tracks[i] = reaper.GetSelectedTrack(0, i - 1)
    end

    if shallow_equal(sel_tracks, cur_tracks) then
      -- The track selection hasn't been changed, so we can move on to looking at the item selection
      local cur_razor = GetRazorTracks()
      if not shallow_equal(sel_razor, cur_razor) then
        sel_razor = cur_razor
        ProcessTracks(sel_razor)
      else
        if #cur_razor == 0 then
          local num_items = reaper.CountSelectedMediaItems(0)
          if num_items > 0 then
            -- Grab the selected MediaItems into a table
            local cur_items = {}
            for i = 1, num_items do
              cur_items[i] = reaper.GetSelectedMediaItem(0, i - 1)
            end
            -- If all MediaItems have a different partner track or the first selected item's track has changed
            if not shallow_equal(sel_items, cur_items) or firstselitemtrack ~= reaper.GetMediaItem_Track(cur_items[1]) then
              sel_items = cur_items
              firstselitemtrack = reaper.GetMediaItem_Track(cur_items[1])
              local tracks = {}
              for i = 1, num_items do
                tracks[i] = reaper.GetMediaItem_Track(sel_items[i])
              end
              ProcessTracks(tracks)
              -- Scroll the mixer to the first selected track (Optional: Comment out if not needed)
              if num_items > 0 then
                reaper.SetMixerScroll(reaper.GetSelectedTrack(0, 0))
              end
            end
          end
        end
      end
    else
      -- User changed the track selection manually
      sel_tracks = cur_tracks
    end
  end
  
  reaper.SetExtState("ReaTooled", "LinkTrackItemState", "1", true)

  -- Debugging message
  --Msg("isRunning: " .. tostring(script_running))
  --Msg("ExtState: " .. ext_state)

  reaper.defer(Main)
end

Main()

