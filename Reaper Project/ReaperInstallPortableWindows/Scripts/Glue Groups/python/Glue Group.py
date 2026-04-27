import utils
from time import time
from sws_python import * 


# init
t = time()


def glueGroup():

	num_items = RPR_CountSelectedMediaItems(0)
	if not num_items: return

	# select whole group if its in one
	RPR_Main_OnCommand(40034, 0)

	# Group Items regardless
	RPR_Main_OnCommand(40032, 0)

	# store a reference to the original item
	source_item = RPR_GetSelectedMediaItem(0, 0);

	# store a pointer to the original track
	source_track = RPR_GetMediaItemTrack(source_item)

	# is this a reglueing of a previously glued item?
	glue_group = utils.checkForGlueGroup()

	if glue_group:
		glued_item = reGlue(source_track, source_item, glue_group)
	else:
		glued_item = doGlue(source_track, source_item)

	if glued_item:
		# deselect all
		utils.deselect()
		#select glued item
		RPR_SetMediaItemSelected(glued_item, True)
		#move cursor to item
		RPR_Main_OnCommand(41173, 0)


def doGlue(source_track, source_item, glue_group = False, existing_container = False):

	# make a new glue_group id from the group id if this is a new group, and name glue_track accordingly
	if not glue_group:
		glue_group = int(RPR_GetMediaItemInfo_Value(source_item, "I_GROUPID"))

	#count items to be added
	num_items = RPR_CountSelectedMediaItems(0)

	# keep track of original items
	original_items = []
	freezeString = ""
	for i in range(num_items):
		item = RPR_GetSelectedMediaItem(0, i)
		original_items.append( item )
		if(item == existing_container): continue
		state = utils.getSetObjectState(item)
		freezeString += state

	for i in range(num_items):
		utils.setToAudioTake( original_items[i] )

	for i in range(num_items):
		RPR_SetMediaItemSelected(original_items[i], True)

	# if we are passing in a container (eg a reglue from a container)
	if existing_container:
		# duplicate container so its still there after glue
		container = utils.duplicateItems([existing_container], -2, False)[0]
	else:
		# store reference to a new container
		container = RPR_AddMediaItemToTrack(source_track)
		# assign glue group
		utils.setItemGlueGroup(container, glue_group)
	
	# glue selected items
	RPR_Main_OnCommand(41588, 0)
	#store ref to new glued item
	glued_item = RPR_GetSelectedMediaItem(0, 0);
	#store a reference to this glue group in the glued item
	utils.setItemGlueGroup(glued_item, glue_group, False)

	# make sure the container is big enough
	container_length = RPR_GetMediaItemInfo_Value(container, "D_LENGTH")
	new_length = RPR_GetMediaItemInfo_Value(glued_item, "D_LENGTH")
	if(container_length < new_length):
		RPR_SetMediaItemInfo_Value(container, "D_LENGTH", new_length)

	freezeString = "\n<FREEZE 1\n"+utils.getSetObjectState(container)+freezeString+">\n"


	track_state = utils.getSetObjectState(source_track)
	track_state = track_state[:-2]

	track_state += freezeString + ">"

	utils.getSetObjectState(source_track, track_state)

	RPR_DeleteTrackMediaItem(source_track, container)

	utils.log(utils.getSetObjectState(source_track))

	return glued_item
	


