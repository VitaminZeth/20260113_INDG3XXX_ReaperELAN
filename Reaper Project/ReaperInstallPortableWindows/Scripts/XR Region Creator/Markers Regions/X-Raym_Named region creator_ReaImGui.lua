--[[
 * ReaScript Name: Named region creator (ReaImGui)
 * About: Create named and colored regions from SWS Auto-Color list, from time selection, or from last regions end to edit cursor position, or update region. Keyboard shortcuts are associated to region names first character, or one of non used alphanumerical characters available.
 * Screenshot: https://cloud.extremraym.com/sharex/reaper_KIqZUdvei4.mp4
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: X-Raym Premium Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.2.0
--]]

--[[
 * Changelog:
 * v1.2.0 (2026-02-19)
  + Current region name and color fields
  # Move SWS and sort buttons to title/right-click menu
  # Update region matching time selection instead of creating new one
 * v1.1.5 (2025-02-06)
  # Remove unwanted button selection via Arrow
 * v1.1.5 (2025-01-28)
  # Window resize border color
  # Moving window with click and drag titlebar only
 * v1.1.4 (2025-01-25)
  # Fix color insertion
 * v1.1.3 (2025-01-09)
  # Exit via context menu
 * v1.1.2 (2025-01-07)
  # ReaImGui init update
 * v1.1.1 (2025-01-04)
  # Better isdark text
 * v1.1.0 (2025-01-03)
  + Sort regions dropdown
  # ReaImGui v0.9 shim
 * v1.0.14 (2024-04-13)
  # Force reaimgui version
 * v1.0.13 (2024-03-30)
  + User definable buttons with preset scripts
  # bug fix reload colors
 * v1.0.12 (2024-03-30)
  # Sort regions by SWS Auto-color ID (not just line in the file)
 * v1.0.11 (2024-03-30)
  # fix too many  regions in keyboard shortcut association
 * v1.0.10 (2024-03-30)
  # real_name fix
 * v1.0.9 (2024-03-05)
  + Color inversion for SWS 2.14
 * v1.0.8 (2024-01-09)
  + Added empty name region button
 * v1.0.7 (2023-11-22)
  + Various UI customization in User Config Area for Preset script
 * v1.0.6 (2023-08-27)
  # Fix keyboard shortcut insered in region name
 * v1.0.5 (2023-08-26)
  # Apply color directly
  # Polish UI
 * v1.0.4 (2023-08-26)
  + Theme
  # Layout
 * v1.0.3 (2023-08-26)
  # Regions with Spaces support
  # Regions without color support
  # Dark text for bright regions
  # Keyboard shorcut for all alphanumerical characters, so 36 shortcuts available
 * v1.0.2 (2023-08-25)
  # Region end bug fix
 * v1.0.1 (2023-08-25)
  + Color interactivity on regions buttons
 * v1.0 (2023-08-25)
  + Initial release
--]]

--------------------------------------------------------------------------------
-- USER CONFIG AREA --
--------------------------------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

console = true -- Display debug messages in the console
reaimgui_force_version = "0.9.3.2"

alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" -- Keys for keyboard shortcut

-- List of name. Add (x) for keyboard shortcuts. Uppercase. Supports A-Z and Num1 for Keypad.
-- Check https://www.extremraym.com/cloud/reascript-doc/ Imgui_Key functions for more.
buttons_user = {
  --{ name = "Intro", color = 13972736 },
  --{ name = "Verse", color = 32768 },
  --{ name = "Chorus", color = 13959274 },
}

load_from_sws_autocolor = true
all_on_same_line = false
sort_by = "Name" -- Name or ID

--------------------------------------------------------------------------------
                                                   -- END OF USER CONFIG AREA --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- GLOBALS --
--------------------------------------------------------------------------------

input_title = "XR - Region Creator"
undo_text = "Add region"

ext_name = "XR_Region Creator"

