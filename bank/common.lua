function economy.formatMoney(amount)
	return economy.config:get("currency_format"):format(amount)
end

-- processes and cleans a passed amount value with basic sanity checks
-- returns the resulting amount or nil if unsuccessful
function economy.sanitizeAmount(amount)
	-- first lets make sure we really have a number
	amount = tonumber(amount)
	if not amount then return nil, "Not a number" end

	-- make sure no one tries to set Pi amount of credits, or similar annoyances
	amount = math.ceil(amount)

	-- we generally don't allow operations on negative values
	if(amount < 0) then
		return nil, "You must not pass a negative amount."
	end

	return amount
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

function economy.buildableTo(pos, placer, reportViolation)
	local node, player = minetest.get_node(pos), placer:get_player_name()
	local buildable = minetest.registered_nodes[node.name]["buildable_to"]
	local protected = minetest.is_protected(pos, player)
	if protected and reportViolation then
		minetest.record_protection_violation(pointed_thing.above, player)
	end
	return buildable and not protected
end
