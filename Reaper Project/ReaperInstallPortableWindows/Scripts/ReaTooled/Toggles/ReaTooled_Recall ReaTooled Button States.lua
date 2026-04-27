--[[
-- @description ReaTooled - Recall ReaTooled Button States
-- @version 1.0
-- @date 2024.03.12
-- @author Brendan Baker
-- @link http://brendanpatrickbaker.com/reatooled/
-- @about
    # Recalls various ReaTooled Button States
--]]




local reatooled_keymap_state = tonumber(reaper.GetExtState("ReaTooled", "TabToTransientState"))

if reatooled_keymap_state == 1 then
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSf475a3ed46e25a1ef9d2a8b4ad6aab87c94102a1"), 0) -- Script: ReaTooled_Toggle Tab to Transient.lua
  else
end


local reatooled_keymap_state = tonumber(reaper.GetExtState("ReaTooled", "PlayCursorLinkState"))

if reatooled_keymap_state == 1 then
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSed328eb507619b18c1154efa1b048d816cfc2d0c"), 0)  -- Script: ReaTooled_Toggle Edit Cursor follows Playback on Stop.lua
  else
end


local reatooled_keymap_state = tonumber(reaper.GetExtState("ReaTooled", "LinkTrackItemState"))

if reatooled_keymap_state == 1 then
  reaper.SetExtState("ReaTooled", "LinkTrackItemState", "1", true)
  reaper.SetToggleCommandState(0, reaper.NamedCommandLookup("_RSf28451a9bd28e7b3d270c4e5ce58052377a5e3df"), 1) -- Set button state on
  reaper.RefreshToolbar2(0, reaper.NamedCommandLookup("_RSf28451a9bd28e7b3d270c4e5ce58052377a5e3df"))
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS0a8653eb2474467f0c9dd9684bd8b6d5ba70ae97"), 0) -- Script: ReaTooled_Toggle Link Track and Item and Razor Selection.lua
  else
end


local reatooled_keymap_state = tonumber(reaper.GetExtState("ReaTooled", "EditFollowsPlaybackState"))

if reatooled_keymap_state == 1 then
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSe16d9e990f3d5fcec42256f63e00086d75b71288"), 0) -- Script: ReaTooled_Toggle Edit Cursor follows Playback on Stop.lua
  else
end

local reatooled_keymap_state = tonumber(reaper.GetExtState("ReaTooled", "MarkersLockedState"))

if reatooled_keymap_state == 1 then
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSfddebd265f81f5d37380924290732ca9deb3ccee"), 0) -- Script: ReaTooled_Toggle Markers Follow Ripple All vs Locked.lua
  else
end


local reatooled_keymap_state = tonumber(reaper.GetExtState("ReaTooled", "HoverModeState"))

if reatooled_keymap_state == 1 then
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS16d5d199f5424fa387d4f2ec9f1dc4fb35d75b25"), 0)  -- Script: ReaTooled_Recall Hover Mode State.lua
  else
end

local reatooled_keymap_state = tonumber(reaper.GetExtState("ReaTooled", "ReaTooledKeymapOn"))

if reatooled_keymap_state == 1 then
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS7e9fb26fe2faa9088b9d1aadabdbdfc97d417337"), 0)  -- Script: ReaTooled_Recall ReaTooled Keymap State.lua
  else
end


local reatooled_keymap_state = tonumber(reaper.GetExtState("ReaTooled", "LayeredEditingOn"))

if reatooled_keymap_state == 1 then
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS6edf5b85f2b775c4062a4ec0e30bcfabec3c3832"), 0) -- Script: ReaTooled_Toggle Layered Editing.lua
  else
end


reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS92db63d6237bd397c8fb2e69d1bfa8978dbf559f"), 0)  -- Script: ReaTooled Slip indicator
