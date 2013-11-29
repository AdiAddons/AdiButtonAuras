--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013 Adirelle (adirelle@gmail.com)
All rights reserved.

This file is part of AdiButtonAuras.

AdiButtonAuras is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

AdiButtonAuras is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with AdiButtonAuras.  If not, see <http://www.gnu.org/licenses/>.
--]]

if select(2, UnitClass("player")) ~= "MONK" then return end

-- Globals: AddRuleFor Configure IfSpell IfClass SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower SharedSimpleBuffs
-- Globals: BuildAuraHandler_Longest ImportPlayerSpells bit BuildAuraHandler_Single
-- Globals: math

AdiButtonAuras:RegisterRules(function(addon)
	addon.Debug('Rules', 'Adding mistweaver rules')

	local buff = GetSpellInfo(115151) -- Renewing Mist

	return {
		Configure {
			115151, -- Renewing Mist
			"group",
			"UNIT_AURA",
			function(units, model)
				local count, minExpiration = 0, math.huge
				for unit in pairs(units.group) do
					local name, _, _, _, _, _, expiration = UnitAura(unit, buff, nil, "HELPFUL PLAYER")
					if name then
						count, minExpiration = count + 1, min(minExpiration, expiration)
					end
				end
				if count > 0 then
					model.highlight, model.count, model.expiration = "good", count, minExpiration
				end
			end
		},
		Configure {
			116680, -- Thunder Focus Tea
			"group",
			"UNIT_AURA",
			function(units, model)
				local count, minExpiration = 0, math.huge
				for unit in pairs(units.group) do
					local name, _, _, _, _, _, expiration = UnitAura(unit, buff, nil, "HELPFUL PLAYER")
					if name then
						count, minExpiration = count + 1, min(minExpiration, expiration)
					end
				end
				if count > 3 and minExpiration < 6 then
					model.highlight, model.expiration = "flash", minExpiration
				end
			end
		},
		Configure {
			116670, -- Uplift
			"group",
			{ "UNIT_AURA", "UNIT_HEALTH", "UNIT_HEALTH_MAX" },
			function(units, model)
				-- Rough estimation at level 90
				local heal = 1.2 * ((7210+8379)/2 + 0.68 * GetSpellBonusHealing())
				local totalHeal = 0
				for unit in pairs(units.group) do
					if UnitAura(unit, buff, nil, "HELPFUL PLAYER") then
						totalHeal = totalHeal + min(heal, UnitHealthMax(unit) - UnitHealth(unit))
					end
				end
				if totalHeal >= 2 * heal then
					model.highlight = "flash"
				end
			end
		},
	}

end)
