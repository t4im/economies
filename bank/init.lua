--
-- Banking accounts for players
-- allows storing and transferring funds between players
--
economy = economy or {}
economy.bank = economy.bank or {}
economy.bank.version = 1.00
economy.bank.modpath = minetest.get_modpath("bank")

-- load configuration
dofile(economy.bank.modpath.."/config.lua")
-- common helper functions
dofile(economy.bank.modpath.."/common.lua")

-- load classes and related api
dofile(economy.bank.modpath.."/bankaccount.lua")
dofile(economy.bank.modpath.."/transaction.lua")

-- add operational code
dofile(economy.bank.modpath.."/wiretransfer.lua")
dofile(economy.bank.modpath.."/control.lua")

-- extra nodes
dofile(economy.bank.modpath.."/atm.lua")