theme_colors = {
  WindowBg          = 0x292929ff, -- Window
  Border            = 0x2a2a2aff, -- Border
  Button            = 0x454545ff, -- Button
  ButtonActive      = 0x404040ff, -- Button and Top resize
  ButtonHovered     = 0x606060ff,
  FrameBg           = 0x454545ff, -- Input text BG
  FrameBgHovered    = 0x606060ff,
  FrameBgActive     = 0x404040ff,
  TitleBg           = 0x292929ff, -- Title
  TitleBgActive     = 0x000000ff,
  Header            = 0x323232ff, -- Selected rows
  HeaderHovered     = 0x323232ff,
  HeaderActive      = 0x05050587,
  ResizeGrip        = 0x323232ff, -- Resize
  ResizeGripHovered = 0x404040ff,
  ResizeGripActive  = 0x05050587,
  TextSelectedBg    = 0x292929ff, -- Search Field Selected Text
  SeparatorHovered  = 0x606060ff,
  SeparatorActive   = 0x404040ff,
  CheckMark         = 0xffffffff, -- CheckMark
  SliderGrab        = 0xffffff33, -- SliderGrab
  SliderGrabActive  = 0xffffff66,
}


--------------------------------------------------------------------------------
-- DEPENDENCIES --
--------------------------------------------------------------------------------

if not reaper.CF_GetSWSVersion then
  reaper.MB("Missing dependency: SWS extension.\nPlease download it from http://www.sws-extension.org/", "Error", 0)
  return false
end

version = reaper.CF_GetSWSVersion()
version_num_1, version_num_2 = version:match("(%d+)%.(%d+)")
version_num = tonumber(version_num_1) * 100 + version_num_2
if version_num > 213 then
  do_color_inversion = true
end

imgui_path = reaper.ImGui_GetBuiltinPath and ( reaper.ImGui_GetBuiltinPath() .. '/imgui.lua' )

if not imgui_path then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

local ImGui = dofile(imgui_path) (reaimgui_force_version)

--------------------------------------------------------------------------------
                                                       -- END OF DEPENDENCIES --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- DEBUG --
--------------------------------------------------------------------------------

function Msg( value )
  if console then
    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
  end
end

--------------------------------------------------------------------------------
-- DEFER --
--------------------------------------------------------------------------------

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState()
end

--------------------------------------------------------------------------------
-- READ FILE --
--------------------------------------------------------------------------------

function read_lines(filepath)
  local lines = {}
  local f = io.input(filepath)
  if not f then return false end
  repeat
    local s = f:read ("*l") -- read one line
    if s then  -- if not end of file (EOF)
      table.insert(lines, s)
    end
  until not s  -- until end of file
  f:close()
  return lines
end


--------------------------------------------------------------------------------
-- TABLES --
--------------------------------------------------------------------------------

function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
        copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function SortTable( tab, val1, val2)
  -- SORT TABLE
  -- thanks to https://forums.coronalabs.com/topic/37595-nested-sorting-on-multi-dimensional-array/
  table.sort(tab, function( a,b )
    if (a[val1] < b[val1]) then
      -- primary sort on position -> a before b
      return true
    elseif (a[val1] > b[val1]) then
      -- primary sort on position -> b before a
      return false
    else
      -- primary sort tied, resolve w secondary sort on rank
      return a[val2] < b[val2]
    end
  end)
end

--------------------------------------------------------------------------------
-- REAMGUI --
--------------------------------------------------------------------------------

-- From cfillion
function about()
  local owner = reaper.ReaPack_GetOwner(({reaper.get_action_context()})[2])

  if not owner then
    reaper.MB(string.format(
      'This feature is unavailable because this script was not installed using ReaPack.',
      "Warning"), "Warning", 0)
    return
  end

  reaper.ReaPack_AboutInstalledPackage(owner)
  reaper.ReaPack_FreeEntry(owner)
end

