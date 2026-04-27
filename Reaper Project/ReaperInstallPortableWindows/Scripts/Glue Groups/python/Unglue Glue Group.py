import utils
from time import time



# init
t = time()


def unglueGroup():

	# count selected items
	num_items = RPR_CountSelectedMediaItems(0)

	# make sure we selected something that is a glued group instance
	glue_group_data = utils.checkForGlueGroup(False)

	if glue_group_data:

		glue_group = glue_group_data["glue_group"]
		item = glue_group_data["item"]
		glue_group_container_string = "glue_group_container:"+str(glue_group)+":"

		# store state of glued item (for adding to containers notes)
		original_state = utils.getSetObjectState(item)
		p = prefix = "\n|                                                                                                                "
		for i in range(70): 
			prefix += p
		original_state = prefix+"\n|glue_group_original_state:\n|"+original_state.replace("\n", "\n|")

		original_pos = RPR_GetMediaItemInfo_Value(item, "D_POSITION")

		original_track = RPR_GetMediaItemTrack(item)
		glue_track = utils.getTrackFromGlueGroup(glue_group)

		RPR_SetMediaTrackInfo_Value(glue_track, "B_SHOWINTCP", True)
		RPR_TrackList_AdjustWindows(True)

		# deselect all
		utils.deselect()
		# select glue track
		RPR_SetOnlyTrackSelected(glue_track)

		# loop through and re-add items
		num_items = RPR_GetTrackNumMediaItems(glue_track)
		offset = 0
		restored_items = []
		for i in range(num_items):
			glue_item = RPR_GetTrackMediaItem(glue_track, i)
			restored_item = RPR_AddMediaItemToTrack(original_track)
			state = utils.getSetObjectState(glue_item)

			if glue_group_container_string in state:
				state = state.replace(glue_group_container_string, glue_group_container_string+original_state)

			utils.getSetObjectState(restored_item, state)
			item_pos = RPR_GetMediaItemInfo_Value(restored_item, "D_POSITION")
			if i == 0: offset = item_pos
			RPR_SetMediaItemInfo_Value(restored_item, "D_POSITION", original_pos + item_pos - offset)
			RPR_SetMediaItemInfo_Value(restored_item, "I_GROUPID", 0)

			restored_items.append(restored_item)


		for i in range(num_items):
			utils.restoreOriginalTake(restored_items[i])

		for i in range(num_items):
			RPR_SetMediaItemSelected(restored_items[i], True)

		# Group items
		RPR_Main_OnCommand(40032, 0)

		#remove item from track
		RPR_DeleteTrackMediaItem(original_track, item)

		RPR_SetMediaTrackInfo_Value(glue_track, "B_SHOWINTCP", False)

		# select original track
		RPR_SetOnlyTrackSelected(original_track)



RPR_Undo_BeginBlock();


RPR_PreventUIRefresh(1)

# do the unglue
unglueGroup()


# clean up
RPR_UpdateTimeline()
RPR_UpdateArrange()
RPR_TrackList_AdjustWindows(True)
# zoom in then out
RPR_Main_OnCommand(1011, 0)
RPR_Main_OnCommand(1012, 0)


RPR_PreventUIRefresh(-1)


# utils.log("Done in:", time()-t)


RPR_Undo_EndBlock("Unglue Glue Group", -1)







