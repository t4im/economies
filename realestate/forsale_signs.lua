-- uses some code, especially the nodeboxmodels and sign type determination, of
-- the rewritten sign_lib by Vanessa Ezekowitz and Diego Martinez under lgpl

-- call the functions that make the landselling happen
-- not mixing these with the forsale signs allows us to
-- add other nodes, for example aliased ones from protectionmods
local forsale_receive_fields = economy.realestate.landsale.receive_fields
local forsale_punch = economy.realestate.landsale.punch
local forsale_construct = economy.realestate.landsale.construct

local determine_sign_type = function(itemstack, placer, pointed_thing)
	local name = minetest.get_node(pointed_thing.above).name

	if not economy.buildableTo(pointed_thing.above, placer, reportViolation) then
		return itemstack
	end

	local node = minetest.get_node(pointed_thing.under)

	if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
		return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack)
	else
		local above = pointed_thing.above
		local under = pointed_thing.under
		local dir = {x = under.x - above.x,
			y = under.y - above.y,
			z = under.z - above.z}

		local walldir = minetest.dir_to_wallmounted(dir)

		local placer_pos = placer:getpos()
		if placer_pos then
			dir = {	x = above.x - placer_pos.x,
				y = above.y - placer_pos.y,
				z = above.z - placer_pos.z }
		end

		local facedir = minetest.dir_to_facedir(dir)

		if walldir == 0 then
			minetest.add_node(above, {name = "realestate:forsale_sign_hanging", param2 = facedir})
		elseif walldir == 1 then
			minetest.add_node(above, {name = "realestate:forsale_sign_yard", param2 = facedir})
		else -- it must be a wall mounted sign.
			minetest.add_node(above, {name = itemstack:get_name(), param2 = facedir})
		end

		itemstack:take_item()
		return itemstack
	end
end

minetest.register_node("realestate:forsale_sign", {
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
	on_place = determine_sign_type,
	on_construct = forsale_construct,
	on_receive_fields = forsale_receive_fields,
	on_punch = forsale_punch
})

minetest.register_node("realestate:forsale_sign_yard", {
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

minetest.register_node("realestate:forsale_sign_hanging", {
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
