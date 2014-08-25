--
-- Player notification
--
function economy.notify(player, message, ...)
	local name = player:get_player_name()
	if arg.n > 0
		then message = message:format(unpack(arg))
	end
	minetest.chat_send_player(name, message)
end

function economy.notifyAll(message, ...)
	if arg.n > 0 then
		message = message:format(unpack(arg))
	end
	minetest.chat_send_all(message)
end

function economy.notifyAny(condition, message, ...)
	if arg.n > 0 then
		message = message:format(unpack(arg))
	end
	for _,player in ipairs(minetest.get_connected_players()) do
		if condition(player) then
			economy.notify(player, message)
		end
	end
end

--
-- Log notification
--

local logPrefix = ("[%s] "):format(minetest.get_current_modname())
function economy.logAction(message, ...)
	if arg.n > 0 then
		message = message:format(unpack(arg))
	end
	minetest.log("action", logPrefix .. message)
end
function economy.debug(message, ...)
	if arg.n > 0 then
		message = message:format(unpack(arg))
	end
	minetest.debug(logPrefix .. message)
end
