local economies, core = economies, core

local atm_model_bottom = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.3125, 0.5, 0.5, 0.5}, -- base
		{-0.5, 0.375, -0.4375, 0.5, 0.5, -0.3125}, -- front
	}
}

local atm_model_top = {
	type = "fixed",
	fixed = {
		{-0.375, 0.3125, -0.1875, 4/16, 0.5, 0}, -- ceiling
		{-0.5, -0.5, -0.25, -0.375, 0.5, 0.5}, -- leftwall
		{4/16, -0.5, -0.25, 0.5, 0.5, 0.5}, -- rightwall
		{-0.375, -0.5, 0, 4/16, 0.5, 0.5}, -- base
	}
}

core.register_node("bank:atm_bottom", {
	tiles = {
		"bank_atm_entry.png",
		"bank_atm_texture.png",
		"bank_atm_texture.png",
		"bank_atm_texture.png",
		"bank_atm_texture.png",
		"bank_atm_texture.png",
		},
	inventory_image = "bank_atm_inventory.png",
	description = "ATM",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=3},
	node_box = atm_model_bottom,
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 }
	},
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		meta:set_string("infotext", "ATM")
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		bank.openWireFormspec(clicker)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local pos, def = economies.get_base_node(pointed_thing)
		if not def then return end
		if def.on_rightclick then
			return def.on_rightclick(pos, core.get_node(pos), placer, itemstack, pointed_thing)
		end

		local facedir = core.dir_to_facedir(placer:get_look_dir())
		local top_pos = { x = pos.x, y = pos.y + 1, z = pos.z }

		if economies.buildable_to(pos, placer) and economies.buildable_to(top_pos, placer) then
			local nodename = itemstack:get_name()
			core.set_node(pos, { name = nodename, param2 = facedir })
			core.set_node(top_pos, { name = "bank:atm_top", param2 = facedir })
			itemstack:take_item()
			return itemstack
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local top_pos = { x = pos.x, y = pos.y + 1, z = pos.z }
		if core.get_node(top_pos).name == "bank:atm_top" then
			core.remove_node(top_pos)
		end
	end
})

core.register_node("bank:atm_top", {
	tiles = {
		"bank_atm_texture.png",
		"bank_atm_texture.png",
		"bank_atm_texture.png",
		"bank_atm_texture.png",
		"bank_atm_texture.png",
		"bank_atm_top_front.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=3},
	node_box = atm_model_top,
	selection_box = {
		type = "fixed",
		fixed = { 0, 0, 0, 0, 0, 0 }
	},
})
