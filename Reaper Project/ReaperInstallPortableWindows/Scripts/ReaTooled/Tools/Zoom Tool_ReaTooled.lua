-- @description ReaTooled - Zoom Tool (Zoomer Tool)
-- @version 1.2
-- @date 2024.11.13
-- @author Brendan Baker
-- @link https://brendanpatrickbaker.com/reatooled/
-- @about
--   # This script loads a set of mouse modifiers focusing on zooming to a selection, which gives similar functionality to ProTools' "Zoomer Tool."
-- CHANGELOG
-- # v1.2 Added Opt+Click to Zoom Out, Changed Zoom In/out Archie_View scripts for better performance
-- # v1.1 Multiple tweaks to mouse modifier to more closely align with PT behavior

local CMD_ID_1 = reaper.NamedCommandLookup("_RS21aa0b14cf72a27be535d32efe0d05513523aec9")
local CMD_ID_2 = reaper.NamedCommandLookup("_RSd77ea649952c67db183a19cece290cf3e1b3d49d")
local CMD_ID_3 = reaper.NamedCommandLookup("_RSb08c9a159d1a7537eda8df72b777b1cc4c9422e8")
local CMD_ID_4 = reaper.NamedCommandLookup("_RSc2c7d733888679038b4a4341074dc703d0f7f9c2")
local CMD_ID_7 = reaper.NamedCommandLookup("_RS5e85a066efd01fde2482832bf4a3502dce0427b6")

was_set=-1

