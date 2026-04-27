--local xyco = require '\\Scripts\\xy_control'
--dofile "C:/ProgrammingProjects/Projects/_lua/xy_control.lua"
dofile "/Users/teemu/codeprojects/reaper-lua-stuff/xy_control.lua"
MyWidgets={}
last_mouse_cap=0
was_clicked=false
last_mouse_x=0
last_mouse_y=0

function on_frame()
  if gfx.getchar()<0 then return end
  if last_mouse_cap~=gfx.mouse_cap then last_mouse_cap=gfx.mouse_cap end  
  if last_mouse_cap==0 then was_clicked=false end
  local mouse_was_moved=false
  if last_mouse_x~=gfx.mouse_x or last_mouse_y~=gfx.mouse_y then
    last_mouse_x=gfx.mouse_x; last_mouse_y=gfx.mouse_y;
    mouse_was_moved=true
  end
  for key,widget in pairs(MyWidgets) do
    if is_in_rect(gfx.mouse_x,gfx.mouse_y,widget.x,widget.y,widget.w,widget.h)==true then
      if last_mouse_cap==1 and was_clicked==false then 
        widget.on_mousedown(widget); was_clicked=true; 
      end
      if mouse_was_moved==true then
        widget.on_mousemove(widget)
      end
      if last_mouse_cap==0 then widget.on_mouseup(widget) end
      if gfx.mouse_wheel~=0 then 
        widget.on_mousewheel(widget)
      end
    end
    widget.draw(widget)
  end
  gfx.update()
  gfx.mouse_wheel=0
  reaper.defer(on_frame)
end

gfx.init("Xenakios Lua XYControl test",1000,800,0)
MyWidgets[1]=XYControl.new(0,0,498,498)
MyWidgets[2]=XYControl.new(500,0,498,498)
MyWidgets[2].on_mousewheel=function(wid)
  for key,handle in pairs(wid.handles) do
    local nx=handle[1]
    local ny=handle[2]
    local rotamt=0.1
    if gfx.mouse_wheel<0 then rotamt=-rotamt end
    nx, ny=rotate_point(nx,ny,rotamt,0.5,0.5)
    handle[1]=nx
    handle[2]=ny
    handle[3](nx,ny)
  end
end
MyWidgets[3]=XYControl.new(0,500,1000,300)
add_handle(MyWidgets[3],0.5,0.5)
for i=0, 7 do
  add_handle(MyWidgets[1],1.0/7*i,0.6,function(nx,ny) 
    local track=reaper.GetTrack(0,i)
    reaper.SetMediaTrackInfo_Value(track,"D_PAN",-1.0+2.0*nx)
    reaper.SetMediaTrackInfo_Value(track,"D_VOL",1.0-ny)
    end)
end
--add_handle(MyWidgets[1],0.55,0.55)
--[[
add_handle(MyWidgets[2],0.25,0.5,function(nx,ny)
  local track=reaper.GetTrack(0,0)
  local vol_env=reaper.GetTrackEnvelopeByName(track, "Volume")
  if vol_env~=nil then
    reaper.SetEnvelopePoint(vol_env,0,0.0,1.0-ny,0,0.5,false,false)
    reaper.SetEnvelopePoint(vol_env,1,1.0,ny,0,0.5,false,false)
    --reaper.SetEnvelopePoint(vol_env,1,1.0,ny)
  end
  reaper.UpdateArrange()
end)
--]]

for i=0, 7 do
add_handle(MyWidgets[2],1.0/7*i,0.5,function(nx,ny)
  --3 11
  local track=reaper.GetTrack(0,0)
  reaper.TrackFX_SetParamNormalized(track, 0, 2+i*10+1, 1.0-ny)  
  reaper.TrackFX_SetParamNormalized(track, 0, 2+i*10+9, nx)  
end)
end
reaper.atexit(function() 
     for k,v in pairs(MyWidgets[2].handles) do
       local hstate = { ["hx"] = v[1], ["hy"] = v[2]}
       reaper.SetProjExtState(0, "xy_test", k, v[1] .. " " .. v[2])
     end
     --reaper.ShowConsoleMsg("quit xy test!\n")
     gfx.quit() 
    end)
on_frame()

--MyWidgets[1]=XYControl.new(0,0,600,600)
--perkele()


