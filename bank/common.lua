function economy.formatMoney(amount)
	return economy.config:get("currency_format"):format(amount)
end

-- takes the function call and sends any contained feedback (second result) to the named player
-- then returns the first result
function economy.feedbackTo(name, result, feedback)
	if feedback then minetest.chat_send_player(name, feedback) end
	return result
end