function UpdateState()
  local MM_CTX_ITEM_default=reaper.GetMouseModifier('MM_CTX_ITEM',0)
  local MM_CTX_ITEMLOWER_default=reaper.GetMouseModifier('MM_CTX_ITEMLOWER',0)
  local MM_CTX_ITEMEDGE_default=reaper.GetMouseModifier('MM_CTX_ITEMEDGE',0)
  local MM_CTX_TRACK_default=reaper.GetMouseModifier('MM_CTX_TRACK',0)
  local MM_CTX_ITEM_CLK_default=reaper.GetMouseModifier('MM_CTX_ITEM_CLK',0)
  local MM_CTX_TRACK_CLK_default=reaper.GetMouseModifier('MM_CTX_TRACK_CLK',0)
  local MM_CTX_ITEMLOWER_CLK_default=reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',0)
  local MM_CTX_ITEM_DBLCLK_default=reaper.GetMouseModifier('MM_CTX_ITEM_DBLCLK',0)
  local MM_CTX_ITEMLOWER_DBLCLK_default=reaper.GetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',0)  

  
  local is_set =
    reaper.GetMouseModifier('MM_CTX_ITEM',0) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',1) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',2) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',3) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',4) == MM_CTX_ITEM_default and
    reaper.GetMouseModifier('MM_CTX_ITEM',5) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',6) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',7) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',8) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',9) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',10) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',11) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',12) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',13) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',14) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEM',15) == '48 m' and -- Marquee zoom

    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',0) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',1) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',2) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',3) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',4) == MM_CTX_ITEMLOWER_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',5) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',6) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',7) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',8) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',9) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',10) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',11) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',12) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',13) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',14) == '48 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',15) == '48 m' and -- Marquee zoom
    
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',0) == '0' and
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',1) == '0' and
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',2) == '0' and
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',3) == '0' and
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',4) == '10 m' and -- Stretch item (relative edge edit)
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',5) == '12 m' and -- Stretch item ignoring snap (relative edge edit)
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',6) == '6 m' and -- Stretch item ignoring selection/grouping
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',7) == '8 m' and -- Stretch item ignoring snap and selection/grouping
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',8) == MM_CTX_ITEMEDGE_default and
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',9) == MM_CTX_ITEMEDGE_default and
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',10) == MM_CTX_ITEMEDGE_default and
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',11) == MM_CTX_ITEMEDGE_default and
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',12) == '6 m' and -- Stretch item ignoring selection/grouping
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',13) == MM_CTX_ITEMEDGE_default and
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',14) == '19 m' and -- Adjust loop section start/end
    reaper.GetMouseModifier('MM_CTX_ITEMEDGE',15) == MM_CTX_ITEMEDGE_default and
    
    reaper.GetMouseModifier('MM_CTX_TRACK',0) == '22 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_TRACK',1) == '22 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_TRACK',2) == '22 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_TRACK',3) == '22 m' and -- Marquee zoom
    reaper.GetMouseModifier('MM_CTX_TRACK',4) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',5) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',6) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',7) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',8) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',9) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',10) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',11) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',12) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',13) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',14) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',15) == MM_CTX_TRACK_default and
    
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',0) == '_RS9268783e8fdf118c7afb2b9e5a2a76c30bd7218d' and -- Script: Archie_View; Zoom in horizontally - snap to playback cursor.lua
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',1) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',2) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',3) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',4) == '_RS1f4c63e71fe1fc621fd1b4976377ff6aae8e3781' and -- Script: Archie_View; Zoom out horizontally - snap to playback cursor.lua
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',5) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',6) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',7) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',8) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',9) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',10) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',11) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',12) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',13) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',14) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',15) == MM_CTX_TRACK_CLK_default and
    
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',0) == '_RS9268783e8fdf118c7afb2b9e5a2a76c30bd7218d' and -- Script: Archie_View; Zoom in horizontally - snap to playback cursor.lua
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',1) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',2) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',3) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',4) == '_RS1f4c63e71fe1fc621fd1b4976377ff6aae8e3781' and -- Script: Archie_View; Zoom out horizontally - snap to playback cursor.lua
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',5) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',6) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',7) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',8) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',9) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',10) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',11) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',12) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',13) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',14) == MM_CTX_ITEM_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',15) == MM_CTX_ITEM_CLK_default and

    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',0) == '_RS9268783e8fdf118c7afb2b9e5a2a76c30bd7218d' and -- Script: Archie_View; Zoom in horizontally - snap to playback cursor.lua
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',1) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',2) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',3) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',4) == '_RS1f4c63e71fe1fc621fd1b4976377ff6aae8e3781' and -- Script: Archie_View; Zoom out horizontally - snap to playback cursor.lua
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',5) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',6) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',7) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',8) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',9) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',10) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',11) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',12) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',13) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',14) == MM_CTX_ITEMLOWER_CLK_default and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',15) == MM_CTX_ITEMLOWER_CLK_default and
    
    reaper.GetMouseModifier('MM_CTX_ITEM_DBLCLK',0) == '0' and
    reaper.GetMouseModifier('MM_CTX_ITEM_DBLCLK',4) == '40295 c' and -- View: Zoom out project
    
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',0) == '0' and
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',4) == '40295 c' -- View: Zoom out project

  if is_set ~= was_set then
    was_set=is_set
    reaper.set_action_options(3 | (is_set and 4 or 8))
    reaper.RefreshToolbar(0)
  end
  reaper.defer(UpdateState)
end

-- Set Mouse Modifiers for each category
reaper.SetMouseModifier('MM_CTX_ITEM',0,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',1,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',2,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',3,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',4,'0 m')
reaper.SetMouseModifier('MM_CTX_ITEM',5,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',6,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',7,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',8,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',9,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',10,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',11,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',12,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',13,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',14,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEM',15,'48 m') -- Marquee zoom

reaper.SetMouseModifier('MM_CTX_ITEMLOWER',0,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',1,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',2,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',3,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',4,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',5,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',6,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',7,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',8,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',9,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',10,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',11,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',12,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',13,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',14,'48 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',15,'48 m') -- Marquee zoom

reaper.SetMouseModifier('MM_CTX_ITEMEDGE',0,'0')
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',1,'0')
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',2,'0')
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',3,'0')
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',4,'10 m') -- Stretch item (relative edge edit)
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',5,'12 m') -- Stretch item ignoring snap (relative edge edit)
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',6,'6 m') -- Stretch item ignoring selection/grouping
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',7,'8 m') -- Stretch item ignoring snap and selection/grouping
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',8,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',9,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',10,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',11,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',12,'6 m') -- Stretch item ignoring selection/grouping
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',13,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',14,'19 m') -- Adjust loop section start/end
reaper.SetMouseModifier('MM_CTX_ITEMEDGE',15,'-1')

