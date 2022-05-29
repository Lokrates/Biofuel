
-- THIS CODE CAN BE REMOVED WHEN ISSUES https://gitlab.com/VanessaE/pipeworks/-/merge_requests/47 AND https://github.com/minetest/minetest_game/pull/2895 WILL BE MERGED.

local function biofuel_fix_furance(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local item = inv:get_stack("fuel", 1)
	local is_fuel = minetest.get_craft_result({method = "fuel", width = 1, items = {item:to_string()}})
	if is_fuel.time == 0 then
		inv:set_stack("fuel", 1, "")
		local leftover = inv:add_item("dst", item)
		 	if not leftover:is_empty() then
				local above = vector.new(pos.x, pos.y + 1, pos.z)
				local drop_pos = minetest.find_node_near(above, 1, {"air"}) or above
				minetest.item_drop(replacements[1], nil, drop_pos)
			end
	end
end

local furnace_def = minetest.registered_nodes["default:furnace"]
local old_on_timer = furnace_def.on_timer;
minetest.override_item("default:furnace", {
  on_timer = function(pos, elapsed)
    local ret = old_on_timer(pos, elapsed)
		biofuel_fix_furance(pos)
    return ret
  end
})

local furnace_active_def = minetest.registered_nodes["default:furnace_active"]
local old_on_timer_active = furnace_active_def.on_timer;
minetest.override_item("default:furnace_active", {
  on_timer = function(pos, elapsed)
    local ret = old_on_timer(pos, elapsed)
		biofuel_fix_furance(pos)
    return ret
  end
})