function contextMenu()
  local r = reaper
  local dock_id = ImGui.GetWindowDockID(ctx)
  if not ImGui.BeginPopupContextWindow(ctx, nil, ImGui.PopupFlags_MouseButtonRight | ImGui.PopupFlags_NoOpenOverItems) then return end
  if ImGui.BeginMenu(ctx, 'Dock window') then
    if ImGui.MenuItem(ctx, 'Floating', nil, dock_id == 0) then
      set_dock_id = 0
    end
    for i = 0, 15 do
      if ImGui.MenuItem(ctx, ('Docker %d'):format(i + 1), nil, dock_id == ~i) then
        set_dock_id = ~i
      end
    end
    ImGui.EndMenu(ctx)
  end

  ImGui.Separator(ctx)

  if ImGui.MenuItem( ctx, "Open SWS Auto-Color Window" ) then
    reaper.Main_OnCommand( reaper.NamedCommandLookup( "_SWSAUTOCOLOR_OPEN" ), 0 )
  end

  if ImGui.MenuItem( ctx, "Reload colors from SWS Auto-Color" ) then
    GetButtonsFromSWSAutoColor()
  end

  ImGui.Separator(ctx)

  if ImGui.MenuItem( ctx, "Sort by Name", nil, sort_by == "Name" ) then
    sort_by = "Name"
    GetButtonsFromSWSAutoColor()
  end

  if ImGui.MenuItem( ctx, "Sort by ID", nil, sort_by == "ID" ) then
    sort_by = "ID"
    GetButtonsFromSWSAutoColor()
  end

  ImGui.Separator(ctx)

  if ImGui.MenuItem(ctx, 'About/help', 'F1', false, r.ReaPack_GetOwner ~= nil) then
    about()
  end
  if ImGui.MenuItem(ctx, 'Close', 'Escape') then
    exit = true
  end
  ImGui.EndPopup(ctx)
end

function TableToMenu( t )
  return table.concat(t, "\0") .. "\0"
end

--------------------------------------------------------------------------------
-- PROCESS --
--------------------------------------------------------------------------------

function GetClosestMarkerOrRegion( want_region, pos_limit )
  local count_markers_regions, count_markers, count_regions = reaper.CountProjectMarkers(0)
  if (want_region and count_regions == 0) or ( not want_region and count_markers == 0) then return false end
  local minimal = math.huge
  local closest = {}
  for i = 0, count_markers_regions - 1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3( 0, i )
    if pos >= pos_limit then break end
    if retval >= 0 and want_region == isrgn then
      if not isrgn then rgnend = pos end
      local pos_relative = math.abs( edit_cur_pos - pos )
      local rgnend_relative = math.abs( edit_cur_pos - rgnend )
      local closest_edge = ""
      local absolute_distance = 0
      if pos_relative < rgnend_relative then
        absolute_distance = pos_relative
        closest_edge = "s"
      else
        absolute_distance = rgnend_relative
        closest_edge = "e"
      end
      -- if absolute_distance > minimal then break end -- we need to loop in all regions because one region can have region end inside its previous region
      if absolute_distance < minimal then
        minimal = absolute_distance
        closest = { pos = pos, pos_end = rgnend, name = name, real_name = name, idx = markrgnindexnumber, id = i, color = color, is_rgn = isrgn }
      end
      if absolute_distance == minimal then
        minimal = absolute_distance
        if (closest_edge == "s" and edit_cur_pos >= pos) then
          closest = { pos = pos, pos_end = rgnend, name = name, real_name = name, idx = markrgnindexnumber, id = i, color = color, is_rgn = isrgn }
        end
      end
    end
  end
  return closest
end

