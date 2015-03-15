-- call the functions that make the landselling happen
-- not mixing these with the forsale signs allows us to
-- add other nodes, for example aliased ones from protectionmods
local forsale_receive_fields = realestate.landsale.receive_fields
local forsale_punch = realestate.landsale.punch
local forsale_construct = realestate.landsale.construct

core.register_node("realestate:forsale_sign", {
	description = "For Sale sign",
	inventory_image = "forsale_sign_inventory.png",
	wield_image = "forsale_sign_inventory.png",
	node_placement_prediction = "",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.4375, -0.25, 0.4375, 0.4375, 0.375, 0.5}
	},
	tiles = {"forsale_sign_borders.png", "forsale_sign_borders.png",
		"forsale_sign_borders.png", "forsale_sign_borders.png",
		"forsale_sign.png", "forsale_sign.png"},
	groups = {choppy=2, dig_immediate=2},
	on_place = economies.switch_on_place {
		on_ceiling="realestate:forsale_sign_hanging",
		on_ground="realestate:forsale_sign_yard",
	},
	on_construct = forsale_construct,
	on_receive_fields = forsale_receive_fields,
	on_punch = forsale_punch
})

core.register_node("realestate:forsale_sign_yard", {
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.25, -0.0625, 0.4375, 0.375, 0},
			{-0.0625, -0.5, -0.0625, 0.0625, -0.1875, 0}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.4375, -0.5, -0.0625, 0.4375, 0.375, 0}
	},
	tiles = {"forsale_sign_borders.png", "forsale_sign_borders.png",
		"forsale_sign_borders.png", "forsale_sign_borders.png",
		"forsale_sign.png", "forsale_sign.png"},
	groups = {choppy=2, dig_immediate=2},
	drop = "realestate:forsale_sign",
	on_receive_fields = forsale_receive_fields,
	on_construct = forsale_construct,
	on_punch = forsale_punch
})

core.register_node("realestate:forsale_sign_hanging", {
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.3125, -0.0625, 0.4375, 0.3125, 0},
			{-0.4375, 0.25, -0.03125, 0.4375, 0.5, -0.03125},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.45, -0.275, -0.049, 0.45, 0.5, 0.049}
	},
	tiles = {"forsale_sign_borders.png", "forsale_sign_borders.png",
		"forsale_sign_borders.png", "forsale_sign_borders.png",
		"forsale_sign_hanging.png", "forsale_sign_hanging.png"
	},
	groups = {choppy=2, dig_immediate=2},
	drop = "realestate:forsale_sign",
	on_receive_fields = forsale_receive_fields,
	on_construct = forsale_construct,
	on_punch = forsale_punch
})

core.register_craft({
	output = 'realestate:forsale_sign',
	recipe = {
		{'dye:red', 'dye:white', 'dye:red'},
		{'dye:white', 'default:sign_wall', 'dye:white'},
		{'dye:red', 'dye:white', 'dye:red'},
	}
})
