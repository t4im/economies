--
-- Banking accounts for players
-- allows storing and transferring funds between players
--
economy = economy or {}
economy.bank = economy.bank or {}
economy.bank.version = 1.00
economy.bank.modpath = minetest.get_modpath("bank")

-- load configuration
dofile(economy.bank.modpath.."/config.lua")

-- general helper functions
function economy.formatMoney(amount)
	return economy.config:get("currency_format"):format(amount)
end

-- takes the function call and sends any contained feedback (second result) to the named player
-- then returns the first result
function economy.feedbackTo(name, result, feedback)
	if feedback then minetest.chat_send_player(name, feedback) end
	return result
end

-- load accounting class and methods
dofile(economy.bank.modpath.."/bankaccount.lua")

-- load chatcommands, privileges and administration
dofile(economy.bank.modpath.."/control.lua")