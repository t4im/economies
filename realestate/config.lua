--
-- configuration handling
--
-- use economies.conf in your worldpath to change any settings listed as defaults here
--
-- economies.register_config_defaults({
-- })

-- optional dependency support
economies.with_landrush = minetest.get_modpath("landrush") ~= nil
economies.with_areas = minetest.get_modpath("areas") ~= nil
economies.with_protection = economies.with_landrush or economies.with_areas
