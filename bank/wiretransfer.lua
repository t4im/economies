economy = economy or {}
economy.bank = economy.bank or {}

function economy.bank.wire(from, to, amount, subject)
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

	return economy.feedbackTo(name, sourceAccount:transferTo(targetAccount, amount, subject))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "bank:wire_formspec" then return end

	if fields.transfer then
		economy.bank.wire(player:get_player_name(), fields.to, fields.amount, fields.subject)
	end
end)

function economy.bank.openWireFormspec(player)
	local playername = player:get_player_name()
	local account = economy.bank.getAccount(playername)
	local formspec = "size[10,7]"..
		"label[0.75,0.75; Welcome " .. account.owner .. "]" ..
		"label[5,0.75;" ..
			"Balance: " .. account:printBalance() .. "\n" ..
			"Frozen: " .. (account:isFrozen() or "no") .. "]" ..
		"label[0.75,2.5;Wire transfer]" ..
		"field[1,4;8.25,0.75;subject;Subject (optional):;]" ..
		"field[1,5;4,0.75;to;To:;]" ..
		"field[5,5;2,0.75;amount;Amount:;0]" ..
		"button[7,4.75;2,0.75;transfer;Transfer]"..
		"button_exit[8,6;1.5,0.75;logout;Logout]"
	minetest.show_formspec(playername, "bank:wire_formspec", formspec)
end
