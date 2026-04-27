function do_stuff()
numitems=reaper.CountSelectedMediaItems(0)
for i = 0, numitems-1, 1 do

  local ih=reaper.GetSelectedMediaItem(0,i)
  local item_len=reaper.GetMediaItemInfo_Value(ih, "D_LENGTH")
  local th=reaper.GetActiveTake(ih)       
  local nb,name=reaper.GetSetMediaItemTakeInfo_String(th, 'P_NAME', '', false)
  --reaper.ShowConsoleMsg(name .. "\n")
  --local nb,name=reaper.GetSetMediaItemTakeInfo_String(th, 'P_NAME', tostring(i), true)
  local pitch=-12.0-1.0/numitems*i
  reaper.SetMediaItemTakeInfo_Value(th,'D_PITCH',pitch)
  local len=0.3-0.19/numitems*i
  reaper.SetMedia ItemInfo_Value(ih, "D_LENGTH",len)
end
reaper.UpdateArrange()
end

troll_image=0

local TrollFace = {} -- the table representing the class, which will double as the metatable for the instances
TrollFace.__index = TrollFace -- failed table lookups on the instances should fallback to the class table, to get methods

-- syntax equivalent to "MyClass.new = function..."
function TrollFace.new(x,y,ro)
  local self = setmetatable({}, TrollFace)
  self.xcor = x
  self.ycor = y
  local im_w, im_h=gfx.getimgdim(troll_image)
  
  self.w = im_w*0.25
  self.h = im_h*0.25
  self.rotate = ro
  self.stopped = true
  self.scale = 0.25
  self.on_clicked=function() end
  return self
end

MyTrolls={}

function is_in_rect(xcora,ycora,xa,ya,wa,ha)
if (xcora>=xa and xcora<xa+wa and ycora>=ya and ycora<ya+ha) then
  return true
end
return false
end

was_clicked=false
last_mouse_cap=0
hot_troll=0

function rotate_point(x,y,angle,cx,cy)
local s=math.sin(angle)
local c=math.cos(angle)
x=x-cx
y=y-cx
local newx=x * c - y * s;
local newy=x * s + y * c;
return newx + cx, newy + cy
end

function on_frame()
  if last_mouse_cap~=gfx.mouse_cap then last_mouse_cap=gfx.mouse_cap end  
  if last_mouse_cap==0 then was_clicked=false end
  local troll_index=1
  reaper.SetCursorPositi
  for key,value in pairs(MyTrolls) do
    gfx.x=value.xcor
    gfx.y=value.ycor
    gfx.drawstr(troll_index)
    --gfx.blit(troll_image, value.scale, value.rotate)
    norm_x=1.0/gfx.w*value.xcor
    norm_y=1.0/gfx.h*value.ycor
    reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,troll_index-1),"D_PAN",-1.0+2.0*norm_x)    
    reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,troll_index-1),"D_VOL",1.0-norm_y)
    if gfx.mouse_wheel~=0 then 
      rot_am=0.1
      if gfx.mouse_wheel<0 then rot_am=-rot_am end
      local rx,ry=rotate_point(value.xcor,value.ycor,rot_am,300.0,300.0)
      value.xcor=rx
      value.ycor=ry
      --value.scale=value.scale-0.05
      
    end
    if is_in_rect(gfx.mouse_x,gfx.mouse_y,value.xcor,value.ycor,value.w,value.h)==true then
      if hot_troll==0 and gfx.mouse_cap==1 then
        hot_troll=troll_index
      end
      gfx.r=1.0; gfx.g=1.0; gfx.b=0.0; gfx.a=0.5;
      gfx.rect(gfx.x,gfx.y,value.w,value.h)
      gfx.a=1.0;
      
      if gfx.mouse_wheel>0 then
        --value.scale=value.scale+0.05
        --gfx.mouse_wheel=0
      end
      if last_mouse_cap==1 and was_clicked==false then value.on_clicked(value); was_clicked=true; end
      
      end
      if value.stopped==false then
        value.rotate=value.rotate+0.1
    end
    troll_index=troll_index+1
  end
  gfx.update()
  if gfx.mouse_cap==0 then hot_troll=0 end
  if hot_troll~=0 and gfx.mouse_cap==1 then
    --reaper.ShowConsoleMsg("fo")
    adj_x=MyTrolls[hot_troll].xcor
    adj_x=gfx.mouse_x-(MyTrolls[hot_troll].w*1.0)/2
    adj_y=MyTrolls[hot_troll].ycor
    adj_y=gfx.mouse_y-(MyTrolls[hot_troll].h*1.0)/2
    MyTrolls[hot_troll].xcor=adj_x
    MyTrolls[hot_troll].ycor=adj_y
    
  end
  gfx.mouse_wheel=0
  reaper.defer(on_frame)
end

gfx.init("Xenakios Lua Test",600,600,0)
troll_image=gfx.loadimg(1,"C:/Net_Downloads/06102014/Transparent_Troll_Face.png")
if troll_image~=1 then reaper.ShowConsoleMsg("failed to load trollface\n") end
reaper.atexit(function() 
     reaper.SetExtState("lua_test","pippeli",gfx.dock(-1),true)
     gfx.quit() 
    end)
for i=1, 8 do
      MyTrolls[i] = TrollFace.new(300+280.0*math.sin(3.141592/4*i),300+280.0*math.cos(3.141592/4*i))
      --MyTrolls[i]. on_clicked=function(self) self.stopped=not self.stopped end
end
--MyTrolls[8].on_clicked=function()
--reaper.Main_OnCommand(40044,0)
--end

on_frame()

