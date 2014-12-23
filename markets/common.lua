economies = economies or {}
markets = markets or {}
markets.defaults = markets.defaults or {}

markets.defaults.group = { snappy=2, choppy=2 }

markets.defaults.after_place_node = function(pos, placer, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local playername = placer:get_player_name()
	meta:set_string("owner", playername)
end

markets.defaults.can_dig = function(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("main")
end

--markets.defaults.on_punch = function(pos, node, puncher, pointed_thing)
--	minetest.node_punch(pos, node, puncher, pointed_thing)
--end

-- inventories
local function isOwner(player, pos) return player:get_player_name() == minetest.get_meta(pos):get_string("owner") end

markets.defaults.allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	if not isOwner(player, pos) then
		return 0
	end
	return count
end
markets.defaults.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	if not isOwner(player, pos) then
		economies.logAction("illegal inventory-put attempt by %s at %s", player:get_player_name(), minetest.pos_to_string(pos))
		return 0
	end
	return stack:get_count()
end
markets.defaults.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	if not isOwner(player, pos) then
		economies.logAction("illegal inventory-take attempt by %s at %s", player:get_player_name(), minetest.pos_to_string(pos))
		return 0
	end
	return stack:get_count()
end

markets.defaults.on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
end
markets.defaults.on_metadata_inventory_put = function(pos, listname, index, stack, player)
	economies.logAction("inventory-put by %s at %s", player:get_player_name(), minetest.pos_to_string(pos))
end
markets.defaults.on_metadata_inventory_take = function(pos, listname, index, stack, player)
	economies.logAction("inventory-take by %s at %s", player:get_player_name(), minetest.pos_to_string(pos))
end

