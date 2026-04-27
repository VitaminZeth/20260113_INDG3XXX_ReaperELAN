fader_img=0

egenvelopes={}

egsliders={}

notevalues={{1,8,"32nd"},
            {1,5,"16th quintuplet"},
            {1,4,"16th"},
            {1,3,"8th triplet"},
            {1,2,"8th"},
            {6,8,"8th dotted"},
            {4,5,"4th quintuplet"},
            {1,1,"4th"},
            {6,4,"4th dotted"},
            {4,2,"Half"},
            {4,1,"Whole"}}
            
use_note_rates=false            

function make_slider(x,y,w,h,val,name,valcb)
  slider={}
  slider.x=function() return x end
  slider.y=function() return y end
  slider.w=function() return gfx.w-60 end
  slider.h=function() return 20 end
  slider.value=val
  slider.valcb=valcb
  slider.name=name
  slider.type="Slider"
  slider.env_enabled=false
  slider.envelope= {{ 0.0, val }, { 0.25, val } , { 0.75 ,val } , { 1.0,val }}
  slider.OnMouse=function(theslider, whichevent, x, y, extra) 
      --reaper.ShowConsoleMsg(tostring(theslider).." "..x.." "..y.."\n") 
    end
  return slider
end

function make_envelope(x,y,w,h,assocslider)
  result={}
  result.x=function() return x end
  result.y=function() return y end
  result.w=function() return gfx.w-20 end
  result.h=function() return h end
  
  result.type="Envelope"
  result.hotpoint=0
  result.envelope=assocslider.envelope
  result.name=assocslider.name
  return result
end

function make_button(x,y,w,h,click_cb)
  result={}
  result.x=function() return x end
  result.y=function() return y end
  result.w=function() return w end
  result.h=function() return h end
  result.type="Button"
  result.name="MyButton"
  result.OnClick=click_cb
  result.checked=true
  return result
end

function bound_value(minval, val, maxval)
if val<minval then return minval end
if val>maxval then return maxval end
return val
end

function quantize_value(val, numsteps)
  return 1.0/numsteps*math.floor(val*numsteps)
end

envelope_ranges={["Volume"] = {0.0,2.0}, ["Volume (Pre-FX)"] = {0.0,2.0},
                 ["Pan"] = {-1.0,1.0}, ["Pan (Pre-FX)"] = {-1.0,1.0}, ["Playrate"]={0.1,4.0} }

function get_envelope_range(env)
  rv, name=reaper.GetEnvelopeName(env, "")
  if rv==true then
    if envelope_ranges[name]~=nil then 
      return envelope_ranges[name][1],envelope_ranges[name][2] end
    --if name=="Volume" or name=="Volume (Pre-FX)" then return 0.0,2.0 end
    --if name=="Pan" or name=="Pan (Pre-FX)" then return -1.0,1.0 end
  end
  return 0.0,1.0
end

function is_in_rect(xcora,ycora,xa,ya,wa,ha)
if (xcora>=xa and xcora<xa+wa and ycora>=ya and ycora<ya+ha) then
  return true
end
return false
end

function slider_to_value(slid)
  
end

