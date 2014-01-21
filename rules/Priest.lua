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

if select(2, UnitClass("player")) ~= "PRIEST" then return end

local addonName, addon = ...

-- Globals: AddRuleFor Configure SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower SharedSimpleBuffs
-- Globals: BuildAuraHandler_Longest ImportPlayerSpells bit BuildAuraHandler_Single
-- Globals: math

AdiButtonAuras:RegisterRules(function(addon)
	addon.Debug('Rules', 'Adding priest rules')
	return {
		ImportPlayerSpells {
			-- Import all spells for ...
			"PRIEST",
			-- ... but ...
			   17, -- Power Word: Shield
			81661, -- Evangelism
		},
		ShowPower {
			{
				 2944, -- Devouring Plague
				64044, -- Psychic Horror
			},
			"SHADOW_ORBS",
		},
		Configure {
			"PWShield",
			addon.L["Show Power Word: Shield or Weakened Soul on targeted ally."],
			17, -- Power Word: Shield
			"ally",
			"UNIT_AURA",
			(function()
				local hasPWShield = BuildAuraHandler_Single("HELPFUL", "good", "ally", 17)
				local hasWeakenedSoul = BuildAuraHandler_Single("HARMFUL", "bad", "ally", 6788)
				return function(units, model)
					return hasPWShield(units, model) or hasWeakenedSoul(units, model)
				end
			end)(),
		},
		Configure {
			"Archangel",
			addon.BuildDesc("HELPFUL PLAYER", nil, "player", 81661),
			81700, -- Archangel
			"player",
			"UNIT_AURA",
			(function()
				local hasEvangelism = BuildAuraHandler_Single("HELPFUL PLAYER", nil, "player", 6788)
				local proxy = {} -- Local model
				return function(units, model)
					if hasEvangelism(units, proxy) then
						model.count = proxy.count
						if proxy.expiration - GetTime() < 5 then
							model.hint = true
						end
					end
				end
			end)(),
			81661, -- Evangelism
		},
	}
end)
