XYControl = {}

XYControl.__index = XYControl

idcounter=1

function is_in_rect(xcora,ycora,xa,ya,wa,ha)
if (xcora>=xa and xcora<xa+wa and ycora>=ya and ycora<ya+ha) then
  return true
end
return false
end

function rotate_point(x,y,angle,cx,cy)
	local s=math.sin(angle)
	local c=math.cos(angle)
	x=x-cx
	y=y-cx
	local newx=x * c - y * s;
	local newy=x * s + y * c;
	return newx + cx, newy + cy
end


function get_hot_handle(xyco,x_,y_)
  for key,handle in pairs(xyco.handles) do
    hxcor=xyco.w*handle[1]
	hycor=xyco.h*handle[2]
	if is_in_rect(x_,y_,hxcor-8.0,hycor-8.0,16.0,16.0)==true then
	  return handle
	end
  end
  return {}  
end

function XYControl.new(x_,y_,w_,h_)
  local self = setmetatable({}, XYControl)
  self.handles={}
  self.id = idcounter
  idcounter = idcounter+1  
  self.x = x_
  self.y = y_
  self.w = w_
  self.h = h_
  self.mouse_down=false
  self.on_mousewheel=function(wid) end
  self_hot_handle={}
  self.draw=function(wid) 
    
	--gfx.line(w.x,w.y,w.x+w.w,w.y+w.h)
    --gfx.line(w.x,w.y+w.h,w.x+w.w,w.y)
	local handlecount=0
	for key,handle in pairs(wid.handles) do
	  if wid.hot_handle==handle then
	    gfx.r=1.0; gfx.g=1.0; gfx.b=1.0; gfx.a=1.0;
	  else
	    gfx.r=1.0; gfx.g=1.0; gfx.b=1.0; gfx.a=0.5;
	  end
	  gfx.circle(wid.x+handle[1]*wid.w,wid.y+handle[2]*wid.h,10.0,true,true)
	  gfx.r=0; gfx.g=0; gfx.b=0; gfx.a=1;
	  gfx.x=wid.x+handle[1]*wid.w-3
	  gfx.y=wid.y+handle[2]*wid.h-3
	  gfx.drawstr(handlecount)
	  handlecount=handlecount+1
	end
	gfx.r=1.0; gfx.g=1.0; gfx.b=1.0; gfx.a=0.3;
	gfx.rect(wid.x,wid.y,wid.w,wid.h,false)
  end
  self.on_mousedown=function(wid)
    wid.mouse_down=true
	--reaper.ShowConsoleMsg("whee! " .. gfx.mouse_x .. "\n")
  end
  self.on_mousemove=function(wid)
    if wid.mouse_down==false then
	  wid.hot_handle=get_hot_handle(wid,gfx.mouse_x-wid.x,gfx.mouse_y-wid.y)
	end
	if wid.mouse_down==true then
	  if wid.hot_handle~=nil then
	    local norm_x=1.0/wid.w*(gfx.mouse_x-wid.x)
		local norm_y=1.0/wid.h*(gfx.mouse_y-wid.y)
		wid.hot_handle[1]=norm_x
		wid.hot_handle[2]=norm_y
		local fun=wid.hot_handle[3]
		if fun~=nil then fun(norm_x,norm_y) end
	  end
	  --reaper.ShowConsoleMsg("mouse dragged over " .. wid.id .. " " .. gfx.mouse_x .. ":" .. gfx.mouse_y .. "\n")
	  
	end
  end
  self.on_mouseup=function(wid) wid.mouse_down=false end
  return self
end

function add_handle(xyco,x_,y_,change_func_)
  if change_func_==nil then change_func_=function(nx,ny) end end
  xyco.handles[#xyco.handles+1]={x_,y_,change_func_}
end

function perkele()
reaper.APITest()
end




