import re
from reaper_python import *
from sws_python import * 


def duplicateItems(items_array = False, offset = -1, select=True):
	if items_array:
		num_items = len(items_array)
	else:
		items_array = []
		num_items = RPR_CountSelectedMediaItems(0)
		for i in range(num_items):
			items_array.append(RPR_GetSelectedMediaItem(0, i))

	if offset > -2:
		first_pos = RPR_GetMediaItemInfo_Value(items_array[0], "D_POSITION")
		if offset == -1:
			last_length = RPR_GetMediaItemInfo_Value(items_array[num_items-1], "D_LENGTH")
			last_pos = RPR_GetMediaItemInfo_Value(items_array[num_items-1], "D_POSITION")
			offset = last_pos+last_length

	track = RPR_GetMediaItemTrack(items_array[0])
	duplicates = []

	for i in range(num_items):
		original = items_array[i]
		RPR_SetMediaItemSelected(original, False)
		state = getSetObjectState(original)
		duplicate = RPR_AddMediaItemToTrack(track)
		getSetObjectState(duplicate, state)
		duplicates.append(duplicate)

		if select:
			RPR_SetMediaItemSelected(duplicate, True)

		if offset > -2:
			duplicate_pos = RPR_GetMediaItemInfo_Value(duplicate, "D_POSITION")
			RPR_SetMediaItemInfo_Value(duplicate, "D_POSITION", offset + (duplicate_pos-first_pos))

	return duplicates


def getTrackFromGlueGroup(glue_group):
	num_tracks = RPR_GetNumTracks()
	glue_group = "glue_group_track:"+str(glue_group)+":";
	for i in range(num_tracks):
		track = RPR_GetTrack(0, i)
		(bool, track, parmname, track_name, setnewvalue)  = RPR_GetSetMediaTrackInfo_String(track, "P_NAME", '', False)
		if glue_group == track_name:
			break

	return track

def getGlueGroupFromTrack(track):
	(bool, track, parmname, track_name, setnewvalue) = RPR_GetSetMediaTrackInfo_String(track, "P_NAME", '', False)
	regexp = r"glue_group_track:(\d*):"
	ex = re.compile(regexp)
	match = ex.search(track_name)
	if match:
		glue_group = int(match.group(1))
		return glue_group

def checkForGlueGroup(container = True):
	num_items = RPR_CountSelectedMediaItems(0)
	for i in range(num_items):
		item = RPR_GetSelectedMediaItem(0, i);
		glue_group = getGlueGroupFromItem(item, container)
		if glue_group:
			return {"glue_group":glue_group, "item":item}

	return False


def setItemGlueGroup(item, glue_group, container = True):
	state = getSetObjectState(item)
	if not state: return

	string = "glue_group:"
	if container : string = "glue_group_container:"
	string += str(glue_group)+":"

	if string in state: return

	state = state.replace("POSITION", "<NOTES\n|" + string + "\n>\nPOSITION")
	getSetObjectState(item, state)
	getSetItemName(item, string)


def getGlueGroupFromState(state, container = True):
	regexp = r"\n\|glue_group:(\d*):"
	if container: regexp = r"\n\|glue_group_container:(\d*):"
	ex = re.compile(regexp)
	match = ex.search(state)
	if match:
		glue_group = int(match.group(1))
		return glue_group


def getGlueGroupFromItem(item, container = True):
	state = getSetObjectState(item, '', True)
	return getGlueGroupFromState(state, container)


def removeGlueGroupFromItem(item, glue_group, container = True):
	state = getSetObjectState(item)
	string = "|glue_group:"
	if container: string = "|glue_group_container:"
	state = state.replace(string, "")
	getSetObjectState(item, state)




def getItemWavSrc(item):
	take = RPR_GetActiveTake(item)
	source = RPR_GetMediaItemTake_Source(take)
	sourceArray = RPR_GetMediaSourceFileName(source, "", 1024);
	if sourceArray:
		return sourceArray[1]

