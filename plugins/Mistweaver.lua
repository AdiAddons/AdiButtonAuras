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

AdiButtonAuras_RegisterRules(function(addon)
	addon.Debug('Rules', 'Adding mistweaver rules')

	local buff = GetSpellInfo(115151) -- Renewing Mist

	return {
		Configure {
			115151, -- Renewing Mist
			"group",
			{ "UNIT_AURA", "GROUP_ROSTER_UPDATE" },
			function(units, model)
				local count, minExpiration = 0
				for unit in pairs(units.group) do
					local name, _, _, _, _, _, expiration = UnitAura(unit, buff, nil, "HELPFUL PLAYER")
					if name then
						count = count + 1
						if not minExpiration or expiration < minExpiration then
							minExpiration = expiration
						end
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
			{ "UNIT_AURA", "GROUP_ROSTER_UPDATE" },
			function(units, model)
				local limit, count = GetTime() + 6, 0
				for unit in pairs(units.group) do
					local name, _, _, _, _, _, expiration = UnitAura(unit, buff, nil, "HELPFUL PLAYER")
					if name and expiration < limit then
						count = count + 1
					end
				end
				if count >= 3 then
					model.highlight = "flash"
				end
			end
		},
		Configure {
			116670, -- Uplift
			"group",
			{ "UNIT_AURA", "UNIT_HEALTH", "UNIT_HEALTH_MAX", "GROUP_ROSTER_UPDATE" },
			function(_, model)
				local count = 0
				for unit in pairs(units.group) do
					if UnitAura(unit, buff, nil, "HELPFUL PLAYER") and UnitHealth(unit) / UnitHealthMax() < 0.8 then
						count = count + 1
					end
				end
				if count >= 3 then
					model.highlight = "flash"
				end
			end
		},
	}

end)
