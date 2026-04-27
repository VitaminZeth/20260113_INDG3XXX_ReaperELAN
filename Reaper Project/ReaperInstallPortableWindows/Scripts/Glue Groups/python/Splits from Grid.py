def do():

	# select all items in group
	RPR_Main_OnCommand(40034, 0)

	cursorInit = RPR_GetCursorPosition()

	# move cursor to end of items
	RPR_Main_OnCommand(41174, 0)
	end = RPR_GetCursorPosition()


	# move to the start of item
	RPR_Main_OnCommand(41173, 0)
	cursor = RPR_GetCursorPosition()


	while(cursor < end):
		# move cursor right 1 grid unit
		RPR_Main_OnCommand(40647, 0)
		# slice
		RPR_Main_OnCommand(40012, 0)
		# update cursor pos
		cursor = RPR_GetCursorPosition()

	# stop
	RPR_Main_OnCommand(1016, 0)
	RPR_MoveEditCursor(cursorInit-cursor, 0)



RPR_Undo_BeginBlock();
RPR_PreventUIRefresh(1)



do()



RPR_UpdateTimeline()
RPR_PreventUIRefresh(-1)
RPR_Undo_EndBlock("Slices from Grid", -1)