function Process( entry )

  reaper.Undo_BeginBlock()

  local cur_pos = reaper.GetCursorPosition()
  local time_start, time_end = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )
  local color = 0
  if entry.color then
    if do_color_inversion and os_sep == "\\" then -- Win Only
      local r, g, b = reaper.ColorFromNative( entry.color )
      color = reaper.ColorToNative( b, g, r )
    end
    color = color | 16777216
  end
  if time_start ~= time_end then -- If time selection
    -- Check region at time selection
    marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion( 0, time_start )
    create = true
    if region_idx >= 0 then
      local retval, is_region, region_start, region_end, region_name, markrgnindexnumber, region_color = reaper.EnumProjectMarkers3(0, region_idx)

      if region_start == time_start and region_end == time_end then
        create = false
        reaper.SetProjectMarkerByIndex2( 0, region_idx, is_region, region_start, region_end, markrgnindexnumber , entry.real_name or "", color, 0 )
        if not entry.color then
          reaper.Main_OnCommand( 41896, 0 ) -- Markers: Set region near cursor to default color
        end
      end
    end
    if create then
      local retval = reaper.AddProjectMarker2( 0, true, time_start, time_end, entry.real_name or "", -1, color )
    end
  else
    marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion( 0, cur_pos )
    if region_idx >= 0 then
      local retval, is_region, region_start, region_end, region_name, markrgnindexnumber, region_color = reaper.EnumProjectMarkers3(0, region_idx)
      reaper.SetProjectMarkerByIndex2( 0, region_idx, is_region, region_start, region_end, markrgnindexnumber , entry.real_name or "", color, 0 )
      if not entry.color then
        reaper.Main_OnCommand( 41896, 0 ) -- Markers: Set region near cursor to default color
      end
    else
      -- Get Last Region Region End
      last_region = GetClosestMarkerOrRegion( true, cur_pos )
      if not last_region or not last_region.pos_end then last_region = { pos_end = 0 } end
      if cur_pos > last_region.pos_end then
        reaper.AddProjectMarker2( 0, true, last_region.pos_end, cur_pos, entry.real_name or "", -1, color)
      end
    end
  end

  reaper.Undo_EndBlock( undo_text, -1)
  reaper.UpdateArrange()
end

--------------------------------------------------------------------------------
-- MAIN --
--------------------------------------------------------------------------------

-- CSV to Table
-- http://lua-users.org/wiki/LuaCsv
function ParseCSVLine (line,sep)
  local res = {}
  local pos = 1
  sep = sep or ','
  while true do
    local c = string.sub(line,pos,pos)
    if (c == "") then break end
    if (c == '"') then
      -- quoted value (ignore separator within)
      local txt = ""
      repeat
        local startp,endp = string.find(line,'^%b""',pos)
        txt = txt..string.sub(line,startp+1,endp-1)
        pos = endp + 1
        c = string.sub(line,pos,pos)
        if (c == '"') then txt = txt..'"' end
        -- check first char AFTER quoted string, if it is another
        -- quoted string without separator, then append it
        -- this is the way to "escape" the quote char in a quote. example:
        --   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
      until (c ~= '"')
      table.insert(res,txt)
      assert(c == sep or c == "")
      pos = pos + 1
    else
      -- no quotes used, just look for the first separator
      local startp,endp = string.find(line,sep,pos)
      if (startp) then
        table.insert(res,string.sub(line,pos,startp-1))
        pos = endp + 1
      else
        -- no separator found -> use rest of string and terminate
        table.insert(res,string.sub(line,pos))
        break
      end
    end
  end
  return res
end

function isDark( r, g, b ) -- expect 0<=x<=1 values
  local luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
  return luminance < 0.5
end

