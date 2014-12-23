economies = economies or {}
bank = bank or {}

function bank.wire(from, to, amount, subject)
	local transaction = bank.Transaction:new{source=from, target=to, amount=amount, subject=subject}
	transaction:from():getOwner():assertMayInit(transaction)
	return transaction:commit()
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "bank:wire_formspec" then return end

	if fields.transfer then
		bank.wire(player:get_player_name(), fields.to, fields.amount, fields.subject)
	end
end)

function bank.openWireFormspec(player)
	local playername = player:get_player_name()
	local account = bank.getAccount(playername)
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
			return bank.wire(name, account, amount, subject)
		end

		minetest.chat_send_player(name, "Usage: <account> <amount> [<subject>])")
		return false
    end,
})
