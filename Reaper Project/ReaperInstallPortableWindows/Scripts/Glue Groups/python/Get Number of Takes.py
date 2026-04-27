import utils



item = RPR_GetSelectedMediaItem(0, 0)

num_takes = RPR_GetMediaItemNumTakes(item)

utils.logK(num_takes=num_takes)