function slider_to_string(slid)
  if slid.name=="Quant steps" then return math.floor(3+slid.value*61) end
  if slid.name=="Rate" and use_note_rates==true then
    local nvindex=math.floor(1+(#notevalues-1)*slid.value)
    return notevalues[nvindex][3]
  end
  return tostring(slid.value)
end

function draw_slider(slid)
  if slid.type~="Slider" then return end
  --local imgw,imgh=gfx.getimgdim(fader_img)
  local imgw = 32
  local imgh = 25
  gfx.r=1.0; gfx.g=1.0; gfx.b=1.0; gfx.a=1.0;
  gfx.x=slid.x()+3
  gfx.y=slid.y()+2
  gfx.drawstr(slid.name .. " " .. slider_to_string(slid))
  gfx.rect(slid.x(),slid.y(),slid.w(),imgh-1,false)
  local thumbx=slid.x()+(slid.w()-(imgw/1))*slid.value
  gfx.a=0.5
 
  gfx.rect(thumbx,slid.y(),imgw,imgh,true)  
  --gfx.blit(fader_img,1.0,0.0,0,0,imgw,imgh-1,thumbx,slid.y,imgw,imgh-1)
  gfx.a=1.0
end

function draw_button(but)
  if but.type~="Button" then return end
  gfx.r=1.0; gfx.g=1.0; gfx.b=1.0; gfx.a=1.0;
  gfx.rect(but.x(),but.y(),but.w(),but.h(),false)
  if but.checked==true then
    gfx.line(but.x(),but.y(),but.x()+but.w(), but.y()+but.h())
    gfx.line(but.x(),but.y()+but.h(),but.x()+but.w(),but.y())
  end
end

function draw_envelope(env,enabled)
  if env.type~="Envelope" then return end
  gfx.r=1.0; gfx.g=1.0; gfx.b=1.0; gfx.a=1.0
  gfx.x=env.x()+8; gfx.y=env.y()+8
  local title=env.name
  if enabled==true then title=title.." (enabled)" else title=title.." (disabled)" end
  
  gfx.drawstr(title)
  local xcor0=0.0
  local ycor0=0.0
  local i=1
  for key,envpoint in pairs(env.envelope) do
    local xcor = env.x()+envpoint[1]*env.w()
    local ycor = env.y()+(1.0-envpoint[2])*env.h()
    
    if i>1 then
      --reaper.ShowConsoleMsg(i.." ")
      gfx.r=1.0; gfx.g=1.0; gfx.b=1.0; gfx.a=0.7;
      gfx.line(xcor0,ycor0,xcor,ycor,true)
    end
    xcor0=xcor
    ycor0=ycor
    
    if env.hotpoint==i then
      gfx.r=0.0; gfx.g=1.0; gfx.b=0.0; gfx.a=1.0;
    else
      gfx.r=1.0; gfx.g=0.0; gfx.b=0.0; gfx.a=1.0;
    end
    i=i+1
    gfx.circle(xcor,ycor,5.0,true,true)
  end
end

function get_hot_env_point(env,mx,my)
  for key,envpoint in pairs(env.envelope) do
    local xcor = env.x()+envpoint[1]*env.w()
    local ycor = env.y()+(1.0-envpoint[2])*env.h()
    if is_in_rect(mx,my,xcor-5,ycor-5,10,10) then return key end
  end
 
  return 0
end

function get_env_interpolated_value(env,x)
  if #env==0 then return 0.0 end
  if x<env[1][1] then return env[1][2] end
  if x>env[#env][1] then return env[#env][2] end
  local i=1
  for key,envpoint in pairs(env) do
    if x>=envpoint[1] then
      nextpt=env[key+1]
      if nextpt==nil then nextpt=envpoint end
      if x<nextpt[1] then
        local timedelta=nextpt[1]-envpoint[1]
        if timedelta<0.0001 then timedelta=0.0001 end
        local valuedelta=nextpt[2]-envpoint[2]
        local interpos=(x-envpoint[1])
        return envpoint[2]+valuedelta*((1.0/timedelta)*interpos)
      end
    end
    i=i+1
  end
  return 0.0
end

function sort_envelope(env)
  table.sort(env,function(a,b) return a[1]<b[1] end)
end

last_used_params={}

last_envelope=nil

function segment_value(cnt)
  if cnt % 4 == 0 then return 0.0 end
  if cnt % 4 == 1 then return 1.0 end
  if cnt % 4 == 2 then return 0.0 end
  return -1.0
end

function segment_tension(cnt,tension)
  if cnt % 4 == 0 then return -tension end
  if cnt % 4 == 1 then return tension end
  if cnt % 4 == 2 then return -tension end
  return tension
end

function generate(freq,amp,center,phase,randomness,quansteps,tilt,fadindur,fadoutdur,ratemode,clip)
  --reaper.ShowConsoleMsg("generating ")
  math.randomseed(1)
  env=reaper.GetSelectedEnvelope(0)
  if env==nil then return end
  local envscalingmode=reaper.GetEnvelopeScalingMode(env)
  local time_start, time_end=reaper.GetSet_LoopTimeRange(false, false, 0.0, 0.0, false)
  if time_end<=time_start then return end
  local time=time_start
  --local freqhz=1.0+7.0*freq^2.0
  local nvindex=math.floor(1+(#notevalues-1)*freq)
  local dividend=notevalues[nvindex][1]
  local divisor=notevalues[nvindex][2]
  --reaper.ShowConsoleMsg(dividend .. " " .. divisor .. "\n")
  local freqhz=1.0
  if ratemode>0.5 then
    freqhz=(reaper.Master_GetTempo()/60.0)*1.0/(dividend/divisor)
  else
    freqhz=0.1+(31.9*freq^2.0)
  end
  
  local minv,maxv=get_envelope_range(env)
  local gen_end_time=time_end
  if ratemode>0.5 then
    time=reaper.TimeMap_timeToQN(time_start)
    gen_end_time=reaper.TimeMap_timeToQN(time_end)
  end
  reaper.DeleteEnvelopePointRange(env, time_start,time_end+0.0001)
  local timeseldur=time_end-time_start
  local fadoutstart_time = time_end-time_start-timeseldur*fadoutdur
  if ratemode>0.5 then
    fadoutstart_time = reaper.TimeMap_timeToQN(fadoutstart_time)
    time_start = reaper.TimeMap_timeToQN(time_start)
  end
  local oscphase=phase
  local segshape=-1.0+2.0*tilt
  local ptcount=0
  while time<=gen_end_time do
    local time_to_interp = 1.0/timeseldur*(time-time_start)
    local freq_norm_to_use=get_env_interpolated_value(egsliders[1].envelope,time_to_interp)
    freqhz=0.2+(15.8*freq_norm_to_use^2.0)
    local phase=2*3.141592653*phase
    local fade_gain = 1.0
    if ratemode<0.5 then
      if time-time_start<timeseldur*fadindur then
        fade_gain=1.0/(timeseldur*fadindur)*(time-time_start)
      end
      if time-time_start>fadoutstart_time then
        fade_gain=1.0-(1.0/(timeseldur*fadoutdur)*(time-fadoutstart_time-time_start))
      end
    else
    
    end
    --local sineval = math.sin(2*3.141592653*(time-time_start)*freqhz+phase)
    local sineval = math.sin(oscphase)
    local clip_amp = 1.0+clip*2.0
    local val = segment_value(ptcount) --bound_value(-1.0,clip_amp*sineval,1.0)
    
    --if time_to_interp<0.0 or time_to_interp>1.0 then
    --  reaper.ShowConsoleMsg(time_to_interp.." ") end
    local amp_to_use = get_env_interpolated_value(egsliders[2].envelope,time_to_interp)
    --if amp_to_use<0.0 or amp_to_use>1.0 then reaper.ShowConsoleMsg(amp_to_use.." ") end
    val=0.5+(0.5*amp_to_use*fade_gain)*val
    local center_to_use=get_env_interpolated_value(egsliders[3].envelope,time_to_interp)
    local rangea=maxv-minv
    val=minv+((rangea*center_to_use)+(-rangea/2.0)+(rangea/1.0)*val)
    local z=math.random()*randomness
    val=val+(-randomness/2.0)+z
    local tilt_ramp = 1.0/(gen_end_time-time_start) * (time-time_start)
    local tilt_amount = -1.0+2.0*tilt
    local tilt_delta = -tilt_amount+(2.0*tilt_amount)*tilt_ramp
    --val=val+tilt_delta
    local num_quansteps=3+quansteps*61
    if num_quansteps<64 then
      val=quantize_value(val,num_quansteps)
    end
    local instime=time
    if ratemode>0.5 then
      instime=reaper.TimeMap2_QNToTime(0, time)
    end
    val=bound_value(minv,val,maxv)
    val = reaper.ScaleToEnvelopeMode(envscalingmode, val)
    local tension = segment_tension(ptcount,segshape)
    reaper.InsertEnvelopePoint(env, instime, val, 5, tension, true, true)
    oscphase=oscphase+1.0/((2*3.141592653)/(freqhz))
    time=time+(1.0/freqhz/4.0)
    --time=time+(1.0/(freqhz*32))
    ptcount=ptcount+1
  end
  --if last_used_parms==nil then last_used_params={"}
  last_used_params[env]={freq,amp,center,phase,randomness,quansteps,tilt,fadindur,fadoutdur,ratemode,clip}
  reaper.Envelope_SortPoints(env)
  reaper.UpdateArrange()
end

captured_control=nil
was_changed=false
already_added_pt=false
already_removed_pt=false
last_mouse_cap=0

function update()
  if gfx.getchar()<0 then return end
  curenv=reaper.GetSelectedEnvelope(0)
  --if curenv==nil and last_envelope~=nil then curenv=last_envelope end
  if curenv~=last_envelope then 
    last_envelope=curenv
    if last_used_params[curenv]~=nil then
      for i=1, #egsliders do 
        if egsliders[i].type=="Slider" then
          --egsliders[i].value=last_used_params[curenv][i]
        end
      end
    end
  end
  if gfx.mouse_cap==0 then 
    captured_control=nil
    already_added_pt=false 
    already_removed_pt=false
    if was_changed==true then
      reaper.Undo_OnStateChangeEx("Generate envelope points",1,-1) 
    end
    was_changed=false
  end
   local dogenerate=false
  for key,tempcontrol in pairs(egsliders) do
    --if key>=200 and tempcontrol.type=="Button" then reaper.ShowConsoleMsg(tostring(tempcontrol).." ") end
    if is_in_rect(gfx.mouse_x,gfx.mouse_y,tempcontrol.x(),tempcontrol.y(),tempcontrol.w(),tempcontrol.h()) then
      if gfx.mouse_cap==1 and captured_control==nil then
        captured_control=tempcontrol
      
      end
      if tempcontrol.type=="Slider" and gfx.mouse_cap==2 then
        gfx.x=gfx.mouse_x
        gfx.y=gfx.mouse_y
        local menuresult=gfx.showmenu("Toggle envelope active|Show envelope")
        if menuresult==1 then
          if tempcontrol.env_enabled==false then
            tempcontrol.env_enabled=true else
            tempcontrol.env_enabled=false
          end
        end
        if menuresult==2 then
          egsliders[100].envelope=tempcontrol.envelope
          egsliders[100].name=tempcontrol.name
        end
      end
      if tempcontrol.type=="Envelope" then
        if gfx.mouse_cap==0 then
          tempcontrol.hotpoint=get_hot_env_point(tempcontrol,gfx.mouse_x,gfx.mouse_y)
        end
        if tempcontrol.hotpoint==0 and gfx.mouse_cap==1 and already_added_pt==false then
          --reaper.ShowConsoleMsg("gonna add point ")
          local pt_x = 1.0/tempcontrol.w()*(gfx.mouse_x-tempcontrol.x())
          local pt_y = 1.0/tempcontrol.h()*(gfx.mouse_y-tempcontrol.y())
          tempcontrol.envelope[#tempcontrol.envelope+1]={ pt_x,1.0-pt_y }
          dogenerate=true
          already_added_pt=true
          sort_envelope(tempcontrol.envelope)
        end
        if already_removed_pt==false and tempcontrol.hotpoint>0 and gfx.mouse_cap == 17  then
          table.remove(tempcontrol.envelope,tempcontrol.hotpoint)
          dogenerate=true
          already_removed_pt=true
          --reaper.ShowConsoleMsg("remove pt "..tempcontrol.hotpoint)
        end       
        if tempcontrol==captured_control and tempcontrol.hotpoint>0 and gfx.mouse_cap==1 then
          local pt_x = 1.0/tempcontrol.w()*(gfx.mouse_x-captured_control.x())
          local pt_y = 1.0/captured_control.h()*(gfx.mouse_y-captured_control.y())
          ept = captured_control.envelope[captured_control.hotpoint]
          ept[1]=pt_x
          ept[2]=1.0-pt_y
          dogenerate=true
          --reaper.ShowConsoleMsg("would drag pt "..tempcontrol.hotpoint.."\n")
        end
      end
    end
    local env_enabled=false
    if captured_control~=nil then
      if captured_control.OnMouse~=nil then 
        --captured_control.OnMouse(captured_control, "drag", gfx.mouse_x,gfx.mouse_y, nil)
      end
      if captured_control.type=="Slider" then
        if captured_control.envelope==egsliders[100].envelope then 
          env_enabled=captured_control.env_enabled
        end
        local new_value=1.0/captured_control.w()*(gfx.mouse_x-tempcontrol.x())
        new_value=bound_value(0.0,new_value,1.0)
        --reaper.ShowConsoleMsg(captured_control.type .. " ")
        if captured_control.value~=new_value then
          dogenerate=true
          captured_control.value=new_value
        end
      end
    end
    draw_slider(tempcontrol)
    draw_envelope(tempcontrol,env_enabled)
    draw_button(tempcontrol)
  end
  if dogenerate==true then
    if egsliders[10].value>0.5 then use_note_rates=true else use_note_rates=false end 
    generate(egsliders[1].value,
    egsliders[2].value,
    egsliders[3].value,
    egsliders[4].value,
    egsliders[5].value,
    egsliders[6].value,
    egsliders[7].value,
    egsliders[8].value,
    egsliders[9].value,
    egsliders[10].value,
    egsliders[11].value)
    was_changed=true
  end
  last_mouse_cap=gfx.mouse_cap
  gfx.update()
  reaper.defer(update)
end

gfx.init("Envelope point generator",700,286+180,0)
for i=0,10 do
  local buttonkey=(i+200)
  new_button=make_button(655,12+i*25,20,20,nil)
  egsliders[buttonkey]=new_button
end
egsliders[1]=make_slider(10,10,0,0,0.5,"Rate", function(nx) end)
egsliders[2]=make_slider(10,35,0,0,0.5,"Amplitude",function(nx) end)
egsliders[3]=make_slider(10,60,0,0,0.5,"Center",function(nx) end)
egsliders[4]=make_slider(10,85,0,0,0.0,"Phase",function(nx) end)
egsliders[5]=make_slider(10,110,0,0,0.0,"Randomness",function(nx) end)
egsliders[6]=make_slider(10,135,0,0,1.0,"Quant steps",function(nx) end)
egsliders[7]=make_slider(10,160,0,0,0.5,"Segment shape",function(nx) end)
egsliders[8]=make_slider(10,185,0,0,0.0,"Fade in duration",function(nx) end)
egsliders[9]=make_slider(10,210,0,0,0.0,"Fade out duration",function(nx) end)
egsliders[10]=make_slider(10,235,0,0,0.0,"Rate mode",function(nx) end)
egsliders[11]=make_slider(10,260,0,0,0.0,"Clip",function(nx) end)
egsliders[100]=make_envelope(10,290,0,170,egsliders[1])
for key,tempcontrol in pairs(egsliders) do
  reaper.ShowConsoleMsg(key.." "..tempcontrol.type.." "..tempcontrol.name.."\n")
end
update()

