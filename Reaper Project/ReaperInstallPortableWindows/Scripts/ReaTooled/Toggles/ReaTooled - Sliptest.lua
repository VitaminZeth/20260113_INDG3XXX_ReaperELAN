-- @description ReaTooled - Move Tool
-- @version 1.1
-- @date 2024.02.12
-- @author Brendan Baker
-- @link https://brendanpatrickbaker.com/reatooled/
-- @about
--   # This script loads a set of mouse modifiers focusing on moving items, which gives similar functionality to ProTools' "Grabber Tool."
-- CHANGELOG
-- # v1.1 Multiple tweaks to mouse modifier to more closely align with PT behavior

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
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',0) == '13 m' and -- Move item ignoring time selection
    reaper.GetMouseModifier('MM_CTX_ITEM',1) == '58 m' and -- Move item contents
    reaper.GetMouseModifier('MM_CTX_ITEM',2) == '51 m' and -- Move item ignoring time selection, enabling ripple edit for all tracks
    reaper.GetMouseModifier('MM_CTX_ITEM',3) == '50 m' and -- Move item ignoring time selection, enabling ripple edit for this track
    reaper.GetMouseModifier('MM_CTX_ITEM',4) == '2 m' and -- Copy item
    reaper.GetMouseModifier('MM_CTX_ITEM',5) == '56 m' and -- Move item contents ignoring snap, ripple earlier adjacent items
    reaper.GetMouseModifier('MM_CTX_ITEM',6) == '7 m' and -- Render item to new file
    reaper.GetMouseModifier('MM_CTX_ITEM',7) == '39 m' and -- Copy item, pooling MIDI source data
    reaper.GetMouseModifier('MM_CTX_ITEM',8) == '32 m' and -- Move item vertically
    reaper.GetMouseModifier('MM_CTX_ITEM',9) == '57 m' and -- Move item contents and right edge ignoring snap, ripple later adjacent items
    reaper.GetMouseModifier('MM_CTX_ITEM',12) == '36 m' and -- Copy item vertically
    reaper.GetMouseModifier('MM_CTX_ITEM',13) == '55 m' and -- Move item contents ignoring snap, ripple all adjacent items
    
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',0) == '13 m' and -- Move item ignoring time selection
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',1) == '58 m' and -- Move item contents
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',2) == '51 m' and -- Move item ignoring time selection, enabling ripple edit for all tracks
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',3) == '50 m' and -- Move item ignoring time selection, enabling ripple edit for this track
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',4) == '2 m' and -- Copy item
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',5) == '56 m' and -- Move item contents ignoring snap, ripple earlier adjacent items
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',6) == '7 m' and -- Render item to new file
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',7) == '39 m' and -- Copy item, pooling MIDI source data
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',8) == '32 m' and -- Move item vertically
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',9) == '57 m' and -- Move item contents and right edge ignoring snap, ripple later adjacent items
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',12) == '36 m' and -- Copy item vertically
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER',13) == '55 m' and -- Move item contents ignoring snap, ripple all adjacent items

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
    
    reaper.GetMouseModifier('MM_CTX_TRACK',0) == '9 m' and -- Marquee select items
    reaper.GetMouseModifier('MM_CTX_TRACK',1) == '13 m' and -- Marquee add to item selection
    reaper.GetMouseModifier('MM_CTX_TRACK',2) == '16 m' and -- Draw a copy of the selected media item, pooling MIDI source data
    reaper.GetMouseModifier('MM_CTX_TRACK',3) == '2 m' and -- Draw a copy of the selected media item ignoring snap
    reaper.GetMouseModifier('MM_CTX_TRACK',4) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',5) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',6) == '16 m' and -- Draw a copy of the selected media item, pooling MIDI source data
    reaper.GetMouseModifier('MM_CTX_TRACK',7) == '17 m' and -- Draw a copy of the selected media item ignoring snap, pooling MIDI source data
    reaper.GetMouseModifier('MM_CTX_TRACK',8) == '14 m' and -- Move time selection
    reaper.GetMouseModifier('MM_CTX_TRACK',9) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',10) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',11) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',12) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',13) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',14) == MM_CTX_TRACK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK',15) == MM_CTX_TRACK_default and
    
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',0) == '1 m' and -- Deselect all items and move edit cursor
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',1) == '5 m' and -- Extend time selection
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',2) == '2 m' and -- Deselect all items and move edit cursor ignoring snap
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',3) == '6 m' and -- Extend time selection ignoring snap
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',4) == '8 m' and -- Restore previous zoom level
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',5) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',6) == '4 m' and -- Clear time selection
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',7) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',8) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',9) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',10) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',11) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',12) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',13) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',14) == MM_CTX_TRACK_CLK_default and
    reaper.GetMouseModifier('MM_CTX_TRACK_CLK',15) == MM_CTX_TRACK_CLK_default and

    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',0) == '_1eb32b1b95474949883ca579137d130f' and -- Custom: ReaTooled Move Tool Left Click
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',1) == '17 m' and -- Add items to selection and set time selection to selected items
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',2) == '4 m' and -- Toggle item selection
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',4) == '15 m' and -- Add stretch marker
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',8) == '42391 c' and -- Item: Quick add take marker at mouse position
    reaper.GetMouseModifier('MM_CTX_ITEM_CLK',9) == '18 m' and -- Add/edit take marker
    
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',0) == '_1eb32b1b95474949883ca579137d130f' and -- Custom: ReaTooled Move Tool Left Click
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',1) == '17 m' and -- Add items to selection and set time selection to selected items
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',2) == '4 m' and -- Toggle item selection
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',4) == '15 m' and -- Add stretch marker
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',8) == '42391 c' and -- Item: Quick add take marker at mouse position
    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_CLK',9) == '18 m' and -- Add/edit take marker
    
    reaper.GetMouseModifier('MM_CTX_ITEM_DBLCLK',0) == '6 m' and -- MIDI: open in editor, Subprojects: open project, Audio: show media item properties

    reaper.GetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',0) == '6 m' -- MIDI: open in editor, Subprojects: open project, Audio: show media item properties

        
  if is_set ~= was_set then
    was_set=is_set
    reaper.set_action_options(3 | (is_set and 4 or 8))
  end
  reaper.RefreshToolbar(0)
  reaper.defer(UpdateState)