function GetButtonsFromSWSAutoColor()
  buttons = deepcopy( buttons_user )
  os_sep = package.config:sub(1,1)
  sws_autocolor_path = reaper.GetResourcePath() .. os_sep .. "sws-autocoloricon.ini"
  local ids = {}
  local t = {}
  if load_from_sws_autocolor and reaper.file_exists( sws_autocolor_path ) then
    local lines = read_lines( sws_autocolor_path )
    if lines and #lines > 0 then
      for i, line in ipairs( lines ) do
        local id, value = line:match( 'AutoColor (%d+)=2 (.+)' )
        if id then
          local csv = ParseCSVLine( value, " " )
          if csv[1] and csv[2] then
            id = tonumber(id)
            if id then
              t[id] = { name = csv[1] or "", real_name = csv[1] or "", color = tonumber( csv[2] ) or "", keyboard = keyboard, id = id }
              table.insert( ids, id )
            end
          end
        end
      end
    end
  end

  table.sort( ids )

  for i, id in pairs( ids ) do
    table.insert( buttons, t[id] )
  end
  table.insert( buttons, { name = "Empty", real_name = "Empty", color = nil, keyboard = keyboard } )

  if sort_by:lower() == "name" then
    SortTable( buttons, "name", "id" )
  end

  keys_used = {}
  buttons_keys = {}
  local count_buttons_keys = 0
  for k, button in ipairs( buttons ) do
    local first_letter = button.name:sub(1, 1)
    if first_letter and keys_used[first_letter] == nil then
      local k = first_letter:upper()
      button.name = button.name .. " (" .. k .. ")"
      button.key = k
      keys_used[first_letter] = true
      count_buttons_keys = count_buttons_keys + 1
    end
    buttons_keys[ button.name:lower() ] = true
  end

  -- Find not used keyboard shortcut
  if count_buttons_keys < #buttons then
    local t_alphabet = {}
    for c in string.gmatch(alphabet,".") do
      if not keys_used[c] then
        table.insert( t_alphabet, c )
      end
    end
    local index = 1
    for i, button in ipairs( buttons ) do
      if not button.key then
        local k = ( tonumber( t_alphabet[index] and "Num" .. t_alphabet[index] ) ) or t_alphabet[index]
        if k then
          button.key = k
          button.name = button.name .. " (" .. k .. ")"
        end
        index = index + 1
      end
    end
  end
end

function SetThemeColors()
  local count_theme_colors = 0
  for k, color in pairs( theme_colors ) do
    local color_str = reaper.GetExtState( "XR_ImGui_Col", k )
    if color_str ~= "" then
      color = tonumber( color_str, 16 )
    end
    ImGui.PushStyleColor(ctx, reaper[ "ImGui_Col_" .. k ](), color )
    count_theme_colors = count_theme_colors + 1
  end
  return count_theme_colors
end

function PopStyle( num )
  if num > 0 then
    ImGui.PopStyleColor(ctx, num)
  end
  return  0
end

