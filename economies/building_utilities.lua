function economies.topPosOf(pos) return { x = pos.x, y=pos.y + 1, z = pos.z } end

function economies.basePos(pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	if minetest.registered_nodes[node.name]["buildable_to"] then
		return pointed_thing.under
	else
		return pointed_thing.above
	end
end

function economies.wallmountedAgainst(pointed_thing)
	return minetest.dir_to_wallmounted {
			x = pointed_thing.under.x - pointed_thing.above.x,
			y = pointed_thing.under.y - pointed_thing.above.y,
			z = pointed_thing.under.z - pointed_thing.above.z
	}
end

function economies.facedirTo(pointed_thing, placer)
	local placer_pos = placer:getpos()
	return minetest.dir_to_facedir {
			x = pointed_thing.above.x - placer_pos.x,
			y = pointed_thing.above.y - placer_pos.y,
			z = pointed_thing.above.z - placer_pos.z
	}
end

function economies.buildableTo(pos, placer, reportViolation)
	local node, player = minetest.get_node(pos), placer:get_player_name()
	local buildable = minetest.registered_nodes[node.name]["buildable_to"]
	local protected = minetest.is_protected(pos, player)
	if protected and reportViolation then
		minetest.record_protection_violation(pointed_thing.above, player)
	end
	return buildable and not protected
end

-- places a different node depending on circumstances
function economies.switch_on_place(ruleset)
	return function(itemstack, placer, pointed_thing)
		-- if we can't place it against it, or are not allowed to, ignore the placement completly
		if not economies.buildableTo(pointed_thing.above, placer, false) then
			return itemstack
		end

		-- right click functionality of a targeted node has priority over placing this one against it
		local target_node = minetest.get_node(pointed_thing.under)
		local target_node_def = minetest.registered_nodes[target_node.name]
		if target_node_def and target_node_def.on_rightclick then
			return target_node_def.on_rightclick(pointed_thing.under, target_node, placer, itemstack)
		end

		local wall_direction = economies.wallmountedAgainst(pointed_thing)
		local face_direction = economies.facedirTo(pointed_thing, placer)

		local replacement = nil

		if wall_direction == 0 and ruleset.on_ceiling then
			replacement = ruleset.on_ceiling
		elseif wall_direction == 1 and ruleset.on_ground then
			replacement = ruleset.on_ground
		end

		-- if no rule is matching, we assume to use the original node
		minetest.add_node(pointed_thing.above, { name = (replacement or itemstack:get_name()), param2 = face_direction })

		itemstack:take_item()
		return itemstack
	end
end
