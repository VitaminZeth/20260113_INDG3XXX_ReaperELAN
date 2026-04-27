import utils


num_items =  RPR_CountSelectedMediaItems(0)
items = []
for i in range(num_items):
	items.append(RPR_GetSelectedMediaItem(0, i))

utils.deselect()

for i in range(num_items):

	item = items[i]

	utils.setToAudioTake(item)

# RPR_Main_OnCommand(40209, 0)