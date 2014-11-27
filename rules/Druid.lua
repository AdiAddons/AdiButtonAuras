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

	-- GLOBALS: SPELL_POWER_ECLIPSE

	return {
		ImportPlayerSpells {
			-- Import all spells for ...
			"DRUID",
			-- ... but ...
			  5217, -- Tiger's Fury
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
			L["Show combo points."],
			{
				  1079, -- Rip
				 22568, -- Ferocious Bite
				 22570, -- Maim
				 52610, -- Savage Roar
			},
			{ "enemy", "player" },
			"UNIT_COMBO_POINTS",
			function(units, model)
				if not units.enemy then return end
				local points = GetComboPoints("player", units.enemy)
				if points and points > 0 then
					model.count = points
					return true
				end
			end,
		},
		Configure {
			"ComboPointsFlash",
			format(L["%s at 5 combo points."], DescribeHighlight("flash")),
			{
				  1079, -- Rip
				 22568, -- Ferocious Bite
				 22570, -- Maim
				 52610, -- Savage Roar
			},
			{ "enemy", "player" },
			"UNIT_COMBO_POINTS",
			function(units, model)
				if units.enemy and GetComboPoints("player", units.enemy) == 5 then
					model.highlight = "flash"
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
			},
			"player",
			"UNIT_AURA",
			function(_, model)
				if not GetPlayerBuff("player", 100977) then
					model.hint = true
				end
			end,
			77495, -- Provided by: Mastery: Harmony
		},
		Configure {
			"LunarEnergy",
			format(L["Show %s."], L["lunar energy"]),
			5176, -- Wrath
			"player",
			"UNIT_POWER_FREQUENT",
			function(units, model)
				local power = UnitPower("player", SPELL_POWER_ECLIPSE)
				if power > 0 then
					model.count = power
				end
			end,
			79577, -- Provided by: Eclipse (passive)
		},
		Configure {
			"SolarEnergy",
			format(L["Show %s."], L["solar energy"]),
			2912, -- Starfire
			"player",
			"UNIT_POWER_FREQUENT",
			function(units, model)
				local power = UnitPower("player", SPELL_POWER_ECLIPSE)
				if power < 0 then
					model.count = -power
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
		BuffAliases { -- Always show Tiger's Fury Buff even when 'darkened'
			5217,
			5217,
		},
		Configure {
			"GlyphOfRejuvenation",
			L["Suggests to cast Rejuvenation to enable Glyph of Rejuvenation effect."],
			  774, -- Rejuvenation
			"player",
			"UNIT_AURA",
			function(_, model)
				if not GetPlayerBuff("player", 96206) then -- Glyph of Rejuvenation buff
					model.hint = true
				end
			end,
			17076, -- Glyph of Rejuvenation
		},
	}

end)

-- GLOBALS: AddRuleFor BuffAliases BuildAuraHandler_FirstOf BuildAuraHandler_Longest
-- GLOBALS: BuildAuraHandler_Single BuildDesc BuildKey Configure DebuffAliases Debug
-- GLOBALS: DescribeAllSpells DescribeAllTokens DescribeFilter DescribeHighlight
-- GLOBALS: DescribeLPSSource GetComboPoints GetEclipseDirection GetNumGroupMembers
-- GLOBALS: GetShapeshiftFormID GetSpellBonusHealing GetSpellInfo GetTime
-- GLOBALS: GetTotemInfo HasPetSpells ImportPlayerSpells L LongestDebuffOf
-- GLOBALS: PLAYER_CLASS PassiveModifier PetBuffs SelfBuffAliases SelfBuffs
-- GLOBALS: SharedSimpleBuffs SharedSimpleDebuffs ShowPower SimpleBuffs
-- GLOBALS: SimpleDebuffs UnitCanAttack UnitCastingInfo UnitChannelInfo UnitClass
-- GLOBALS: UnitHealth UnitHealthMax UnitIsDeadOrGhost UnitIsPlayer UnitPower
-- GLOBALS: UnitPowerMax UnitStagger bit ceil floor format ipairs math min pairs
-- GLOBALS: print select string table tinsert GetPlayerBuff