function Main()

  edit_cur_pos = reaper.GetCursorPosition()

  for i, button in ipairs( buttons ) do
    pop_style = 0

    if button.color and button.color ~= -4 then -- -4 is not color, from empry string
      r, g, b = reaper.ColorFromNative(  button.color )
      if do_color_inversion and os_sep == "\\" then -- Win Only
        r, g, b = b, g, r
      end
      color = ImGui.ColorConvertDouble4ToU32( r/255, g/255, b/255, 1 )
      ImGui.PushStyleColor(ctx, ImGui.Col_Button,        color)
      local r, g, b, a = ImGui.ColorConvertU32ToDouble4( color)
      local h, s, v = ImGui.ColorConvertRGBtoHSV( r, g, b )
      local r, g, b = ImGui.ColorConvertHSVtoRGB( h, s, v*0.8 )
      local color_hover = ImGui.ColorConvertDouble4ToU32( r, g, b, a )
      ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, color_hover)
      r, g, b = ImGui.ColorConvertHSVtoRGB( h, s, v*0.7 )
      local color_active = ImGui.ColorConvertDouble4ToU32( r, g, b, a )
      ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,  color_active)
      pop_style = pop_style + 3
      if not isDark( r, g, b ) then
        ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0x000000FF)
        pop_style = pop_style + 1
      end
    end

    if button.key then
      key = button.key :gsub("Num", "Keypad")
      if not input_active and reaper["ImGui_Key_" .. key ] and ImGui.IsKeyPressed(ctx, reaper["ImGui_Key_" .. key ]() ) then
        local color = ImGui.GetStyleColor( ctx, ImGui.Col_ButtonActive )
        ImGui.PushStyleColor(ctx, ImGui.Col_Button,        color)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, color)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,  color)
        pop_style = pop_style + 3

        ImGui.SetKeyboardFocusHere( ctx, 0 )

        Process( button )
      end
    end

    local w, h = ImGui.CalcTextSize( ctx, button.name, 0, 0 )
    w = w + ImGui.GetStyleVar(ctx, ImGui.StyleVar_ItemInnerSpacing) + 2
    if ImGui.GetCursorPosX( ctx ) + w > imgui_width then
      ImGui.NewLine( ctx )
    end

    if ImGui.Button(ctx, button.name .. '##3fkey' ..i ) then
      Process( button, remove )
    end
    if ImGui.IsItemHovered(ctx) then
      ImGui.SetMouseCursor(ctx, ImGui.MouseCursor_Hand)
    end

    if i < #buttons then ImGui.SameLine( ctx ) end

    pop_style = PopStyle( pop_style )

  end

  if all_on_same_line then ImGui.SameLine(ctx) end

  ImGui.Dummy( ctx, 0, 20 )

  local pressed_key = ""

  local break_point = 650
  local button_width = (imgui_width < break_point and imgui_width ) or 220
  local button_height = 35
  local buttons_count = (imgui_width < break_point and 1) or 3

  if all_on_same_line then
    button_width = nil
    button_height = nil
    ImGui.SameLine(ctx)
  end

  if buttons_count > 1 and not all_on_same_line then
    ImGui.Spacing( ctx )
    ImGui.SameLine(ctx, (imgui_width - (button_width * buttons_count) )/ 2 )
  end

  if not input_active and ImGui.IsKeyPressed( ctx, ImGui.Key_LeftArrow ) then
    local color = ImGui.GetStyleColor( ctx, ImGui.Col_ButtonActive )
    ImGui.PushStyleColor(ctx, ImGui.Col_Button,        color)
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, color)
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,  color)
    pop_style = 3
    pressed_key = "left"
  end

  if ImGui.Button( ctx, "Previous Measure (Left)", button_width, button_height ) or pressed_key == "left" then
    reaper.Main_OnCommand( 41043, 0 ) -- Move edit cursor back one measure
  end
  if ImGui.IsItemHovered(ctx) then
    ImGui.SetMouseCursor(ctx, ImGui.MouseCursor_Hand)
  end

  pop_style = PopStyle( pop_style )

  if buttons_count > 1 then ImGui.SameLine( ctx ) end

  if not input_active and ImGui.IsKeyPressed( ctx, ImGui.Key_Delete ) then
    pressed_key = "delete"
  end

  if ImGui.Button( ctx, "Delete Current Region (Del)", button_width, button_height ) or pressed_key == "delete" then
    local edit_cur_pos = reaper.GetCursorPosition()
    local marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion( 0, edit_cur_pos )
    if region_idx >= 0 then
     reaper.DeleteProjectMarkerByIndex( proj, region_idx )
    end
  end
  if ImGui.IsItemHovered(ctx) then
    ImGui.SetMouseCursor(ctx, ImGui.MouseCursor_Hand)
  end

  if buttons_count > 1 then ImGui.SameLine( ctx ) end

  if ImGui.IsKeyPressed( ctx, ImGui.Key_RightArrow ) then
    local color = ImGui.GetStyleColor( ctx, ImGui.Col_ButtonActive )
    ImGui.PushStyleColor(ctx, ImGui.Col_Button,        color)
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, color)
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,  color)
    pop_style = 3
    pressed_key = "right"
  end

  if ImGui.Button( ctx, "Next Measure (Right)", button_width, button_height ) or pressed_key == "right" then
    reaper.Main_OnCommand( 41040, 0 ) -- Move edit cursor to start of next measure
  end

  if ImGui.IsItemHovered(ctx) then
    ImGui.SetMouseCursor(ctx, ImGui.MouseCursor_Hand)
  end

  pop_style = PopStyle( pop_style )

  ImGui.Dummy( ctx, 0, 20 )

  time_start, time_end = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )
  marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion( 0, (time_start~=time_end and time_start) or edit_cur_pos )
  if region_idx ~= -1 then
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3( 0, region_idx )
    ImGui.Text( ctx, "Current region:" )
    ImGui.SameLine( ctx )
    color = ImGui.ColorConvertNative( color )
    retval, col_rgb = ImGui.ColorEdit3( ctx, "##Current Region Color", color,ImGui.ColorEditFlags_NoInputs  | ImGui.ColorEditFlags_NoLabel )
    if retval and col_rgb ~= color then
      reaper.SetProjectMarkerByIndex2( proj, region_idx, true, pos, rgnend, markrgnindexnumber, name, ImGui.ColorConvertNative( col_rgb )|0x1000000, 0 )
      reaper.MarkProjectDirty(0)
    end
    color_active = ImGui.IsItemActive( ctx )
    if not color_active and last_color_active then
      reaper.Undo_BeginBlock()
      reaper.MarkProjectDirty(0)
      reaper.Undo_EndBlock("Region colored", -1)
      reaper.UpdateTimeline()
    end
    last_color_active = color_active
    ImGui.SameLine( ctx )
    ImGui.SetNextItemWidth( ctx, -1 )
    local retval, val = ImGui.InputText( ctx, "##Current Region", name )
    input_active = ImGui.IsItemActive( ctx )
    if retval then
      reaper.SetProjectMarkerByIndex2( proj, region_idx, true, pos, rgnend, markrgnindexnumber, val, ImGui.ColorConvertNative( color ), 0 )
      renamed = true
      reaper.MarkProjectDirty(0)
    end
    if renamed and not input_active then
      reaper.Undo_BeginBlock()
      reaper.MarkProjectDirty(0)
      reaper.Undo_EndBlock("Region renamed", -1)
      renamed = false
    end
  end

  if not input_active and ImGui.IsKeyPressed( ctx, ImGui.Key_Space ) then
    reaper.Main_OnCommand( 40044, 0 ) -- Transport: Play/stop
  end

