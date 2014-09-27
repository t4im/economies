--
-- market stalls
-- small enclosures within a market
-- usually manned by a merchant
-- can be very flexible in pricing, types of goods and amounts of goods being sold/bought, but lacks logistical integrations
-- they represent good shops for players just beginning to sell or buy goods (and thus should be a bit cheaper to craft)
-- but don't allow automation, shop extension or scaling as it'll be wanted for advanced shops

economies.markets.register_market("markets:treasure_box", {
	description = "a cheap box with mixed stuff sold for the same price",
	tiles = {
		"homedecor_cardboard_box_sides.png",
		"homedecor_cardboard_box_sides.png",
		"homedecor_cardboard_box_sides.png",
		"homedecor_cardboard_box_sides.png",
		"homedecor_cardboard_box_sides.png",
		"homedecor_cardboard_box_sides.png",
	}
	groups = { snappy=2, choppy=2, oddly_breakable_by_hand=2, flammable=1 },
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
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
})
