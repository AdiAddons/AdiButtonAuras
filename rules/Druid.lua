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

if select(2, UnitClass("player")) ~= "DRUID" then return end

-- Globals: AddRuleFor Configure IfSpell SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower SharedSimpleBuffs
-- Globals: BuildAuraHandler_Longest ImportPlayerSpells bit BuildAuraHandler_Single
-- Globals: math

AdiButtonAuras:RegisterRules(function(addon)
	addon.Debug('Rules', 'Adding druid rules')
	
	local L = addon.L

	return {
		ImportPlayerSpells {
			-- Import all spells for ...
			"DRUID",
			-- ... but ...
			 50464, -- Nourish
			145518, -- Genesis
			 16870, -- Clearcasting
			114108, -- Soul of the Forest (restoration)
			 16974, -- Predatory Swiftness (passive)
		},
		BuffAliases {
			50464, -- Nourish
			96206, -- Glyph of Rejuvenation
		},
		BuffAliases {
			145518, -- Genesis
			   774, -- Rejuvenation
		},
		PassiveModifier {
			113043, -- Omen of Clarity
			{
				8936, -- Regrowth
				5176, -- Wrath
				5185, -- Healing Touch
			},
			16870, -- Clearcasting
			"player",
			"flash"
		},
		PassiveModifier {
			114107, -- Soul of the Forest
			 18562, -- Swiftmend
			114108, -- Soul of the Forest (restoration)
			"player",
			"flash"
		},
		Configure {
			"ComboPoints",
			format(
				addon.L["Show %s and %s when it reaches its maximum."],
				addon.L["combo points"],
				addon.DescribeHighlight("flash")
			),
			{
				  1079, -- Rip
				 22568, -- Ferocious Bite
				 22570, -- Maim
				 52610, -- Savage Roar
				127538, -- Savage Roar (glyphed)
			},
			{ "enemy", "player" },
			"UNIT_COMBO_POINTS",
			function(units, model)
				if not units.enemy then return end
				local points = GetComboPoints("player", units.enemy)
				if points and points > 0 then
					model.count = points or 0
					if points == 5 then
						model.highlight = "flash"
					end
					return true
				end
			end,
		},
		IfSpell { 77495, -- Mastery: Harmony
			Configure {
				"Harmony",
				L['Flash when mastery is inactive.'],
				50464, -- Nourish
				"player",
				{ "UNIT_AURA", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED" },
				(function()
					local harmonyBuff = GetSpellInfo(100977) -- Harmony
					return function(units, model)
						if InCombatLockdown() and not UnitAura("player", harmonyBuff, nil, "HELPFUL PLAYER") then
							model.highlight = "flash"
							return true
						end
					end
				end)()
			},
		},
		IfSpell { 79577, -- Eclipse (passive)
			Configure {
				"LunarEnergy",
				format(L["Show %s."], L["lunar energy"]),
				5176, -- Wrath
				"player",
				{ "UNIT_POWER_FREQUENT", "ECLIPSE_DIRECTION_CHANGE" },
				function(units, model)
					if GetEclipseDirection() ~= "sun" then
						model.highlight = "lighten"
						model.count = -UnitPower("player", SPELL_POWER_ECLIPSE)
					else
						model.highlight = "darken"
					end
				end,
			},
			Configure {
				"SolarEnergy",
				format(L["Show %s."], L["solar energy"]),
				2912, -- Starfire
				"player",
				{ "UNIT_POWER_FREQUENT", "ECLIPSE_DIRECTION_CHANGE" },
				function(units, model)
					if GetEclipseDirection() ~= "moon" then
						model.highlight = "lighten"
						model.count = UnitPower("player", SPELL_POWER_ECLIPSE)
					else
						model.highlight = "darken"
					end
				end,
			}
		},
		PassiveModifier {
			16864, -- Omen of Clarity
			{
				5221, -- Shred
			},
			16870, -- Clearcasting
			"player",
			"flash"
		},
		PassiveModifier {
			16974, -- Predatory Swiftness (passive)
			{
				 5185, -- Healing Touch
				 2637, -- Hibernate
				20484, -- Rebirth
			},
			69369, -- Predatory Swiftness (buff)
			"player",
			"flash"
		},
		ShowPower {
			5217, -- Tiger's Fury
			"ENERGY",
			35,
			"darken"
		},
	}

end)
