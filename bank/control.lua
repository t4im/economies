-- these privileges seem to be consistent over most other economic mods, so lets reuse them as well
minetest.register_privilege("money", "Can transfer money")
minetest.register_privilege("money_admin", {
	description = "Can modify account balance and freeze/unfreeze the account.",
	give_to_singleplayer = false,
})

economy = economy or {}
economy.bank = economy.bank or {}

function economy.bank.alertAdmins(message)
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		if privs.ban or privs.money_admin then
			minetest.chat_send_player(name, string.format("[Bank] <ALERT> %s", message))
		end
	end
end

local bank_admin_params = "show/unfreeze <account> | freeze <account> <reason> | deposit/withdraw/set <account> <amount> | transfer <source> <target> <amount> [<subject>]"
minetest.register_chatcommand("bankadmin", {
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

			if (command == "transfer") then
				local target, transferAmount, subject = string.match(param, "transfer [^ ]+ ([^ ]+) ([0-9]+) (.*)")
				if(transferAmount and target) then
					local targetAccount = economy.bank.getAccount(target)
					-- add the information, that this was an admin action and by whome
					subject = name .. " enforced transfer. " .. (subject or "")
					return economy.feedbackTo(name, account:transferTo(targetAccount, transferAmount, subject))
				end
			elseif (command == "freeze" and args[3]) then
				-- args[3] is just the first word though enough for the test
				local reason = string.match(param, "freeze [^ ]+ (.+)")
				return economy.feedbackTo(name, account:freeze(reason))
			end

			local amount = tonumber(args[3])

			if (command == "show") then
				minetest.chat_send_player(name, account:describe())
				if account.transient then
					minetest.chat_send_player(name, "account is transient")
				end
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

-- simple and direct wire command allowing to provide a subject
minetest.register_chatcommand("wire", {
	description = "wire transfer <amount> of money from <account> (optionally with subject).",
	params = "<account> <amount> [<subject>]",
	privs = {money=true},
	func = function(name,  param)
		local account, amount, subject = string.match(param, "([^ ]+) ([0-9]+) (.*)")
		amount = tonumber(amount)

		if (account and amount and subject) then
			return economy.bank.wire(name, account, amount, subject)
		end

		minetest.chat_send_player(name, "Usage: <account> <amount> [<subject>])")
		return false
    end,
})

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
