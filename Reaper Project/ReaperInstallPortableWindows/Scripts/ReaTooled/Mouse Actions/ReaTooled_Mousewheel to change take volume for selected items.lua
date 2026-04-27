-- @description Mousewheel Take Volume
-- @author Brenadn Baker (But really modified/copied from Aaron Cendan)
-- @version 1.0
-- @metapackage
-- @provides
--   [main] . > acendan_Mousewheel to zoom items peaks view gain.lua
-- @link https://aaroncendan.me
-- @about
--   # I TOTALLY COPIED THIS FROM NVK THANK YOU <3
--    What a horrible name

speed = 0 --0 is slowest speed. Set to higher integers to zoom faster


local function no_undo()reaper.defer(function()end)end

function Main()
  is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
  if val < 0 then
    for i = 0, speed do
      reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_NUDGETAKEVOLUP"), 0) -- Xenakios/SWS: Nudge active take volume up
    end
  else
    for i = 0, speed do
      reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_NUDGETAKEVOLDOWN"), 0) -- Xenakios/SWS: Nudge active take volume down
    end
  end
  reaper.SetCursorContext(1, nil)
end


--scrName = ({reaper.get_action_context()})[2]:match(".+[/\\](.+)")
--reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
--reaper.Undo_EndBlock(scrName, -1)
--no_undo()