reaper.SetMouseModifier('MM_CTX_TRACK',0,'22 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_TRACK',1,'22 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_TRACK',2,'22 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_TRACK',3,'22 m') -- Marquee zoom
reaper.SetMouseModifier('MM_CTX_TRACK',4,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',5,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',6,'0')
reaper.SetMouseModifier('MM_CTX_TRACK',7,'0')
reaper.SetMouseModifier('MM_CTX_TRACK',8,'0')
reaper.SetMouseModifier('MM_CTX_TRACK',9,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',10,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',11,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',12,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',13,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',14,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',15,'-1')

reaper.SetMouseModifier('MM_CTX_TRACK_CLK',0,'_RS9268783e8fdf118c7afb2b9e5a2a76c30bd7218d') -- Script: Archie_View; Zoom in horizontally - snap to playback cursor.lua
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',1,'0')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',2,'0')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',3,'0')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',4,'_RS1f4c63e71fe1fc621fd1b4976377ff6aae8e3781') -- Script: Archie_View; Zoom out horizontally - snap to playback cursor.lua
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',5,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',6,'0')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',7,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',8,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',9,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',10,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',11,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',12,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',13,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',14,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',15,'-1')

reaper.SetMouseModifier('MM_CTX_ITEM_CLK',0,'_RS9268783e8fdf118c7afb2b9e5a2a76c30bd7218d') -- Script: Archie_View; Zoom in horizontally - snap to playback cursor.lua
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',1,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',2,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',3,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',4,'_RS1f4c63e71fe1fc621fd1b4976377ff6aae8e3781') -- Script: Archie_View; Zoom out horizontally - snap to playback cursor.lua
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',5,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',6,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',7,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',8,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',9,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',10,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',11,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',12,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',13,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',14,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',15,'-1')

reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',0,'_RS9268783e8fdf118c7afb2b9e5a2a76c30bd7218d') -- Script: Archie_View; Zoom in horizontally - snap to playback cursor.lua
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',1,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',2,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',3,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',4,'_RS1f4c63e71fe1fc621fd1b4976377ff6aae8e3781') -- Script: Archie_View; Zoom out horizontally - snap to playback cursor.lua
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',5,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',6,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',7,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',8,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',9,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',10,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',11,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',12,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',13,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',14,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',15,'-1')

reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',0,'0')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',1,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',2,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',3,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',4,'40295 c') -- View: Zoom out project
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',5,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',6,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',7,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',8,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',9,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',10,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',11,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',12,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',13,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',14,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',15,'-1')

reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',0,'0')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',1,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',2,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',3,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',4,'40295 c') -- View: Zoom out project
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',5,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',6,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',7,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',8,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',9,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',10,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',11,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',12,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',13,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',14,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',15,'-1')

--UpdateState()

reaper.Main_OnCommand(40569,0) --enable locking
reaper.Main_OnCommand(40595,0) -- set item edges lock
reaper.Main_OnCommand(40598,0) --set item fades lock
reaper.Main_OnCommand(41852,0) --set item stretch markers lock
reaper.Main_OnCommand(41849,0) --set item envelope
reaper.Main_OnCommand(40572,0) --set time selection to UNlock
  --reaper.Main_OnCommand(40571,0) --set time selection to lock  

reaper.Main_OnCommand(42621, 0) -- clear arrange override mode

-- Set toolbar button states for additional scripts/buttons
reaper.SetToggleCommandState(0, CMD_ID_1, 1) -- Turn off button 1
reaper.SetToggleCommandState(0, CMD_ID_2, 0) -- Turn off button 2
reaper.SetToggleCommandState(0, CMD_ID_3, 0) -- Turn off button 3
reaper.SetToggleCommandState(0, CMD_ID_4, 0) -- Turn off button 4
reaper.SetToggleCommandState(0, CMD_ID_7, 0) -- Turn off button 7
reaper.SetToggleCommandState(0, reaper.NamedCommandLookup("_RS27973b4ea6ddfabb982b8206b117b31843c68991"), 0) -- scrub tool
reaper.SetToggleCommandState(0, reaper.NamedCommandLookup("_RSb90cf42a9ad3d180fdab1c2fbe82e70a76347b1f"), 0) -- TCE tool
reaper.RefreshToolbar(0)
