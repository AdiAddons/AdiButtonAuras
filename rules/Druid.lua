--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2014 Adirelle (adirelle@gmail.com)
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

local _, addon = ...

if not addon.isClass("DRUID") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Rules', 'Adding druid rules')

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
				L["Show %s and %s when it reaches its maximum."],
				L["combo points"],
				DescribeHighlight("flash")
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
		Configure {
			"Harmony",
			L['Suggests when mastery is inactive.'],
			{
				 5185, -- Healing Touch
				 8936, -- Regrowth
				18562, -- Swiftmend
				50464, -- Nourish
			},
			"player",
			"UNIT_AURA",
			(function()
				local harmonyBuff = GetSpellInfo(100977) -- Harmony
				return function(_, model)
					if not UnitAura("player", harmonyBuff, nil, "HELPFUL PLAYER") then
						model.hint = true
					end
				end
			end)(),
			77495, -- Provided by: Mastery: Harmony
		},
		Configure {
			"LunarEnergy",
			format(L["Show %s."], L["lunar energy"]),
			5176, -- Wrath
			"player",
			{ "UNIT_POWER_FREQUENT", "ECLIPSE_DIRECTION_CHANGE" },
			function(units, model)
				if GetEclipseDirection() == "moon" then
					model.hint = true
					model.count = -UnitPower("player", SPELL_POWER_ECLIPSE)
				end
			end,
			79577, -- Provided by: Eclipse (passive)
		},
		Configure {
			"SolarEnergy",
			format(L["Show %s."], L["solar energy"]),
			2912, -- Starfire
			"player",
			{ "UNIT_POWER_FREQUENT", "ECLIPSE_DIRECTION_CHANGE" },
			function(units, model)
				if GetEclipseDirection() == "sun" then
					model.hint = true
					model.count = UnitPower("player", SPELL_POWER_ECLIPSE)
				end
			end,
			79577, -- Provided by: Eclipse (passive)
		},
		PassiveModifier {
			16864, -- Omen of Clarity
			{
				5221, -- Shred
                5185, -- Healing Touch
			},
			135700, -- Clearcasting
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
		Configure {
			"GlyphOfRejuvenation",
			L["Suggests to cast Rejuvenation to enable Glyph of Rejuvenation effect."],
			  774, -- Rejuvenation
			"player",
			"UNIT_AURA",
			(function()
				local buffName = GetSpellInfo(96206) -- Glyph of Rejuvenation
				return function(units, model)
					if not UnitAura("player", buffName, nil, "HELPFUL PLAYER") then
						model.hint = true
					end
				end
			end)(),
			17076, -- Glyph of Rejuvenation
		},
	}

end)
