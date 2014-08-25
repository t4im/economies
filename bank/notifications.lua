--
-- Player notification
--
function economy.notify(player, notification)
	local name = player:get_player_name()
	minetest.chat_send_player(name, notification)
end

function economy.notifyAll(notification)
	minetest.chat_send_all(notification)
end

function economy.notifyAny(condition, notification)
	for _,player in ipairs(minetest.get_connected_players()) do
		if condition(player) then
			economy.notify(player, notification)
		end
	end
end


