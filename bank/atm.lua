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
		{-0.375, 0.3125, -0.1875, 0.1875, 0.5, 0}, -- ceiling
		{-0.5, -0.5, -0.25, -0.375, 0.5, 0.5}, -- leftwall
		{0.1875, -0.5, -0.25, 0.5, 0.5, 0.5}, -- rightwall
		{-0.375, -0.5, 0, 0.1875, 0.5, 0.5}, -- base
	}
}

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "bank:wire_formspec" then return end

	if fields.transfer then
		economy.bank.wire(player:get_player_name(), fields.to, fields.amount)
	end
end)

local open_atm_wire_formspec = function(player)
	local playername = player:get_player_name()
	local account = economy.bank.getAccount(playername)
	local formspec = "size[10,7]"..
		"label[0.75,0.75; Welcome " .. account.owner .. "]" ..
		"label[5,0.75;" ..
			"Balance: " .. account:printBalance() .. "\n" ..
			"Frozen: " .. (account:isFrozen() or "no") .. "]" ..
		"label[0.75,2.5;Wire transfer]" ..
		"field[1,4;8.25,0.75;subject;Subject (optional):;]" ..
		"field[1,5;4,0.75;to;To:;]" ..
		"field[5,5;2,0.75;amount;Amount:;0]" ..
		"button[7,4.75;2,0.75;transfer;Transfer]"..
		"button_exit[8,6;1.5,0.75;logout;Logout]"
	minetest.show_formspec(playername, "bank:wire_formspec", formspec)
end

minetest.register_node("bank:atm_bottom", {
	tiles = {
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png"
	},
	-- inventory_image = "",
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
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "ATM")
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		open_atm_wire_formspec(clicker)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = economy.basePos(pointed_thing)
		local facedir = minetest.dir_to_facedir(placer:get_look_dir())
		local top_pos = economy.topPosOf(pos)

		if economy.buildableTo(pos, placer) and economy.buildableTo(top_pos, placer) then
			local nodename = itemstack:get_name()
			minetest.add_node(pos, { name = nodename, param2 = facedir })
			minetest.add_node(top_pos, { name = "bank:atm_top", param2 = facedir })
			itemstack:take_item()
			return itemstack
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local top_pos = economy.topPosOf(pos)
		if minetest.get_node(top_pos).name == "bank:atm_top" then
			minetest.remove_node(top_pos)
		end
	end
})

minetest.register_node("bank:atm_top", {
	tiles = {
		"default_steel_block.png", -- top
		"default_steel_block.png",
		"default_steel_block.png", -- side
		"default_steel_block.png^[transformFX", -- side
		"default_steel_block.png", -- back
		"default_steel_block.png" -- back
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
