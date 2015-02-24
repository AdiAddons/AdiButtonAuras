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
			   774, -- Rejuvenation
			  5217, -- Tiger's Fury
			 16974, -- Predatory Swiftness (passive)
			114108, -- Soul of the Forest (restoration)
			145518, -- Genesis
			155777, -- Rejuvenation (Germination)
		},
		BuffAliases {
			145518, -- Genesis
			   774, -- Rejuvenation
		},
		PassiveModifier {
			114107, -- Soul of the Forest
			 18562, -- Swiftmend
			114108, -- Soul of the Forest (restoration)
			"player",
			"flash"
		},
		ShowPower {
			{
				  1079, -- Rip
				 22568, -- Ferocious Bite
				 22570, -- Maim
				 52610, -- Savage Roar
			},
			"COMBO"
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
		Configure {
			"RestoWildMushroom",
			L["Shows duration for Wild Mushroom (Restoration)."],
			{
				145205, -- Wild Mushroom (Restoration)
				147349, -- Wild Mushroom (Restoration) with Glyph of the Sprouting Mushroom (id:146654)
			},
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(_, model)
				local hasShroom, _, startTime, duration = GetTotemInfo(1) -- only one shroom at a time
				if hasShroom then
					model.highlight = "good"
					model.expiration = startTime + duration
				end
			end,
			145205 -- Wild Mushroom (Restoration)
		},
		Configure {
			"Germination",
			format(L["Show the shortest duration of %s and %s."], DescribeAllSpells(774, 155777)), -- Rejuvenation & Rejuvenation
			774, -- Rejuvenation
			"ally",
			"UNIT_AURA",
			function(units, model)
				local rejuvFound, _, rejuvExpiration = GetPlayerBuff(units.ally, 774) -- Rejuvenation
				local germFound, _, germExpiration = GetPlayerBuff(units.ally, 155777) -- Rejuvenation (Germination)
				if rejuvFound and germFound then
					model.highlight, model.count, model.expiration = "good", 2, math.min(rejuvExpiration, germExpiration)
				elseif rejuvFound then
					model.highlight, model.expiration = "good", rejuvExpiration
				elseif germFound then
					model.highlight, model.expiration = "good", germExpiration
				end
			end,
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
