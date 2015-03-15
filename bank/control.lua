minetest.register_privilege("bank_teller", {
	description = "Can handle basic administrative banking tasks like freeze/unfreeze accounts or peek into other accounts",
	give_to_singleplayer = false,
})
minetest.register_privilege("bank_admin", {
	description = "Can modify account balance.",
	give_to_singleplayer = false,
})

economies = economies or {}
bank = bank or {}

local bank_admin_params = "show/unfreeze <account> | freeze <account> <reason> | deposit/withdraw/set <account> <amount> | transfer <source> <target> <amount> [<subject>]"
minetest.register_chatcommand("bankadmin", {
	description = "Modify accounts",
	params = bank_admin_params,
	privs = {bank_teller=true},
	func = function(name,  param)
		if param == "" then return false, "Usage: " .. bank_admin_params end

		-- parse the parameters
		local args = string.split(param, " ")
		local command, accountName = args[1], args[2]

		if accountName then
			local privs = minetest.get_player_privs(name)
			if (command == "transfer" and privs.bank_admin) then
				local target, transferAmount, subject = string.match(param, "transfer [^ ]+ ([^ ]+) ([0-9]+) ?(.*)")
				if(transferAmount and target) then
					-- add the information, that this was an admin action and by whome
					subject = name .. " enforced transfer. " .. (subject or "")
					return bank.Transaction:new{
						initiator=name,
						source=accountName, target=target,
						amount=transferAmount, subject=subject
					}:commit()
				end
			end

			local account = bank.getAccount(accountName)
			if (command == "freeze" and args[3]) then
				-- args[3] is just the first word though enough for the test
				local reason = string.match(param, "freeze [^ ]+ (.+)")
				return account:freeze(reason)
			end

			local amount = tonumber(args[3])

			if (command == "show") then
				local output = account:describe()
				if account.transient then
					output = output .. "\n  account is transient"
				end
				return true, output
			elseif (command == "unfreeze") then
				return account:unfreeze()
			elseif (command == "deposit" and amount and privs.bank_admin) then
				economies.logAction("%s depositing %d at %s", name, amount, accountName)
				return account:deposit(amount)
			elseif (command == "withdraw" and amount and privs.bank_admin) then
				economies.logAction("%s withdrawing %d from %s", name, amount, accountName)
				return account:withdraw(amount)
			elseif (command == "set" and amount and privs.bank_admin) then
				economies.logAction("%s setting %s to %d", name, accountName, amount)
				return account:set(amount)
			end
		end

		return false, "Usage: " .. bank_admin_params
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
			local account = bank.getAccount(name)
			if (account.frozen) then
				return false, "Your account is currently frozen."
			end
			return true, account:printBalance()
		end

		-- parse the parameters
		local command, target, amount = string.match(param, "([^ ]+) ([^ ]+) (.+)")
		amount = tonumber(amount)

		-- /money pay <account> <amount>
		if (command == "pay" and target and amount) then
			return bank.wire(name, target, amount)
		else
			return false, "Invalid parameters (see /help money)"
		end
    end,
})
