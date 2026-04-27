item=reaper.AddMediaItemToTrack(reaper.GetTrack(0,0))
take=reaper.AddTakeToMediaItem(item)
reaper.SetMediaItemInfo_Value(item,"D_POSITION",0.0)
src=reaper.PCM_Source_CreateFromFile("C:/MusicAudio/sourcesamples/count.wav")
if src==nil then reaper.ShowConsoleMsg("pcm_source wasn't created\n")
else
reaper.SetMediaItemTake_Source(take, src)
retval, lengthIsQNOut = reaper.GetMediaSourceLength(src)
reaper.SetMediaItemInfo_Value(item,"D_LENGTH",retval)
end




