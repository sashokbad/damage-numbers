-- Damage Numbers
-- A mod for Vermintide 2
-- Made by OrangeChris
-- Version 1.2
-- Last updated for Vermintide 2 version 4.4.0.3 on 2021-06-17

local mod = get_mod('damage_numbers')

-- Your mod code goes here.
-- https://vmf-docs.verminti.de

-- If any of the following Vermintide 2 files are changed, this mod should be checked:
-- 		scripts/ui/hud_ui/damage_numbers_ui.lua
-- 		scripts/unit_extensions/generic/generic_health_extension.lua
-- 		ui/views/ingame_hud_definitions.lua
-- 		...anything that extends GenericHealthExtension, especially TrainingDummyHealthExtension

local DOT_DAMAGE_TYPES = {
  bleed = true,
  burninating = true,
  arrow_poison_dot = true,
}

--- Generate the color of the damage number.
-- @see TrainingDummyHealthExtension#add_damage
-- @param damage The amount of damage being dealt
-- @param damage_type A string describing the type of damage
local function get_damage_color(damage, damage_type)
  if DOT_DAMAGE_TYPES[damage_type] then
    return Vector3(192, 192, 192) -- white
  end
  local red = math.min(120 + damage * 4, 255)
  local green = math.max(200 - damage * 4, 0)
  return Vector3(red, green, 0)
end

--- A copy of DamageNumbersUI#event_add_damage_number. The only difference is
-- ours formats the damage.
local function hook_event_add_damage_number(func, self, damage, size, unit, time, color, is_critical_strike)
  local camera_position = Camera.world_position(self.camera)
  local unit_position = Unit.world_position(unit, 0)
  local cam_to_unit_dir = Vector3.normalize(unit_position - camera_position)
  local cam_direction = Quaternion.forward(Camera.world_rotation(self.camera))
  local forward_dot = Vector3.dot(cam_direction, cam_to_unit_dir)
  local is_infront = forward_dot >= 0 and forward_dot <= 1

  if is_infront then
    local size = size or 1
    local color = color or Vector3(255, 255, 255)
    local new_text = {
      floating_speed = 150,
      alpha = 255,
      size = size,
      -- this line is the one that's different, format to 2 decimal places
      text = string.format('%.2f', damage * 100),
      color = {
        255,
        color.x,
        color.y,
        color.z
      },
      time = self._time + (time or self._unit_text_time),
      starting_time = self._time,
      random_x_offset = math.random(-60, 60),
      random_y_offset = math.random(-40, 40),
      is_critical_strike = is_critical_strike
    }
    self._unit_texts[unit] = self._unit_texts[unit] or {}
    self._unit_texts[unit][#self._unit_texts[unit] + 1] = new_text
  end
end

mod:hook(DamageNumbersUI, 'event_add_damage_number', hook_event_add_damage_number)

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
    local text_size = 40
    local unit = self.unit
    local duration = 2.2
    local color = get_damage_color(damage_amount, damage_type)
    local is_critical_strike = select(7, ...)
    -- We still divide by 100 here because that's what TrainingDummyHealthExtension does
    Managers.state.event:trigger('add_damage_number', actual_damage / 100, text_size, unit, duration, color, is_critical_strike)
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
