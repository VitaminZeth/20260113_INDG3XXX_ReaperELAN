last_time=0.0
last_state=0

function update()
  local cur_time=reaper.time_precise()  
  if cur_time-last_time>=1.0 then
    local command_id=reaper.NamedCommandLookup("_105162f8caacea4b8e4d2b5b5a5b647e")
    --reaper.ShowConsoleMsg(command_id.." ")
    reaper.SetToggleCommandState(0, command_id, last_state)
    
    last_time=cur_time
    if last_state==0 then last_state=1 else last_state=0 end
    --reaper.ShowConsoleMsg(last_state .. " ")
    reaper.RefreshToolbar(command_id)
  end
  reaper.defer(update)
end

update()

