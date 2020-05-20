local mod = get_mod("damage_numbers")

-- [[
return {
	name = "Damage Numbers",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = { -- array of widgets
			{
				setting_id = 'show_all_damage',
				type = 'checkbox',
				default_value = false,
			},
		}
	}
}
--]]
