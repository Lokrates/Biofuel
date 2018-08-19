--File name: init.lua
--Project name: compost, a Mod for Minetest
--License: General Public License, version 3 or later
--Original Work Copyright (C) 2016 cd2 (cdqwertz) <cdqwertz@gmail.com>
--Modified Work Copyright (C) Vitalie Ciubotaru <vitalie at ciubotaru dot tk>
--Modified Work Copyright (C) 2018 Lokrates

-- Load support for intllib.
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

-- pipeworks compat
local has_pipeworks = minetest.get_modpath("pipeworks")
local tube_entry = ""

if has_pipeworks then
	tube_entry = "^pipeworks_tube_connection_wooden.png"
end


minetest.log('action', 'MOD: Biofuel ' .. S("loading..."))
biofuel_version = '0.1'

biomass = {}
biomass.convertible_groups = {'flora', 'leaves', 'flower', 'sapling', 'tree', 'wood', 'stick', 'plant', }
biomass.convertible_nodes = {
	'default:cactus',
	'default:papyrus',
	'default:dry_shrub',
	'farming:wheat',
	'farming:seed_wheat',
	'farming:straw',
	'farming:cotton',
	'farming:seed_cotton',
	'default:marram_grass_1',
	'default:bush_stem',
	'default:acacia_bush_stem',
	'flowers:mushroom_red',
	'flowers:mushroom_brown',
	'default:apple',
	'default:sand_with_kelp',
	'farming:flour',
	'farming:bread',
	'farming:string',
	'pooper:poop_turd',
	'pooper:poop_pile',
}
biomass.convertible_items = {}
for _, v in pairs(biomass.convertible_nodes) do
	biomass.convertible_items[v] = true
end

local function formspec(pos)
	local spos = pos.x..','..pos.y..','..pos.z
	local formspec =
		'size[8,8.5]'..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		'list[nodemeta:'..spos..';src;0.5,0.5;3,3;]'..
		'list[nodemeta:'..spos..';dst;5,1;2,2;]'..
		'list[current_player;main;0,4.25;8,1;]'..
		'list[current_player;main;0,5.5;8,3;8]'..
		'listring[nodemeta:'..spos ..';dst]'..
		'listring[current_player;main]'..	
		'listring[nodemeta:'..spos ..';src]'..
		'listring[current_player;main]'..
		default.get_hotbar_bg(0, 4.25)
	return formspec
end

local function is_convertible(input)
	if biomass.convertible_items[input] then
		return true
	end
	for _, v in pairs(biomass.convertible_groups) do
		if minetest.get_item_group(input, v) > 0 then
			return true
		end
	end
	return false
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function count_input(pos)
	local q = 0
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stacks = inv:get_list('src')
	for k in pairs(stacks) do
		q = q + inv:get_stack('src', k):get_count()
	end
	return q
end

