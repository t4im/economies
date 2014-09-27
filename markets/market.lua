economies = economies or {}
economies.markets = economies.markets or {}
economies.markets.defaults = economies.markets.defaults or {}

economies.markets.defaults.group = { snappy=2, choppy=2 }
economies.markets.defaults.after_place_node = function(pos, placer, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local playername = placer:get_player_name()
	meta:set_string("owner", playername)
end

economies.markets.defaults.can_dig = function(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("main")
end

--economies.markets.defaults.on_punch = function(pos, node, puncher, pointed_thing)
--	minetest.node_punch(pos, node, puncher, pointed_thing)
--end

-- inventories
local function isOwner(player, pos) return player:get_player_name() == minetest.get_meta(pos):get_string("owner") end

economies.markets.defaults.allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	if not isOwner(player, pos) then
		return 0
	end
	return count
end
economies.markets.defaults.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	if not isOwner(player, pos) then
		economies.logAction("illegal inventory-put attempt by %s at %s", player:get_player_name(), minetest.pos_to_string(pos))
		return 0
	end
	return stack:get_count()
end
economies.markets.defaults.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	if not isOwner(player, pos) then
		economies.logAction("illegal inventory-take attempt by %s at %s", player:get_player_name(), minetest.pos_to_string(pos))
		return 0
	end
	return stack:get_count()
end

economies.markets.defaults.on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
end
economies.markets.defaults.on_metadata_inventory_put = function(pos, listname, index, stack, player)
	economies.logAction("inventory-put by %s at %s", player:get_player_name(), minetest.pos_to_string(pos))
end
economies.markets.defaults.on_metadata_inventory_take = function(pos, listname, index, stack, player)
	economies.logAction("inventory-take by %s at %s", player:get_player_name(), minetest.pos_to_string(pos))
end

-- registration
function economies.markets.register_market(name, spec)
	spec.description = spec.description and spec.description .. " (shop)"

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
	spec.can_dig = spec.can_dig or economies.markets.defaults.can_dig
--	spec.on_receive_fields = spec.on_receive_fields or economies.markets.defaults.on_receive_fields
--	spec.on_punch = spec.on_punch or economies.markets.defaults.on_punch
	spec.allow_metadata_inventory_move = spec.allow_metadata_inventory_move or economies.markets.defaults.allow_metadata_inventory_move
	spec.allow_metadata_inventory_put = spec.allow_metadata_inventory_put or economies.markets.defaults.allow_metadata_inventory_put
	spec.allow_metadata_inventory_take = spec.allow_metadata_inventory_take or economies.markets.defaults.allow_metadata_inventory_take
	spec.on_metadata_inventory_move = spec.on_metadata_inventory_move or economies.markets.defaults.on_metadata_inventory_move
	spec.on_metadata_inventory_put = spec.on_metadata_inventory_put or economies.markets.defaults.on_metadata_inventory_put
	spec.on_metadata_inventory_take = spec.on_metadata_inventory_take or economies.markets.defaults.on_metadata_inventory_take

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

	minetest.register_node(name, spec)
end
