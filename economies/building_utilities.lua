local economies = economies
function economies.topPosOf(pos) return { x = pos.x, y=pos.y + 1, z = pos.z } end

-- selects which node was pointed at
-- checks if it is known, right clickable or buildable_to first
-- can still return nil in some rare situations involving unknown nodes
function economies.get_base_node(pointed_thing)
	local pos = pointed_thing.under
	local def = minetest.registered_nodes[minetest.get_node(pos).name]

	if not def or (not def.on_rightclick and not def.buildable_to) then
		pos = pointed_thing.above
		def = minetest.registered_nodes[minetest.get_node(pos).name]
	end
	return pos, def
end

function economies.wallmountedAgainst(pointed_thing)
	local under, above = pointed_thing.under, pointed_thing.above
	return minetest.dir_to_wallmounted {
			x = under.x - above.x,
			y = under.y - above.y,
			z = under.z - above.z
	}
end

function economies.facedirTo(pointed_thing, placer)
	local above, placer_pos = pointed_thing.above, placer:getpos()
	return minetest.dir_to_facedir {
			x = above.x - placer_pos.x,
			y = above.y - placer_pos.y,
			z = above.z - placer_pos.z
	}
end

function economies.buildable_to(pos, placer)
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	return def and def.buildable_to and not minetest.is_protected(pos,  placer:get_player_name())
end

-- places a different node depending on circumstances
function economies.switch_on_place(ruleset)
	return function(itemstack, placer, pointed_thing)
		local pos, def = economies.get_base_node(pointed_thing)
		if not def then return end
		if def.on_rightclick then
			return def.on_rightclick(pos, minetest.get_node(pos), placer, itemstack, pointed_thing)
		end
		if not economies.buildable_to(pos, placer) then return end

		local wall_direction = economies.wallmountedAgainst(pointed_thing)
		local face_direction = economies.facedirTo(pointed_thing, placer)

		local replacement = nil
		if wall_direction == 0 and ruleset.on_ceiling then
			replacement = ruleset.on_ceiling
		elseif wall_direction == 1 and ruleset.on_ground then
			replacement = ruleset.on_ground
		else
			-- if no rule is matching, we assume to use the original node
			replacement = itemstack:get_name()
		end

		minetest.set_node(pointed_thing.above, { name = replacement, param2 = face_direction })

		itemstack:take_item()
		return itemstack
	end
end