end

function Run()

  ImGui.SetNextWindowBgAlpha( ctx, 1 )

  count_theme_colors = SetThemeColors()
  ImGui.PushFont(ctx, font)
  ImGui.SetNextWindowSize(ctx, 800, 200, ImGui.Cond_FirstUseEver)

  ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, 3.0)
  pop_var = 1

  if set_dock_id then
    ImGui.SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end

  local imgui_visible, imgui_open = ImGui.Begin(ctx, input_title, true, ImGui.WindowFlags_NoCollapse)
  if imgui_visible then

    contextMenu()

    imgui_width, imgui_height = ImGui.GetWindowSize( ctx )
    imgui_width, imgui_height = ImGui.GetContentRegionAvail( ctx )

    Main()

    ImGui.End(ctx)
  end

  ImGui.PopFont(ctx)
  ImGui.PopStyleColor( ctx, count_theme_colors)
  ImGui.PopStyleVar( ctx, pop_var )

  if imgui_open and not ImGui.IsKeyPressed(ctx, ImGui.Key_Escape) and not process and not exit then
    reaper.defer(Run)
  end

end -- END DEFER

--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------

function Init()
  reaper.ClearConsole()

  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = ImGui.CreateContext(input_title, ImGui.ConfigFlags_DockingEnable )
  ImGui.SetConfigVar( ctx, ImGui.ConfigVar_DockingNoSplit, 1 )
  ImGui.SetConfigVar( ctx, ImGui.ConfigVar_WindowsMoveFromTitleBarOnly, 1 )

  font = ImGui.CreateFont('sans-serif', 16)
  ImGui.Attach(ctx, font)

  GetButtonsFromSWSAutoColor()

  reaper.defer(Run)
end

if not preset_file_init then
  Init()
end
