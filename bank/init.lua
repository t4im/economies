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
dofile(economy.bank.modpath.."/notifications.lua")

-- load classes and related api
dofile(economy.bank.modpath.."/bankaccount.lua")
dofile(economy.bank.modpath.."/journal.lua")
dofile(economy.bank.modpath.."/transaction.lua")

dofile(economy.bank.modpath.."/imports.lua")

-- add operational code
dofile(economy.bank.modpath.."/wiretransfer.lua")
dofile(economy.bank.modpath.."/directdebit.lua")
dofile(economy.bank.modpath.."/control.lua")

-- craftitems
--dofile(economy.bank.modpath.."/cards.lua")

-- extra nodes
dofile(economy.bank.modpath.."/atm.lua")
