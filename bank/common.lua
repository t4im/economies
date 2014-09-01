-- takes the function call and sends any contained feedback (second result) to the named player
-- then returns the first result
function economies.feedbackTo(name, result, feedback)
	if feedback then minetest.chat_send_player(name, feedback) end
	return result
end

function economies.topPosOf(pos) return { x = pos.x, y=pos.y + 1, z = pos.z } end

function economies.basePos(pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	if minetest.registered_nodes[node.name]["buildable_to"] then
		return pointed_thing.under
	else
		return pointed_thing.above
	end
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
