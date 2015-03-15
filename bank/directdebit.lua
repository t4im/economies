local economies, bank, core = economies, bank, core

-- while this might not be abused to steal money,
-- it might very well be used to spam other players with debit requests
-- as such this priv should be reserved to players that have shown to behave well
core.register_privilege("debit", {
	description = "Can request direct debits from other players.",
	give_to_singleplayer = false,
})

function bank.debit(from, to, amount, subject)
	local transaction = bank.Transaction:new{initiator=to, source=from, target=to, amount=amount, subject=subject}
	transaction:to():getOwner():assertMayInit(transaction)
	bank.openDebitFormspec(transaction)
	return true
end

local debit_orders = {}

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "bank:debit_formspec" then return false end
	local playername = player:get_player_name()

	local transaction = debit_orders[playername]
	debit_orders[playername] = nil

	if fields.accept then
		transaction.amount = fields.amount
		if not economies.feedbackTo(playername, transaction:commit()) then
			core.chat_send_player(transaction.target, "Your direct debit was aborted due to debitor errors.")
		end
	else
		core.chat_send_player(transaction.target, "Your direct debit was denied by " .. playername)
	end
	return true
end)

function bank.openDebitFormspec(transaction)
	local playername = transaction.source
	local greeting = ("Hello %s. Your balance is %s\n%s asks you for a payment of %s.")
			:format(playername, transaction:from():printBalance(), transaction.target, transaction:printAmount())
	local formspec = string.format("size[7,5]"..
		"label[0.5,0.75;%s]" ..
		"label[0.5,2;Subject:\n%s]" ..
		"field[0.75,4;2,0.75;amount;Amount:;%d]" ..
		"button_exit[2.75,3.7;1.5,0.75;accept;Transfer]"..
		"button_exit[5,3.7;1.5,0.75;deny;Cancel]",
			greeting, core.formspec_escape(transaction.subject), transaction.amount)

	if debit_orders[playername] then
		core.chat_send_player(transaction.target, playername .. " is still being processed for another direct debit. Please try again later.")
		return
	end
	debit_orders[playername] = transaction
	core.show_formspec(playername, "bank:debit_formspec", formspec)
end

-- simple and direct wire command allowing to provide a subject
core.register_chatcommand("debit", {
	description = "request a debit of <amount> of money from <account> providing a <subject>.",
	params = "<account> <amount> <subject>",
	privs = {debit=true},
	func = function(name,  param)
		local account, amount, subject = string.match(param, "([^ ]+) ([0-9]+) (.+)")
		amount = tonumber(amount)

		if account and amount and subject then
			return bank.debit(account, name, amount, subject)
		end
		return false, "Usage: <account> <amount> <subject>"
    end,
})