def getSetObjectState(obj, state = "", minimal = False):

	fastStr = SNM_CreateFastString(state)
	setNew = False
	if state: setNew = True
	
	SNM_GetSetObjectState(obj, fastStr, setNew, minimal)

	state = SNM_GetFastString(fastStr)
	SNM_DeleteFastString(fastStr)
	return state


def getSetItemName(item, name = ''):
	if not RPR_GetMediaItemNumTakes(item): return
	take = RPR_GetActiveTake(item)
	if take and take is not None:
		if name:
			RPR_GetSetMediaItemTakeInfo_String(take, "P_NAME", name, True)
		else:
			return RPR_GetTakeName(take)


def setToAudioTake(item):
	#make sure everything is deselected
	deselect()
	
	num_takes =  RPR_GetMediaItemNumTakes(item)
	if not num_takes: return
	active_take = RPR_GetActiveTake(item)
	if not active_take or active_take is None: return

	take_source = RPR_GetMediaItemTake_Source(active_take)
	(take_source, take_type, size) = RPR_GetMediaSourceType(take_source, '', 32)
	if "MIDI" not in take_type: return

	# store ref to the original active take for unglueing
	active_take_number = int(RPR_GetMediaItemTakeInfo_Value(active_take, "IP_TAKENUMBER"))
	# convert the active MIDI item to an audio take
	RPR_SetMediaItemSelected(item, True)
	RPR_Main_OnCommand(40209, 0)

	RPR_SetActiveTake(RPR_GetTake(item, num_takes))
	getSetItemName(item, "glue_group_render:"+str(active_take_number)+":")
	RPR_SetMediaItemSelected(item, False)

	cleanNullTakes(item)


def restoreOriginalTake(item):
	#make sure everything is deselected
	deselect()

	num_takes =  RPR_GetMediaItemNumTakes(item)
	if not num_takes: return
	active_take = RPR_GetActiveTake(item)
	if not active_take or active_take is None: return

	take_name = RPR_GetTakeName(active_take)
	if "glue_group_render:" in take_name:
		# delete this take
		RPR_SetMediaItemSelected(item, True)
		RPR_Main_OnCommand(40129, 0)
		#reselect original active take
		take_number = take_name.split(":")[1]
		if take_number:
			take_number = int(take_number)
			original_take = RPR_GetTake(item, take_number)		
			RPR_SetActiveTake(original_take)

		RPR_SetMediaItemSelected(item, False)

		cleanNullTakes(item)


def cleanNullTakes(item, state = False, force = False):
	if not state: state = getSetObjectState(item)

	if "TAKE NULL" in state or force:
		state = state.replace("TAKE NULL", "")
		getSetObjectState(item, state)


def updateSource(item, old_src, new_src):
	fastStr = SNM_CreateFastString("")
	SNM_GetSetSourceState(item, -1, fastStr, False)
	source = SNM_GetFastString(fastStr)
	source = source.replace(str(old_src), str(new_src))
	SNM_DeleteFastString(fastStr)
	fastStr = SNM_CreateFastString(source)
	SNM_GetSetSourceState(item, -1, fastStr, True)
	SNM_DeleteFastString(fastStr)

def findReplaceItemData(item, find, replace, checkStateFirst = False):
	state = getSetObjectState(item)
	if checkStateFirst:
		if checkStateFirst not in state:
			return False

	newState = state.replace(str(find), str(replace))
	getSetObjectState(item, newState)
	if newState == state: return False
	return True



def deselect():
	num = RPR_CountSelectedMediaItems(0)
	if not num: return
	
	for i in range(num):
		RPR_SetMediaItemSelected( RPR_GetSelectedMediaItem(0, 0), False)



def logState(item):
	state = getSetObjectState(item)
	RPR_ShowConsoleMsg(state)

def log(*args):
	if args is not None:
		msg = ""
		for a in args:
			msg += str(a)+" "
		RPR_ShowConsoleMsg(msg+"\n")

def logK(**args):
	if args is not None:
		for key, value in args.iteritems():
			RPR_ShowConsoleMsg(str(key)+":"+str(value)+"\n")