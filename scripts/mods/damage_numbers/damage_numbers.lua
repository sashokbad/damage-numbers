-- Damage Numbers
-- A mod for Vermintide 2
-- Made by OrangeChris
-- Version 1.2
-- Last updated for Vermintide 2 version 5.5.6 on 2024-06-12

local mod = get_mod('damage_numbers')

-- Your mod code goes here.
-- https://vmf-docs.verminti.de

-- If any of the following Vermintide 2 files are changed, this mod should be checked:
-- 		scripts/ui/hud_ui/damage_numbers_ui.lua
-- 		scripts/unit_extensions/generic/generic_health_extension.lua
-- 		ui/views/ingame_hud_definitions.lua
-- 		...anything that extends GenericHealthExtension, especially TrainingDummyHealthExtension

-- Check whether the attacker is one that we want to show damage for.
local function is_valid_source(attacker_unit)
  if mod:get('show_all_damage') then
    return true
  else
    return Managers.player:local_player().player_unit == attacker_unit
  end
end

--- Called when the unit takes damage.
-- @param func The original function
-- @param self An instance of HealthExtension; the unit being attacked
-- @param attacker_unit The unit dealing the damage
-- @param hit_zone_name
-- @param damage_type A string describing the type of damage
local function hook_add_damage(func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
  if self:is_alive() and damage_amount > 0 and is_valid_source(attacker_unit) then
    local remaining_health = self.health - self.damage
    local actual_damage = math.min(damage_amount, remaining_health)
    local is_critical_strike = select(7, ...)

    DamageUtils.add_unit_floating_damage_numbers(self.unit, damage_type, actual_damage, is_critical_strike)
  end

  return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
end

mod:hook(GenericHealthExtension, 'add_damage', hook_add_damage)
-- RatOgreHealthExtension has to be hooked separately, because it extends
-- GenericHealthExtension but does not override add_damage.
mod:hook(RatOgreHealthExtension, 'add_damage', hook_add_damage)

-- script_data.debug_show_damage_numbers is used by the validation function
-- for the DamageNumbersUI component in scripts/ui/views/ingame_hud_definitions.lua.
function mod:on_enabled()
  script_data.debug_show_damage_numbers = true
end
function mod:on_disabled()
  script_data.debug_show_damage_numbers = nil
end