def reGlue(source_track, source_item, glue_group):
	#store vars from glue_group dict
	container = glue_group["item"];
	glue_group = glue_group["glue_group"]

	# get the original state from the container
	original_state = False
	container_state = utils.getSetObjectState(container)
	regexp = r"glue_group_original_state:((\n\|[^\n\r]*)*)"
	ex = re.compile(regexp, re.M)
	match = ex.search(container_state)
	if match: 
		original_state = match.group(1).replace("\n|", "\n")

	if original_state:
		# clear the original state from the container
		regexp = r"(\n\| *)*\n\|glue_group_original_state:(\n\|[^\n\r]*)*"
		state = re.sub(regexp, "", container_state, flags=re.M)
		utils.getSetObjectState(container, state)
	else:
		pos = RPR_GetMediaItemInfo_Value( RPR_GetSelectedMediaItem(0, 0), "D_POSITION")

	# work out the old glue track from the glue_group id
	glue_track = utils.getTrackFromGlueGroup(glue_group)
	#delete the old glue track
	RPR_DeleteTrack(glue_track)
	
	#make sure source item is selected
	RPR_SetMediaItemSelected(source_item, True)
	# select whole group if its in one
	RPR_Main_OnCommand(40034, 0)

	# run doGlue, but this time with a glue_group and container
	glued_item = doGlue(source_track, source_item, glue_group, container)

	#store updated src
	new_src = utils.getItemWavSrc(glued_item)

	# move glued item to source track
	RPR_MoveMediaItemToTrack(glued_item, source_track)
	#setup item
	if original_state:
		utils.getSetObjectState(glued_item, original_state)
	elif pos:
		RPR_SetMediaItemInfo_Value(glued_item, "D_POSITION", pos)

	#update sources of all instances of this glue group
	updateSources(
		new_src,
		glue_group
	)

	return glued_item


# only called by the updateSources function when any glue groups that were just updated are nested in other glue groups/tracks
def doGlueTrackReGlue(glue_track):
	# get glue_group
	glue_group = utils.getGlueGroupFromTrack(glue_track)
	# deselect all
	utils.deselect()
	# select glue track
	RPR_SetOnlyTrackSelected(glue_track)

	# make glue track visible
	RPR_SetMediaTrackInfo_Value(glue_track, "B_SHOWINTCP", True)
	RPR_TrackList_AdjustWindows(True)

	#select all items in track
	num_items = RPR_CountTrackMediaItems(glue_track)
	for i in range(num_items):
		item = RPR_GetTrackMediaItem(glue_track, i)
		RPR_SetMediaItemSelected(item, True)

	# duplicate
	utils.duplicateItems()
	# glue duplicate
	RPR_Main_OnCommand(41588, 0)
	#select new glued item
	glued_item = RPR_GetSelectedMediaItem(0, 0);
	#get its source
	new_src = utils.getItemWavSrc(glued_item);

	# update the source files based on the newly created glued file
	updateSources(
		new_src,
		glue_group
	)

	#delete glued item from track 
	RPR_DeleteTrackMediaItem(glue_track, glued_item)

	# make glue track invisible
	RPR_SetMediaTrackInfo_Value(glue_track, "B_SHOWINTCP", False)



def updateSources(new_src, glue_group):
	# count all items
	num_items = RPR_CountMediaItems(0)

	glue_group_track_string = "glue_group_track:"
	glue_group_string = "glue_group:"+str(glue_group)+":"

	dirtiedTracks = {}
	# loop through and update wav srcs
	for i in range(num_items):

		# first catch your Media Item
		item = RPR_GetMediaItem(0, i)

		#get take name and see if it matches the currently updated glue group
		take_name = utils.getSetItemName(item)
		if not take_name: continue

		if(glue_group_string in take_name):
			
			current_src = utils.getItemWavSrc(item)

			if(current_src != new_src):
				# BR method
				# get the take
				take = RPR_GetActiveTake(item)
				# update the src
				BR_SetTakeSourceFromFile2(take, new_src, False, True)
				# peakRebuildNeeded = True
				
				#are we updating a src on another hidden glue track? if so store a reference to it in the dirtiedTracks dict
				track = RPR_GetMediaItem_Track(item)
				(track_name, track, flagsOut) = RPR_GetTrackState(track, 0)
				if glue_group_track_string in track_name:
					if track_name not in dirtiedTracks:
						dirtiedTracks[track_name] = track

	# now check dirtied glue tracks
	for i in dirtiedTracks:
		doGlueTrackReGlue(dirtiedTracks[i])






RPR_Undo_BeginBlock();

RPR_PreventUIRefresh(1)

# do the actual glue
glueGroup()

# clean up
RPR_UpdateTimeline()
RPR_UpdateArrange()
RPR_TrackList_AdjustWindows(True)
# zoom in then out
RPR_Main_OnCommand(1011, 0)
RPR_Main_OnCommand(1012, 0)

RPR_PreventUIRefresh(-1)


# utils.log("Done in:", time()-t)


RPR_Undo_EndBlock("Glue Group", -1)
