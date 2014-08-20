-- these privileges seem to be consistent over most other economic mods, so lets reuse them as well
minetest.register_privilege("money", "Can transfer money")
minetest.register_privilege("money_admin", {
	description = "Can modify account balance and freeze/unfreeze the account.",
	give_to_singleplayer = false,
})

local pay = function(from, to, amount)
	-- check if source is frozen
	local sourceAccount = economy.bank.getAccount(from)
	if (sourceAccount:isFrozen()) then
		minetest.chat_send_player(from, "Your account is currently frozen.")
		return false
	end

	-- only allow transactions with online players to avoid
	-- * creating unnecessary accounts
	-- * lost money during transaction due to typos
	-- * transfers to alternative accounts without getting noticed
	local targetPlayer = minetest.get_player_by_name(to)
	if (not targetPlayer) then
		minetest.chat_send_player(from, targetPlayer .. " is currently offline.")
		return false
	end

	-- check if target is frozen
	local targetAccount = economy.bank.getAccount(to)
	if (targetAccount:isFrozen()) then
		minetest.chat_send_player(from, "The target account is currently frozen.")
		return false
	end

	sourceAccount:transferTo(from, targetAccount, amount)
end

-- since several other economic mods use this command in this form, we want to support it for the users as well
-- however administrative functions remain handled extra,
-- which adds an additional layer of security against accidents by admins
minetest.register_chatcommand("money", {
	description = "Show balance or pay <account> <amount> of money.",
	params = "[pay <account> <amount>]",
	privs = {money=true},
	func = function(name,  param)
		-- /money
		if param == "" then
			local account = economy.bank.getAccount(name)
			minetest.chat_send_player(name, account:printBalance())

			if (account:isFrozen()) then
				minetest.chat_send_player(name, "Your account is currently frozen.")
			end
			return true
		end

		-- parse the parameters
		local command, target, amount = string.match(param, "([^ ]+) ([^ ]+) (.+)")

		-- /money pay <account> <amount>
		if (command == "pay" and target and amount) then
			pay(name, target, amount)
		else
			minetest.chat_send_player(name, "Invalid parameters (see /help money)")
			return false
		end
    end,
})