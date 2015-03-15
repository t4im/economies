local economies, bank = economies, bank

function bank.wire(from, to, amount, subject)
	local transaction = bank.Transaction:new{source=from, target=to, amount=amount, subject=subject}
	if transaction:fromAgent():assertMayInit(transaction) then
		return transaction:commit()
	end
	return false
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "bank:wire_formspec" then return false end

	if fields.transfer then
		bank.wire(player:get_player_name(), fields.to, fields.amount, fields.subject)
	end
	return true
end)

function bank.openWireFormspec(player)
	local playername = player:get_player_name()
	local account = bank.getAccount(playername)
	local formspec = string.format("size[10,7]"..
		"label[0.3,0.7; Welcome %s]" ..
		"label[5,0.7;Balance: %s]" ..
		"box[0.3,2;9,3.7;#555]" ..
		"label[0.7,2.5;Wire transfer]" ..
		"field[1,4;8.3,0.7;subject;Subject (optional):;]" ..
		"field[1,5;4,0.7;to;To:;]" ..
		"field[5,5;2,0.7;amount;Amount:;0]" ..
		"button[7,4.7;2,0.7;transfer;Transfer]"..
		"button_exit[8,6;1.5,0.7;logout;Logout]",
			playername, account:printBalance())
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

		if account and amount and subject then
			return bank.wire(name, account, amount, subject)
		end
		return false, "Usage: <account> <amount> [<subject>])"
    end,
})
