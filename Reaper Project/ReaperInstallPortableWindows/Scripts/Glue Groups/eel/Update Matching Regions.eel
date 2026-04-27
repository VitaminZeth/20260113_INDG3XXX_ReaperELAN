import utils
from sws_python import * 


selectNextRegion = RPR_NamedCommandLookup('_SWS_SELNEXTREG')
selectPrevRegion = RPR_NamedCommandLookup('_SWS_SELPREVREG')
selectTracksWithSelectedItems = RPR_NamedCommandLookup('_SWS_SELTRKWITEM')

def updateRegions():

	utils.deselect()

	time = RPR_GetCursorPosition()

	(proj, time, markeridxOut, regionidxOut) = RPR_GetLastMarkerAndCurRegion(0, time, 0, 0)
	
	(ret, idx, isRgn, region_start_pos, rgnEndPos, rgnName, rgnIndex) = RPR_EnumProjectMarkers(
		regionidxOut, True, 0, 0, "", 0
	)

	if regionidxOut == -1: return

	# make sure edit cursor is in place
	RPR_MoveEditCursor(region_start_pos-RPR_GetCursorPosition(), 0)

	fast_Str = SNM_CreateFastString("")
	SNM_GetProjectMarkerName(0, rgnIndex, True, fast_Str)
	marker_name = SNM_GetFastString(fast_Str)
	SNM_DeleteFastString(fast_Str)

	RPR_GoToRegion(0, rgnIndex, False)

	# convert region into time selection
	RPR_Main_OnCommand(40635, 0)				# clear time selection first
	RPR_Main_OnCommand(selectNextRegion, 0)
	RPR_Main_OnCommand(selectPrevRegion, 0)

	# select items in time selction
	RPR_Main_OnCommand(40717, 0)
	if not RPR_CountSelectedMediaItems(0): return

	# select tracks then narrow down to first track
	RPR_Main_OnCommand(selectTracksWithSelectedItems, 0)
	num_tracks = RPR_CountSelectedTracks(0)
	if not num_tracks: return
	first_track = RPR_GetSelectedTrack(0,0)
	RPR_SetOnlyTrackSelected(first_track)
	# set first track as last touched
	RPR_Main_OnCommand(40914, 0)
	

	num_items = RPR_CountSelectedMediaItems(0)
	for i in range(num_items):
		item = RPR_GetSelectedMediaItem(0, i)
		pos = RPR_GetMediaItemInfo_Value(item, "D_POSITION")
		if pos < region_start_pos:
			RPR_SetMediaItemSelected(item, False)


	# copy items
	RPR_Main_OnCommand(40057, 0)

	# get num regions
	(retval, proj, num_markers, num_regions) = RPR_CountProjectMarkers(0, 0, 0)

	for i in range(num_regions):
		# dont touch the items in the region we started in
		if i == regionidxOut: continue

		(ret, idx, isRgn, rgnStartPos, rgnEndPos, rgnName, rgnIndex) = RPR_EnumProjectMarkers(
			i, True, 0, 0, "", 0
		)
		if not isRgn: continue

		fast_Str = SNM_CreateFastString("")
		SNM_GetProjectMarkerName(0, i+1, True, fast_Str)
		current_marker_name = SNM_GetFastString(fast_Str)
		SNM_DeleteFastString(fast_Str)

		if current_marker_name == marker_name:
			RPR_GoToRegion(0, i+1, False)

			# clear time selection first
			RPR_Main_OnCommand(40635, 0)	
			# time selcet region
			RPR_Main_OnCommand(selectNextRegion, 0)
			RPR_Main_OnCommand(selectPrevRegion, 0)

			# select items in time selction
			RPR_Main_OnCommand(40717, 0)
			#remove items
			RPR_Main_OnCommand(40006, 0)
			# paste updated items
			RPR_Main_OnCommand(40058, 0)


	
	# clear time selection
	RPR_Main_OnCommand(40635, 0)

	utils.deselect()

	# make sure edit cursor is back in its original place
	RPR_MoveEditCursor(time-RPR_GetCursorPosition(), 0)





RPR_Undo_BeginBlock();


RPR_PreventUIRefresh(1)

# do the update
updateRegions()


# clean up
RPR_UpdateTimeline()
RPR_UpdateArrange()
RPR_TrackList_AdjustWindows(True)
# zoom in then out
RPR_Main_OnCommand(1011, 0)
RPR_Main_OnCommand(1012, 0)


RPR_PreventUIRefresh(-1)


# utils.log("Done in:", time()-t)


RPR_Undo_EndBlock("Update Matching Regions", -1)