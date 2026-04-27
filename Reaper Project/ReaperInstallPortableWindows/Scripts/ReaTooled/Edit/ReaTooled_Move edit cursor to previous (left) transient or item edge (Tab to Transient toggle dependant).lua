--[[
@description ReaTooled OPTION TAB function similar to Protools
@version 1.1
@author Tim Farrell (modified by Brendan Baker for ReaTooled)
@link http://github.com/sonictim/TJF-Scripts/
@date 2024 03 12
@about
  # Mimics Protools Option Tab Function.
  Will require TJF Toggle Tab to Transient script which can be assigned to a button
  must be installed in the correct directory to work

--]]



function main()

local cmd_id = reaper.NamedCommandLookup("_RSf475a3ed46e25a1ef9d2a8b4ad6aab87c94102a1")  --get ID of ReaTooled Toggle Tab to Transient
local transient = reaper.GetToggleCommandStateEx(0,cmd_id)  -- get command state

reaper.Main_OnCommand(41229, 0)  --Calls command "Selection set: Save set #01"
reaper.Main_OnCommand(40421, 0)  --Calls command "Item: Select all items in track"


    if transient==1 then

       reaper.Main_OnCommand(40376, 0) --Calls command "Item navigation: Move cursor to previous transient in items"

    else


      reaper.Main_OnCommand(40318, 0)  --Calls command "Item navigation: Move cursor left to edge of item"

    end

    reaper.Main_OnCommand(41239, 0)  --Calls command "Selection set: Load set #01"

end


main()

reaper.defer(function() end) --this prevents undo
