economies = economies or {}
economies.markets = economies.markets or {}

function economies.markets.register_market(name, spec)
	spec.tiles = spec.tiles or {
		"default_chest_top.png",
		"default_chest_top.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_lock.png"
	}
	spec.paramtype = spec.paramtype or "light"
	spec.paramtype2 = spec.paramtype2 or "facedir"
	spec.groups = spec.groups or economies.markets.defaults.group
	spec.can_dig = spec.can_dig or economies.markets.defaults.can_dig,
--	spec.on_receive_fields = spec.on_receive_fields or economies.markets.defaults.on_receive_fields,
--	spec.on_punch = spec.on_punch or economies.markets.defaults.on_punch,
	spec.allow_metadata_inventory_move = spec.allow_metadata_inventory_move or economies.markets.defaults.allow_metadata_inventory_move
	spec.allow_metadata_inventory_put = spec.allow_metadata_inventory_put or economies.markets.defaults.allow_metadata_inventory_put
	spec.allow_metadata_inventory_take = spec.allow_metadata_inventory_take or economies.markets.defaults.allow_metadata_inventory_take,
	spec.on_metadata_inventory_move = spec.on_metadata_inventory_move or economies.markets.defaults.on_metadata_inventory_move,
	spec.on_metadata_inventory_put = spec.on_metadata_inventory_put or economies.markets.defaults.on_metadata_inventory_put,
	spec.on_metadata_inventory_take = spec.on_metadata_inventory_take or economies.markets.defaults.on_metadata_inventory_take,

	spec.on_construct = spec.on_construct or function(pos)
		local meta = minetest.get_meta(pos)
		-- meta:get_inventory():set_size("main", 4)
	end

	spec.after_place_node = spec.after_place_node or function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local playername = placer:get_player_name()
		meta:set_string("owner", playername)
		meta:set_string("infotext", "Unconfigured Shop (owned by " .. playername .. ")")
	end

--	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
--	end

	minetest.register_node(mame, spec)
end
