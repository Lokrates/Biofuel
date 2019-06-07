
-- Load support for intllib.
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--Biofuel:
----------


--Phial Fuel
minetest.register_craftitem("biofuel:phial_fuel", {
	description = S(" Phial Fuel "),
	inventory_image = "biofuel_phial_fuel.png"
})

minetest.register_craft({
	type = "fuel",
	recipe = "biofuel:phial_fuel",
	burntime = 10,
})


--Bottle Fuel

minetest.register_craftitem("biofuel:bottle_fuel", {
	description = S(" Bottle Fuel "),
	inventory_image = "biofuel_bottle_fuel.png",
	groups = {biofuel = 1}
})

minetest.register_craft({
    type = "shapeless",
    output = "biofuel:bottle_fuel",
    recipe = {"biofuel:phial_fuel", "biofuel:phial_fuel", "biofuel:phial_fuel", "biofuel:phial_fuel"}
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
			{"group:biofuel", "group:biofuel", "group:biofuel"},
			{"group:biofuel", "group:biofuel", "group:biofuel"},
			{"group:biofuel", "group:biofuel", "group:biofuel"}
		 }
})


--Mod compatibility:
--------------------

--Wine (TenPlus1)

if minetest.get_modpath("wine") then
	minetest.override_item("wine:bottle_rum", {
		groups = {biofuel = 1, dig_immediate = 3, attached_node = 1, vessel = 1},
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "wine:bottle_rum",
		burntime = 40,
	})


	minetest.override_item("wine:bottle_tequila", {
		groups = {biofuel = 1, dig_immediate = 3, attached_node = 1, vessel = 1},
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "wine:bottle_tequila",
		burntime = 40,
	})
end

--Basic Materials

if minetest.get_modpath("basic_materials") then
	minetest.override_item("basic_materials:oil_extract", {
		groups = {biofuel = 1},
	})
end

--Cucina_Vegana

if minetest.get_modpath("cucina_vegana") then
	minetest.override_item("cucina_vegana:sunflower_seeds_oil", {
		groups = {vessel = 1, dig_immediate = 3, attached_node = 1, food = 1, food_oil = 1, food_vegan = 1, eatable = 1, biofuel = 1},
	})

	minetest.override_item("cucina_vegana:flax_seed_oil", {
		groups = {vessel = 1, dig_immediate = 3, attached_node = 1, food = 1, food_oil = 1, food_vegan = 1, eatable = 1, biofuel = 1},
	})

	minetest.override_item("cucina_vegana:lettuce_oil", {
		groups = {dig_immediate = 3, attached_node = 1, food_oil = 1, food_vegan = 1, eatable = 1, biofuel = 1},
	})
end

--[[
--Farming_Redo

if minetest.get_modpath("farming") then
	minetest.override_item("farming:bottle_ethanol", {
		groups = {vessel = 1, dig_immediate = 3, attached_node = 1, biofuel = 1},
	})

	minetest.override_item("farming:hemp_oil", {
		groups = {food_oil = 1, vessel = 1, dig_immediate = 3, attached_node = 1, biofuel = 1},
	})
end
]]