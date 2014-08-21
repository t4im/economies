-- these privileges seem to be consistent over most other economic mods, so lets reuse them as well
minetest.register_privilege("money", "Can transfer money")
minetest.register_privilege("money_admin", {
	description = "Can modify account balance and freeze/unfreeze the account.",
	give_to_singleplayer = false,
})

economy = economy or {}
economy.bank = economy.bank or {}

local alertAdmins = function(message)
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		if privs.ban or privs.money_admin then
			minetest.chat_send_player(name, string.format("[Bank] <ALERT> %s", message))
		end
	end
end

local bank_admin_params = "[show/unfreeze <account> | freeze <account> <reason> | deposit/withdraw/set <account> <amount> | transfer <source> <target> <amount>]"
minetest.register_chatcommand("bank_admin", {
	description = "Modify accounts",
	params = bank_admin_params,
	privs = {money_admin=true},
	func = function(name,  param)
		if param == "" then
			minetest.chat_send_player(name, "Usage: " .. bank_admin_params)
			return false
		end

		-- parse the parameters
		local args = string.split(param, " ")
        local command, accountName = args[1], args[2]

		if accountName then
			local account = economy.bank.getAccount(accountName)

			local transferAmount = tonumber(args[4])
			if (command == "transfer" and args[3] and transferAmount) then
				return economy.feedbackTo(name, account:transfer(actor, args[3], transferAmount))
			elseif (command == "freeze" and args[3]) then
				-- args[3] is just the first word though enough for the test
				local reason = string.match(param, "freeze [^ ]+ (.+)")
				return economy.feedbackTo(name, account:freeze(reason))
			end

			local amount = tonumber(args[3])

			if (command == "show") then
				minetest.chat_send_player(name, account:describe())
				return true
			elseif (command == "unfreeze") then
				return economy.feedbackTo(name, account:unfreeze())
			elseif (command == "deposit" and amount) then
				return economy.feedbackTo(name, account:deposit(amount))
			elseif (command == "withdraw" and amount) then
				return economy.feedbackTo(name, account:withdraw(amount))
			elseif (command == "set" and amount) then
				return economy.feedbackTo(name, account:set(amount))
			end
		end

		minetest.chat_send_player(name, "Usage: " .. bank_admin_params)
		return false
	end,
})

function economy.bank.wire(from, to, amount)
	-- lets ignore these already here to prevent a player from accidentally freezing his own account (see below)
	if(from == to or amount == 0 or not to or to == "") then
		minetest.chat_send_player(from, "Successfully done nothing.")
		return false
	end

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
		minetest.chat_send_player(from, to .. " is currently offline.")
		return false
	end

	-- check if target is frozen
	local targetAccount = economy.bank.getAccount(to)
	if (targetAccount:isFrozen()) then
		minetest.chat_send_player(from, "The target account is currently frozen.")
		return false
	end

	-- if both players are from the same ip it might be a possible cheating attempt
	-- since we only accept transfers to online players, this is bound to be noticed
	if minetest.get_player_ip(from) == minetest.get_player_ip(to) then
		alertAdmins(string.format(
			"%s tried to transfer %s to %s. Both clients are connected from the same IP address. The Accounts were preventively frozen.",
			from, economy.formatMoney(amount), to
		))
		minetest.chat_send_player(from,
			"You tried to transfer money to an account that originates from the same network as you.\n" ..
			"To prevent potential abuse the transfer was denied and admins were notified."
		)
		sourceAccount:freeze(string.format("attempt to transfer %s to %s, having the same ip address", economy.formatMoney(amount), to))
		targetAccount:freeze(string.format("target of an attempt to transfer %s from %s, having the same ip address", economy.formatMoney(amount), from))
		return false
	end

	return economy.feedbackTo(name, sourceAccount:transferTo(targetAccount, amount))
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
		amount = tonumber(amount)

		-- /money pay <account> <amount>
		if (command == "pay" and target and amount) then
			return economy.bank.wire(name, target, amount)
		else
			minetest.chat_send_player(name, "Invalid parameters (see /help money)")
			return false
		end
    end,
})
