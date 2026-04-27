Glue/Unglue Groups
------------------
(LUA only, Python is old version, EEL I cant make work)

* Glues selected items, but stores the original items in the project file
* Can unglue any instance, edit it, and run Glue again and all instances will be updated. (you may need to zoom in/out to refresh)
* When unglueing, a new empty item is inserted under the original items. This item has the data to recall which group these items came from, dont delete it unless you want to glue the items and make a new group that doesnt update other instances
* If you add new items to the glue group, select them AND at least one of the original items to make sure they get added to the existing glue group. If you just tweak the existing items you can select any one and reglue and it will remember which group it belongs to
* You can use the empty container to create silence at the start and end of the glued wav
* Uses item notes/names to keep track of which glue group items belong in. If you see "glue_group:1:" or "glue_group_container:1:" dont delete it from the items name. You can add text to notes/names AFTER ":1:" eg "glue_group:1: My extra text"
* Even glues MIDI items. Uses "Apply track FX as new take" on each item to get the wav. When you unglue, the wav take is removed and just the original MIDI take is restore to active
* Glue groups can be nested inside other glue groups. When you update the nested group, the script checks the parent item too, and updates that. Tested with 20 levels of nesting.
* Requires SWS

Update Matching Regions
-----------------------
* If you have a bunch of regions with the same name, and you edit whats in one of them, run this while your cursor is inside the region to make all other regions with the same name match the edited one.
* Only selects items that start on or after the region
