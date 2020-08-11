-- Load support for MT game translation.
local S = minetest.get_translator("biofuel")


--Biofuel:
----------


--Vial of Biofuel
minetest.register_craftitem("biofuel:phial_fuel", {
	description = S("Vial of Biofuel"),
	inventory_image = "biofuel_phial_fuel.png"
})

minetest.register_craft({
	type = "fuel",
	recipe = "biofuel:phial_fuel",
	burntime = 10,
})


--Bottle of Biofuel

minetest.register_craftitem("biofuel:bottle_fuel", {
	description = S("Bottle of Biofuel"),
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


--Canister of Biofuel

minetest.register_craftitem("biofuel:fuel_can", {
	description = S("Canister of Biofuel"),
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

--Wine 

if minetest.registered_nodes ["wine:bottle_rum"] then
	minetest.override_item("wine:bottle_rum", {
		groups = {biofuel = 1, dig_immediate = 3, attached_node = 1, vessel = 1},
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "wine:bottle_rum",
		burntime = 40,
	})
end

if minetest.registered_nodes ["wine:bottle_tequila"] then
	minetest.override_item("wine:bottle_tequila", {
		groups = {biofuel = 1, dig_immediate = 3, attached_node = 1, vessel = 1},
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "wine:bottle_tequila",
		burntime = 40,
	})
end

if minetest.registered_nodes ["wine:bottle_bourbon"] then
	minetest.override_item("wine:bottle_bourbon", {
		groups = {biofuel = 1, dig_immediate = 3, attached_node = 1, vessel = 1},
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "wine:bottle_burbon",
		burntime = 40,
	})
end

if minetest.registered_nodes ["wine:bottle_sake"] then
	minetest.override_item("wine:bottle_sake", {
		groups = {biofuel = 1, dig_immediate = 3, attached_node = 1, vessel = 1},
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "wine:bottle_sake",
		burntime = 40,
	})
end

if minetest.registered_nodes ["wine:bottle_vodka"] then
	minetest.override_item("wine:bottle_vodka", {
		groups = {biofuel = 1, dig_immediate = 3, attached_node = 1, vessel = 1},
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "wine:bottle_vodka",
		burntime = 40,
	})
end


--Basic Materials

if minetest.registered_items ["basic_materials:oil_extract"] then
	minetest.override_item("basic_materials:oil_extract", {
		groups = {biofuel = 1},
	})
end


--Cucina_Vegana

if minetest.registered_items ["cucina_vegana:sunflower_seeds_oil"] then
	minetest.override_item("cucina_vegana:sunflower_seeds_oil", {
		groups = {biofuel = 1, vessel = 1, dig_immediate = 3, attached_node = 1, food = 1, food_oil = 1, food_vegan = 1, eatable = 1},
	})
end

if minetest.registered_items ["cucina_vegana:flax_seed_oil"] then
	minetest.override_item("cucina_vegana:flax_seed_oil", {
		groups = {biofuel = 1, vessel = 1, dig_immediate = 3, attached_node = 1, food = 1, food_oil = 1, food_vegan = 1, eatable = 1},
	})
end

if minetest.registered_items ["cucina_vegana:lettuce_oil"] then
	minetest.override_item("cucina_vegana:lettuce_oil", {
		groups = {biofuel = 1, vessel = 1, dig_immediate = 3, attached_node = 1, food = 1, food_oil = 1, food_vegan = 1, eatable = 1},
	})
end

if minetest.registered_items ["cucina_vegana:peanut_oil"] then
	minetest.override_item("cucina_vegana:peanut_oil", {
		groups = {biofuel = 1, vessel = 1, dig_immediate = 3, attached_node = 1, food = 1, food_oil = 1, food_vegan = 1, eatable = 1},
	})
end


--Farming_Redo

if minetest.registered_items ["farming:bottle_ethanol"] then
	minetest.override_item("farming:bottle_ethanol", {
		groups = {biofuel = 1, dig_immediate = 3, attached_node = 1, vessel = 1},
	})
end

if minetest.registered_items ["farming:hemp_oil"] then
	minetest.override_item("farming:hemp_oil", {
		groups = {biofuel = 1, dig_immediate = 3, attached_node = 1, vessel = 1},
	})
end