--[[
-- @description ReaTooled - Nudge left by last nudge dialogue settings and move cursor
-- @version 1.0
-- @date 2024.11.18
-- @author Brendan Baker
-- @link http://brendanpatrickbaker.com/reatooled/
-- @about
    # Nudges and moves the edit cursor
--]]

function main()

reaper.Undo_BeginBlock()
reaper.Main_OnCommand(41250,0) -- Item edit: Nudge left by last nudge dialog settings
reaper.Main_OnCommand(41173,0) -- Item navigation: Move cursor to start of items
reaper.Undo_EndBlock("Nudge left", -1)
end

main()

