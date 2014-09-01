economies = economies or {}
economies.bank = economies.bank or {}

function economies.bank.wire(from, to, amount, subject)
	local transaction = economies.bank.Transaction:new{source=from, target=to, amount=amount, subject=subject}

	local good, feedback = transaction:check()
	if not good then
		minetest.chat_send_player(from, feedback or "Wire transfer failed")
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

	-- if both players are from the same ip it might be a possible cheating attempt
	-- since we only accept transfers to online players, this is bound to be noticed
	if minetest.get_player_ip(from) == minetest.get_player_ip(to) then
		sourceAccount:freeze(string.format("attempt to transfer %s to %s, having the same ip address", economies.formatMoney(amount), to))
		targetAccount:freeze(string.format("target of an attempt to transfer %s from %s, having the same ip address", economies.formatMoney(amount), from))

		economies.notifyAny(economies.bank.isSupervisor,
			"%s tried to transfer %s to %s. Both clients are connected from the same IP address. The Accounts were preventively frozen.",
			from, economies.formatMoney(amount), to
		)
		minetest.chat_send_player(from,
			"You tried to transfer money to an account that originates from the same network as you.\n" ..
			"To prevent potential abuse the transfer was denied and admins were notified."
		)
		return false
	end

	return transaction:commit()
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "bank:wire_formspec" then return end

	if fields.transfer then
		economies.bank.wire(player:get_player_name(), fields.to, fields.amount, fields.subject)
	end
end)

function economies.bank.openWireFormspec(player)
	local playername = player:get_player_name()
	local account = economies.bank.getAccount(playername)
	local formspec = "size[10,7]"..
		"label[0.75,0.75; Welcome " .. playername .. "]" ..
		"label[5,0.75;" ..
			"Balance: " .. account:printBalance() .. "\n" ..
			"Frozen: " .. (account.frozen or "no") .. "]" ..
		"label[0.75,2.5;Wire transfer]" ..
		"field[1,4;8.25,0.75;subject;Subject (optional):;]" ..
		"field[1,5;4,0.75;to;To:;]" ..
		"field[5,5;2,0.75;amount;Amount:;0]" ..
		"button[7,4.75;2,0.75;transfer;Transfer]"..
		"button_exit[8,6;1.5,0.75;logout;Logout]"
	minetest.show_formspec(playername, "bank:wire_formspec", formspec)
end

-- simple and direct wire command allowing to provide a subject
minetest.register_chatcommand("wire", {
	description = "wire transfer <amount> of money from <account> (optionally with subject).",
	params = "<account> <amount> [<subject>]",
	privs = {money=true},
	func = function(name,  param)
		local account, amount, subject = string.match(param, "([^ ]+) ([0-9]+) ?(.*)")
		amount = tonumber(amount)

		if (account and amount and subject) then
			return economies.bank.wire(name, account, amount, subject)
		end

		minetest.chat_send_player(name, "Usage: <account> <amount> [<subject>])")
		return false
    end,
})
