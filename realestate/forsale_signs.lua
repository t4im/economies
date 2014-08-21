-- uses some code, especially the nodeboxmodels and sign type determination, of
-- the rewritten sign_lib by Vanessa Ezekowitz and Diego Martinez under lgpl

local forsale_receive_fields = function(pos, formname, fields, sender)
end

local forsale_punch = function(pos, node, puncher)
end

local determine_sign_type = function(itemstack, placer, pointed_thing)
	local name = minetest.get_node(pointed_thing.above).name
	local def = minetest.registered_nodes[name]
	if not def.buildable_to then
		return itemstack
	end
	if minetest.is_protected(pointed_thing.above, placer:get_player_name()) then
		minetest.record_protection_violation(pointed_thing.above,
			placer:get_player_name())
		return itemstack
	end

	local node=minetest.get_node(pointed_thing.under)

	if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
		return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack)
	else
		local above = pointed_thing.above
		local under = pointed_thing.under
		local dir = {x = under.x - above.x,
			y = under.y - above.y,
			z = under.z - above.z}

		local wdir = minetest.dir_to_wallmounted(dir)

		local placer_pos = placer:getpos()
		if placer_pos then
			dir = {
				x = above.x - placer_pos.x,
				y = above.y - placer_pos.y,
				z = above.z - placer_pos.z
			}
		end

		local fdir = minetest.dir_to_facedir(dir)

		local sign_info
		local pt_name = minetest.get_node(under).name
		print(dump(pt_name))
		local signname = itemstack:get_name()

		if wdir == 0 then
			minetest.add_node(above, {name = "realestate:forsale_sign_hanging", param2 = fdir})
		elseif wdir == 1 then
			minetest.add_node(above, {name = "realestate:forsale_sign_yard", param2 = fdir})
		else -- it must be a wooden or metal wall sign.
			minetest.add_node(above, {name = signname, param2 = fdir})
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
	groups = sign_groups,
	on_place = determine_sign_type,
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
	on_punch = forsale_punch
})
