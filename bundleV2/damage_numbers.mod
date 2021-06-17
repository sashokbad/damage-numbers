return {
  run = function()
    fassert(rawget(_G, "new_mod"), "`damage_numbers` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

    new_mod("damage_numbers", {
      mod_script       = "scripts/mods/damage_numbers/damage_numbers",
      mod_data         = "scripts/mods/damage_numbers/damage_numbers_data",
      mod_localization = "scripts/mods/damage_numbers/damage_numbers_localization",
    })
  end,
  packages = {
    "resource_packages/damage_numbers/damage_numbers",
  },
}