local function is_empty(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stacks = inv:get_list('src')
	for k in pairs(stacks) do
		if not inv:get_stack('src', k):is_empty() then
			return false
		end
	end
	if not inv:get_stack('dst', 1):is_empty() then
		return false
	end
	return true
end

local function update_nodebox(pos)
	if is_empty(pos) then
		swap_node(pos, "biofuel:refinery")
	else
		swap_node(pos, "biofuel:refinery_active")
	end
end


local function update_timer(pos)
	local timer = minetest.get_node_timer(pos)
	local meta = minetest.get_meta(pos)
	local count = count_input(pos)
	if not timer:is_started() and count >= 4 then        	  --Input
		timer:start(2)										  --Timebase
		meta:set_int('progress', 0)
		meta:set_string('infotext', S("progress: @1%", "0"))
		return
	end
	if timer:is_started() and count < 4 then     		      --Input
		timer:stop()
		meta:set_string('infotext', S("To start fuel production add biomass "))
		meta:set_int('progress', 0)
	end
end

local function create_biofuel(pos)
	local q = 4												  -- Input
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stacks = inv:get_list('src')
	for k in pairs(stacks) do
		local stack = inv:get_stack('src', k)
		if not stack:is_empty() then
			local count = stack:get_count()
			if count <= q then
				inv:set_stack('src', k, '')
				q = q - count
			else
				inv:set_stack('src', k, stack:get_name() .. ' ' .. (count - q))
				q = 0
				break
			end
		end
	end
	local dirt_count = inv:get_stack('dst', 1):get_count()
	inv:set_stack('dst', 1, 'biofuel:bottle_fuel ' .. (dirt_count + 1))
end

local function on_timer(pos)
	local timer = minetest.get_node_timer(pos)
	local meta = minetest.get_meta(pos)
	local progress = meta:get_int('progress') + 25  			--Progresss in %
	if progress >= 100 then
		create_biofuel(pos)
		meta:set_int('progress', 0)
	else
		meta:set_int('progress', progress)
	end
	if count_input(pos) >= 4 then								--Input
		meta:set_string('infotext', S("progress: @1%", progress))
		return true
	else
		timer:stop()
		meta:set_string('infotext', S("To start fuel production add biomass "))
		meta:set_int('progress', 0)
		return false
	end
end

local function on_construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size('src', 9)                                     -- Input Fields
	inv:set_size('dst', 4)                                     -- Output Fields
	meta:set_string('infotext', S("To start fuel production add biomass "))
	meta:set_int('progress', 0)
end

local function on_rightclick(pos, node, clicker, itemstack)
	minetest.show_formspec(
		clicker:get_player_name(),
		'biofuel:refinery',
		formspec(pos)
	)
end

local function can_dig(pos,player)

	if player and player:is_player() and minetest.is_protected(pos, player:get_player_name()) then
		-- protected
		return false
	end

	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()
	if inv:is_empty('src') and inv:is_empty('dst') then
		return true
	else
		return false
	end
end

local tube = {
	insert_object = function(pos, node, stack, direction)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local result = inv:add_item("src", stack)
		update_timer(pos)
		update_nodebox(pos)
		return result
	end,
	can_insert = function(pos, node, stack, direction)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		stack = stack:peek_item(1)

		return is_convertible(stack:get_name()) and inv:room_for_item("src", stack)
	end,
	input_inventory = "dst",
	connect_sides = {bottom = 1}
}


local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if player and player:is_player() and minetest.is_protected(pos, player:get_player_name()) then
		-- protected
		return 0
	end

	return stack:get_count()
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)

	if player and player:is_player() and minetest.is_protected(pos, player:get_player_name()) then
		-- protected
		return 0
	end

	if listname == 'src' and is_convertible(stack:get_name()) then
		return stack:get_count()
	else
		return 0
	end
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	update_timer(pos)
	update_nodebox(pos)
	minetest.log('action', player:get_player_name() .. S(" moves stuff to refinery at ") .. minetest.pos_to_string(pos))
	return
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
	update_timer(pos)
	update_nodebox(pos)
	minetest.log('action', player:get_player_name() .. S(" takes stuff from refinery at ") .. minetest.pos_to_string(pos))
	return
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)

	if player and player:is_player() and minetest.is_protected(pos, player:get_player_name()) then
		-- protected
		return 0
	end

	local inv = minetest.get_meta(pos):get_inventory()
	if from_list == to_list then
		return inv:get_stack(from_list, from_index):get_count()
	else
		return 0
	end
end

minetest.register_node("biofuel:refinery", {
	description = S("Biofuel Refinery"),
	drawtype = "nodebox",
		tiles = {
			"biofuel_tb.png",       -- top
			"biofuel_tb.png" .. tube_entry,       -- bottom
			"biofuel_fr.png",       -- right
			"biofuel_bl.png",       -- left
			"biofuel_bl.png",       -- back
			"biofuel_fr.png"        -- front
		},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, 0.4375, 0.4375, 0.4375, 0.5, 0.5}, -- NodeBox1
			{0.4375, 0.4375, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox2
			{-0.4375, 0.4375, -0.5, 0.4375, 0.5, -0.4375}, -- NodeBox3
			{-0.5, 0.4375, -0.4375, -0.4375, 0.5, 0.4375}, -- NodeBox4
			{0.4375, -0.375, 0.4375, 0.5, 0.5, 0.5}, -- NodeBox5
			{0.4375, -0.375, -0.5, 0.5, 0.5, -0.4375}, -- NodeBox6
			{-0.5, -0.375, -0.5, -0.4375, 0.5, -0.4375}, -- NodeBox7
			{-0.5, -0.375, 0.4375, -0.4375, 0.5, 0.5}, -- NodeBox8
			{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}, -- NodeBox9
			{-0.4375, -0.375, -0.4375, 0, 0.3125, 0}, -- NodeBox10
			{0, -0.375, 0.1875, 0.375, 0.3125, 0.1875}, -- NodeBox11
			{0.1875, -0.375, 0, 0.1875, 0.3125, 0.375}, -- NodeBox12
			{-0.25, 0.3125, -0.25, 0.25, 0.4375, 0.25}, -- NodeBox13
		}
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand=1, tubedevice=1, tubedevice_receiver=1},
	sounds = default.node_sound_metal_defaults(),
	on_timer = on_timer,
	on_construct = on_construct,
	on_rightclick = on_rightclick,
	can_dig = can_dig,
	tube = tube,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_take = on_metadata_inventory_take,
})

