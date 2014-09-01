--
-- market stalls
-- small enclosures within a market
-- usually manned by a merchant
-- can be very flexible in pricing, types of goods and amounts of goods being sold/bought, but lacks logistical integrations
-- they represent good shops for players just beginning to sell or buy goods (and thus should be a bit cheaper to craft)
-- but don't allow automation, shop extension or scaling as it'll be wanted for advanced shops

minetest.register_node("markets:treasure_box", {
	description = "a cheap box with mixed stuff sold for the same price",
	tiles = {
		"homedecor_cardboard_box_sides.png",
		"homedecor_cardboard_box_sides.png",
		"homedecor_cardboard_box_sides.png",
		"homedecor_cardboard_box_sides.png",
		"homedecor_cardboard_box_sides.png",
		"homedecor_cardboard_box_sides.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { snappy=2, choppy=2, oddly_breakable_by_hand=2, flammable=1 },
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local playername = placer:get_player_name()
		meta:set_string("owner", playername)
		meta:get_inventory():set_size("main", 4)
	end,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
			fixed = {
			{-6/16, -0.5, -6/16, 6/16, -7/16, 6/16}, -- bottom
			{-6.5/16, -0.5, -6/16, -6/16, 1/16, 6/16}, -- left
			{6/16, -0.5, -6/16, 6.5/16, 1/16, 6/16}, -- right
			{-6.5/16, -0.5, 6/16, 6.5/16, 1/16, 6.5/16}, -- back
			{-6.5/16, -0.5, -6.5/16, 6.5/16, 1/16, -6/16}, -- front
		}
	},
	drop = "default:paper",
	can_dig = economies.markets.defaults.can_dig,
--	on_receive_fields = economies.markets.defaults.on_receive_fields,
--	on_punch = economies.markets.defaults.on_punch,
	allow_metadata_inventory_move = economies.markets.defaults.allow_metadata_inventory_move,
	allow_metadata_inventory_put = economies.markets.defaults.allow_metadata_inventory_put,
	allow_metadata_inventory_take = economies.markets.defaults.allow_metadata_inventory_take,
	on_metadata_inventory_move = economies.markets.defaults.on_metadata_inventory_move,
	on_metadata_inventory_put = economies.markets.defaults.on_metadata_inventory_put,
	on_metadata_inventory_take = economies.markets.defaults.on_metadata_inventory_take,
})
