dofile(minetest.get_modpath('biofuel')..'/biofuel.lua')
dofile(minetest.get_modpath('biofuel')..'/refinery.lua')

-- THIS CODE CAN BE REMOVED WHEN ISSUES https://gitlab.com/VanessaE/pipeworks/-/merge_requests/47 AND https://github.com/minetest/minetest_game/pull/2895 WILL BE MERGED.
if minetest.settings:get_bool("biofuel_fix_furnace",true) then
	dofile(minetest.get_modpath('biofuel')..'/fix_furnace.lua')
end