minetest.register_node("biofuel:refinery_active", {
	description = S("Biofuel Refinery Active"),
	drawtype = "nodebox",
		tiles = {
			"biofuel_tb.png",    		   -- top
			"biofuel_tb.png" .. tube_entry,      		   -- bottom
			"biofuel_fr_active.png",       -- right
			"biofuel_bl_active.png",       -- left
			"biofuel_bl_active.png",       -- back
			"biofuel_fr_active.png"        -- front
		},
	node_box = {
		type = "fixed",
		fixed = {
		{-0.4375, 0.4375, 0.4375, 0.4375, 0.5, 0.5}, -- NodeBox1
			{0.4375, 0.4375, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox2
			{-0.4375, 0.4375, -0.5, 0.4375, 0.5, -0.4375}, -- NodeBox3
			{-0.5, 0.4375, -0.4375, -0.4375, 0.5, 0.4375}, -- NodeBox4
			{0.4375, -0.375, 0.4375, 0.5, 0.5, 0.5}, -- NodeBox5
			{0.4375, -0.375, -0.5, 0.5, 0.5, -0.4375}, -- NodeBox6
			{-0.5, -0.375, -0.5, -0.4375, 0.5, -0.4375}, -- NodeBox7
			{-0.5, -0.375, 0.4375, -0.4375, 0.5, 0.5}, -- NodeBox8
			{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}, -- NodeBox9
			{-0.4375, -0.375, -0.4375, 0, 0.3125, 0}, -- NodeBox10
			{0, -0.375, 0.1875, 0.375, 0.3125, 0.1875}, -- NodeBox11
			{0.1875, -0.375, 0, 0.1875, 0.3125, 0.375}, -- NodeBox12
			{-0.25, 0.3125, -0.25, 0.25, 0.4375, 0.25}, -- NodeBox13
		}
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand=1, not_in_creative_inventory = 1, tubedevice=1, tubedevice_receiver=1},
	sounds = default.node_sound_metal_defaults(),
	on_timer = on_timer,
	on_construct = on_construct,
	on_rightclick = on_rightclick,
	can_dig = can_dig,
	tube = tube,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_take = on_metadata_inventory_take,
})

minetest.register_craft({
	output = "biofuel:refinery",
	recipe = {
		{"default:tin_ingot", "default:tin_ingot", "default:tin_ingot"},
		{"default:glass", "default:glass", "default:glass"},
		{"default:tin_ingot", "default:tin_ingot", "default:tin_ingot"}
	}
})

minetest.register_craftitem("biofuel:bottle_fuel", {
	description = S(" Bottle Fuel "),
	inventory_image = "biofuel_bottle_fuel.png"
})

minetest.register_craft({
	type = "fuel",
	recipe = "biofuel:bottle_fuel",
	burntime = 40,
})


--Can Fuel

minetest.register_craftitem("biofuel:fuel_can", {
	description = S(" Fuel Canister "),
	inventory_image = "biofuel_fuel_can.png"
})

minetest.register_craft({
	type = "fuel",
	recipe = "biofuel:fuel_can",
	burntime = 370,
})

minetest.register_craft({
	output = "biofuel:fuel_can",
	recipe = {
			{"biofuel:bottle_fuel", "biofuel:bottle_fuel", "biofuel:bottle_fuel"},
			{"biofuel:bottle_fuel", "biofuel:bottle_fuel", "biofuel:bottle_fuel"},
			{"biofuel:bottle_fuel", "biofuel:bottle_fuel", "biofuel:bottle_fuel"}
		 }
})



minetest.log('action', "MOD: Biofuel version " .. biofuel_version .. (" loaded."))
