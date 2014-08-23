economy = economy or {}
economy.realestate = economy.realestate or {}
economy.realestate.landsale = economy.realestate.landsale or {}

-- this function is expected to be implemented by protection mods
-- return true on success or false with an optional error message
-- economy.realestate.transfer = function(pos, node, puncher)

function economy.realestate.landsale.receive_fields(pos, formname, fields, sender)
	local name = sender:get_player_name()
	if not fields.setup then return end

	if minetest.is_protected(pos, name) then
		minetest.chat_send_player(name, "You cannot configure a sale of land, that does not belong to you.")
		return
	end

	local price = economy.feedbackTo(name, economy.sanitizeAmount(fields.price))
	if not price then return end

	local account = economy.bank.getAccount(name)
	if account.frozen then
		minetest.chat_send_player(name, "Your account is frozen. You may not sell any land at this time.")
		return
	end
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", string.format("For sale by %s for %d\n%s", name, price, fields.description or ""))
	meta:set_string("seller", name)
	meta:set_int("price", price)
	meta:set_string("name", fields.name)
	meta:set_string("description", fields.description)
end

function economy.realestate.landsale.punch(pos, node, puncher)
	local name = puncher:get_player_name()
	if not minetest.is_protected(pos, name) or not economy.realestate.transfer then
		-- either has the owner just punched his own salesblock
		-- or the land is unowned/unprotected anyway
		return;
	end

	local buyerAccount = economy.bank.getAccount(name)
	if buyerAccount.frozen then
		minetest.chat_send_player(name, "Your account is frozen. You may not sell any land at this time.")
		return
	end

	local meta = minetest.get_meta(pos)
	local seller = meta:get_string("seller")
	local targetAccount = economy.bank.getAccount(seller)
	if targetAccount.frozen then
		minetest.chat_send_player(name, "The seller account is frozen. You may not buy this land at this time.")
		return
	end

	local transferAmount = meta:get_int("price")
	local landname = meta:get_string("name")
	local subject = string.format("Landsale at (%d,%d) %s", pos.x, pos.z, landname or "")

	lcoal transaction = Transaction:new{source=name, target=seller, amount=transferAmount, subject=subject, location=pos}

	-- if transfer successfull (especially after balance check)
	if economy.feedbackTo(name, transaction:checkAndCommit()) then
		economy.realestate.transfer(pos, node, puncher)
		minetest.remove_node(pos)
		minetest.chat_send_player(puncher:get_player_name(), "Congratulations! This land is now yours.")
	end
end

function economy.realestate.landsale.construct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", "Soon for sale!")
	meta:set_string("formspec", "size[5,4]" ..
				"label[0.5,0;Setup landsale]" ..
				"field[0.5,1;3,1;name;Name;${name}]" ..
				"field[3.5,1;1.5,1;price;Price;${price}]" ..
				"textarea[0.5,2;4.5,1;description;Description;${description}]" ..
				"button_exit[0.5,3;2,1;close;Close]" ..
				"button_exit[2.5,3;2,1;setup;Setup]")
end