end

-- Set Mouse Modifiers for each category

reaper.SetMouseModifier('MM_CTX_ITEM',0,'13 m') -- Move item ignoring time selection
reaper.SetMouseModifier('MM_CTX_ITEM',1,'58 m') -- Move item contents
reaper.SetMouseModifier('MM_CTX_ITEM',2,'51 m') -- Move item ignoring time selection, enabling ripple edit for all tracks
reaper.SetMouseModifier('MM_CTX_ITEM',3,'50 m') -- Move item ignoring time selection, enabling ripple edit for this track
reaper.SetMouseModifier('MM_CTX_ITEM',4,'2 m') -- Copy item
reaper.SetMouseModifier('MM_CTX_ITEM',5,'56 m') -- Move item contents ignoring snap, ripple earlier adjacent items
reaper.SetMouseModifier('MM_CTX_ITEM',6,'7 m') -- Render item to new file
reaper.SetMouseModifier('MM_CTX_ITEM',7,'39 m') -- Copy item, pooling MIDI source data
reaper.SetMouseModifier('MM_CTX_ITEM',8,'32 m') -- Move item vertically
reaper.SetMouseModifier('MM_CTX_ITEM',9,'57 m') -- Move item contents and right edge ignoring snap, ripple later adjacent items
reaper.SetMouseModifier('MM_CTX_ITEM',10,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM',11,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM',12,'36 m') -- Copy item vertically
reaper.SetMouseModifier('MM_CTX_ITEM',13,'55 m') -- Move item contents ignoring snap, ripple all adjacent items
reaper.SetMouseModifier('MM_CTX_ITEM',14,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM',15,'-1')

reaper.SetMouseModifier('MM_CTX_ITEMLOWER',0,'13 m') -- Move item ignoring time selection
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',1,'58 m') -- Move item contents
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',2,'51 m') -- Move item ignoring time selection, enabling ripple edit for all tracks
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',3,'50 m') -- Move item ignoring time selection, enabling ripple edit for this track
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',4,'2 m') -- Copy item
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',5,'56 m') -- Move item contents ignoring snap, ripple earlier adjacent items
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',6,'7 m') -- Render item to new file
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',7,'39 m') -- Copy item, pooling MIDI source data
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',8,'32 m') -- Move item vertically
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',9,'57 m') -- Move item contents and right edge ignoring snap, ripple later adjacent items
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',10,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',11,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',12,'36 m') -- Copy item vertically
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',13,'55 m') -- Move item contents ignoring snap, ripple all adjacent items
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',14,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER',15,'-1')

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

