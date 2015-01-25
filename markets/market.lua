economies = economies or {}
markets = markets or {}

local function isOwner(player, pos) return player:get_player_name() == minetest.get_meta(pos):get_string("owner") end

markets.defaults = {
	group = { snappy=2, choppy=2 },
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	-- inventories
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if not isOwner(player, pos) or from_list == "item_type" then
			return 0
		end
		return count
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if not isOwner(player, pos) then
			local player_name = player:get_player_name()
			minetest.chat_send_player(player_name, "You are not allowed to configure another players market")
			economies.logAction("illegal inventory-put attempt by %s at %s", player_name, minetest.pos_to_string(pos))
			return 0
		end
		if(listname == "item_type") then
			local virtual_stack = ItemStack(stack)
			virtual_stack:set_count(1)
			minetest.get_meta(pos):get_inventory():set_stack(listname, index, virtual_stack)
			return 0
		end

		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if not isOwner(player, pos) then
			local player_name = player:get_player_name()
			minetest.chat_send_player(player_name, "You are not allowed to configure another players market")
			economies.logAction("illegal inventory-take attempt by %s at %s", player_name, minetest.pos_to_string(pos))
			return 0
		end
		if(listname == "item_type") then
			minetest.get_meta(pos):get_inventory():set_stack(listname, index, ItemStack(""))
			return 0
		end
		return stack:get_count()
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		economies.logAction("inventory-put by %s at %s", player:get_player_name(), minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		economies.logAction("inventory-take by %s at %s", player:get_player_name(), minetest.pos_to_string(pos))
	end
}

-- registration
function markets.register_market(name, spec)
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
	spec.drawtype = spec.drawtype or (spec.node_box and "nodebox")
	spec.groups = spec.groups or markets.defaults.group
	spec.can_dig = spec.can_dig or markets.defaults.can_dig
	spec.allow_metadata_inventory_move = spec.allow_metadata_inventory_move or markets.defaults.allow_metadata_inventory_move
	spec.allow_metadata_inventory_put = spec.allow_metadata_inventory_put or markets.defaults.allow_metadata_inventory_put
	spec.allow_metadata_inventory_take = spec.allow_metadata_inventory_take or markets.defaults.allow_metadata_inventory_take
	spec.on_metadata_inventory_move = spec.on_metadata_inventory_move or markets.defaults.on_metadata_inventory_move
	spec.on_metadata_inventory_put = spec.on_metadata_inventory_put or markets.defaults.on_metadata_inventory_put
	spec.on_metadata_inventory_take = spec.on_metadata_inventory_take or markets.defaults.on_metadata_inventory_take

--	spec.on_construct = spec.on_construct or function(pos)
--		local meta = minetest.get_meta(pos)
--	end

	spec.after_place_node = spec.after_place_node or function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local playername = placer:get_player_name()
		meta:set_string("owner", playername)
		meta:set_string("infotext", "Unconfigured Shop (owned by " .. playername .. ")")
		markets.setup.metadata(meta)

		if placer:get_player_control().sneak then
			markets.setup.item:show(playername, {pos=pos})
		end
	end

	spec.on_receive_fields = spec.on_receive_fields or function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
	end

	spec.on_punch = spec.on_punch or markets.defaults.on_punch or function(pos, node, puncher, pointed_thing)
		if isOwner(puncher, pos) then
			markets.setup.item:show(puncher:get_player_name(), {pos=pos})
		end
	end

	minetest.register_node(name, spec)
end
