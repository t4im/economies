economy = economy or {}
economy.bank = economy.bank or {}

-- while this might not be abused to steal money,
-- it might very well be used to spam other players with debit requests
-- as such this priv should be reserved to players that have shown to behave well
minetest.register_privilege("debit", {
	description = "Can request direct debits from other players.",
	give_to_singleplayer = false,
})

function economy.bank.debit(from, to, amount, subject)
	local transaction = economy.bank.Transaction:new{initiator=to, source=from, target=to, amount=amount, subject=subject}

	local good, feedback = transaction:check()
	if not good then
		minetest.chat_send_player(to, feedback or "Direct debit failed")
		return false
	end

	-- only allow transactions with online players to avoid
	-- * creating unnecessary accounts
	-- * lost money during transaction due to typos
	-- * transfers to alternative accounts without getting noticed
	local targetPlayer = minetest.get_player_by_name(from)
	if (not targetPlayer) then
		minetest.chat_send_player(to, from .. " is currently offline.")
		return false
	end

	-- if both players are from the same ip it might be a possible cheating attempt
	-- since we only accept transfers to online players, this is bound to be noticed
	if minetest.get_player_ip(from) == minetest.get_player_ip(to) then
		sourceAccount:freeze(string.format("direct debit attempt of %s from %s, having the same ip address", economy.formatMoney(amount), from))
		targetAccount:freeze(string.format("target of an direct debit attempt of %s to %s, having the same ip address", economy.formatMoney(amount), to))

		economy.notifyAny(economy.bank.isSupervisor,
			"%s tried a direct debit of %s from %s. Both clients are connected from the same IP address. The Accounts were preventively frozen.",
			to, economy.formatMoney(amount), from
		)
		minetest.chat_send_player(to,
			"You tried to debit money from an account that originates from the same network as you.\n" ..
			"To prevent potential abuse the direct debit was denied and admins were notified."
		)
		return false
	end

	economy.bank.openDebitFormspec(transaction)
	return true
end

local debit_orders = {}

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "bank:debit_formspec" then return end
	local playername = player:get_player_name()

	local transaction = debit_orders[playername]
	debit_orders[playername] = nil

	if fields.accept then
		transaction.amount = fields.amount
		if not economy.feedbackTo(playername, transaction:commit()) then
			minetest.chat_send_player(transaction.target, "Your direct debit was aborted due to debitor errors.")
		end
	else
		minetest.chat_send_player(transaction.target, "Your direct debit was denied by " .. playername)
	end
end)

function economy.bank.openDebitFormspec(transaction)
	local playername = transaction.source
	local greeting = ("Hello %s. Your balance is %s\n%s asks you for a payment of %s.")
			:format(playername, transaction:from():printBalance(), transaction.target, transaction:printAmount())
	local formspec = "size[7,5]"..
		"label[0.5,0.75;" .. greeting .. "]" ..
		"label[0.5,2;Subject:\n " .. minetest.formspec_escape(transaction.subject) .. "]" ..
		"field[0.75,4;2,0.75;amount;Amount:;" .. transaction.amount .. "]" ..
		"button_exit[2.75,3.7;1.5,0.75;accept;Transfer]"..
		"button_exit[5,3.7;1.5,0.75;deny;Cancel]"

	if debit_orders[playername] then
		minetest.chat_send_player(transaction.target, playername .. " is still being processed for another direct debit. Please try again later.")
		return
	end
	debit_orders[playername] = transaction
	minetest.show_formspec(playername, "bank:debit_formspec", formspec)
end

-- simple and direct wire command allowing to provide a subject
minetest.register_chatcommand("debit", {
	description = "request a debit of <amount> of money from <account> providing a <subject>.",
	params = "<account> <amount> <subject>",
	privs = {debit=true},
	func = function(name,  param)
		local account, amount, subject = string.match(param, "([^ ]+) ([0-9]+) (.+)")
		amount = tonumber(amount)

		if (account and amount and subject) then
			return economy.bank.debit(account, name, amount, subject)
		end

		minetest.chat_send_player(name, "Usage: <account> <amount> <subject>")
		return false
    end,
})