reaper.SetMouseModifier('MM_CTX_TRACK',0,'9 m') -- Marquee select items
reaper.SetMouseModifier('MM_CTX_TRACK',1,'13 m') -- Marquee add to item selection
reaper.SetMouseModifier('MM_CTX_TRACK',2,'16 m') -- Draw a copy of the selected media item, pooling MIDI source data
reaper.SetMouseModifier('MM_CTX_TRACK',3,'2 m') -- Draw a copy of the selected media item ignoring snap
reaper.SetMouseModifier('MM_CTX_TRACK',4,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',5,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',6,'16 m') -- Draw a copy of the selected media item, pooling MIDI source data
reaper.SetMouseModifier('MM_CTX_TRACK',7,'17 m') -- Draw a copy of the selected media item ignoring snap, pooling MIDI source data
reaper.SetMouseModifier('MM_CTX_TRACK',8,'14 m') -- Move time selection
reaper.SetMouseModifier('MM_CTX_TRACK',9,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',10,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',11,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',12,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',13,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',14,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK',15,'-1')

reaper.SetMouseModifier('MM_CTX_TRACK_CLK',0,'1 m') -- Deselect all items and move edit cursor
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',1,'5 m') -- Extend time selection
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',2,'2 m') -- Deselect all items and move edit cursor ignoring snap
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',3,'6 m') -- Extend time selection ignoring snap
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',4,'8 m') -- Restore previous zoom level
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',5,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',6,'4 m') -- Clear time selection
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',7,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',8,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',9,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',10,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',11,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',12,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',13,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',14,'-1')
reaper.SetMouseModifier('MM_CTX_TRACK_CLK',15,'-1')


reaper.SetMouseModifier('MM_CTX_ITEM_CLK',0,'_1eb32b1b95474949883ca579137d130f') -- Custom: ReaTooled Move Tool Left Click
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',1,'17 m') -- Add items to selection and set time selection to selected items
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',2,'4 m') -- Toggle item selection
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',3,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',4,'15 m') -- Add stretch marker
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',5,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',6,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',7,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',8,'42391 c') -- Item: Quick add take marker at mouse position
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',9,'18 m') -- Add/edit take marker
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',10,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',11,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',12,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',13,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',14,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_CLK',15,'-1')

reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',0,'_1eb32b1b95474949883ca579137d130f') -- Custom: ReaTooled Move Tool Left Click
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',1,'17 m') -- Add items to selection and set time selection to selected items
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',2,'4 m') -- Toggle item selection
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',3,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',4,'15 m') -- Add stretch marker
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',5,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',6,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',7,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',8,'42391 c') -- Item: Quick add take marker at mouse position
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',9,'18 m') -- Add/edit take marker
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',10,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',11,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',12,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',13,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',14,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_CLK',15,'-1')

reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',0,'6 m') -- MIDI: open in editor, Subprojects: open project, Audio: show media item properties
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',1,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',2,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',3,'-1')
reaper.SetMouseModifier('MM_CTX_ITEM_DBLCLK',4,'-1')
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

reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',0,'6 m') -- MIDI: open in editor, Subprojects: open project, Audio: show media item properties
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',1,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',2,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',3,'-1')
reaper.SetMouseModifier('MM_CTX_ITEMLOWER_DBLCLK',4,'-1')
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

UpdateState()

reaper.Main_OnCommand(40569,0) --enable locking
reaper.Main_OnCommand(40595,0) -- set item edges lock
reaper.Main_OnCommand(40598,0) --set item fades lock
reaper.Main_OnCommand(41852,0) --set item stretch markers lock
reaper.Main_OnCommand(41849,0) --set item envelope
reaper.Main_OnCommand(40572,0) --set time selection to UNlock
  --reaper.Main_OnCommand(40571,0) --set time selection to lock  

reaper.Main_OnCommand(42621, 0) -- clear arrange override mode
