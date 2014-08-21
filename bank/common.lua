function economy.formatMoney(amount)
	return economy.config:get("currency_format"):format(amount)
end

-- takes the function call and sends any contained feedback (second result) to the named player
-- then returns the first result
function economy.feedbackTo(name, result, feedback)
	if feedback then minetest.chat_send_player(name, feedback) end
	return result
end

function economy.topPosOf(pos) return { x = pos.x, y=pos.y + 1, z = pos.z } end

function economy.basePos(pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	if minetest.registered_nodes[node.name]["buildable_to"] then
		return pointed_thing.under
	else
		return pointed_thing.above
	end
end

function economy.buildableTo(pos, placer)
	local node = minetest.get_node(pos)
	local buildable = minetest.registered_nodes[node.name]["buildable_to"]
	local protected = minetest.is_protected(pos, placer:get_player_name())
	return buildable and not protected
end
