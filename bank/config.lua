-- use economy.conf in your worldpath to change any settings listed as defaults below
economy.config = economy.config or Settings(minetest.get_worldpath().."/economy.conf")

local conf_table = economy.config:to_table()

local defaults = {
	initial_amount = "0",
	currency_symbol = "cr",
	currency_name = "credit",
	bank_path = "/bank"
}

for k, v in pairs(defaults) do
	if conf_table[k] == nil then
		economy.config:set(k, v)
	end
end