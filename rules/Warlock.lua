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

if not addon.isClass("WARLOCK") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding warlock rules')

	-- GLOBALS: SPELL_POWER_BURNING_EMBERS

	return {
		ImportPlayerSpells {
			-- Import all spells for ...
			"WARLOCK",
			-- ... but ...
			 80240, -- Havoc
			103958, -- Metamorphosis
		},
		ShowPower {
			{
				 17877, -- Shadowburn
				108683, -- Fire and Brimstone
				108685, -- Conflagrate (Fire and Brimstone)
				108686, -- Immolate (Fire and Brimstone)
				114635, -- Ember Tap
				114654, -- Incinerate (Fire and Brimstone)
			},
			"BURNING_EMBERS",
		},
		ShowPower {
			116858, -- Chaos Bolt
			"BURNING_EMBERS",
			3,
			"hint"
		},
		ShowPower {
			74434, -- Soulburn
			"SOUL_SHARDS",
		},
		ShowPower {
			103958, -- Metamorphosis
			"DEMONIC_FURY",
		},
		Configure {
			"Backdraft",
			format(L["%s when you have 3 or more stacks of %s."], DescribeHighlight("good"), GetSpellInfo(117828)),
			116858, -- Chaos Bolt
			"player",
			"UNIT_AURA",
			function(_, model)
				local found, count, expiration = GetPlayerBuff("player", 117828)
				if found and count >= 3 then
					model.highlight = "good"
					model.expiration = expiration
				end
			end,
			117896, -- Provided by: Backdraft (Passive)
		},
		Configure {
			"Havoc",
			format(
				L["%s Else %s"],
				BuildDesc("HARMFUL PLAYER", "bad", "enemy", 80240),
				BuildDesc("HELPFUL PLAYER", "good", "player", 80240)
			),
			80240, -- Havoc
			{ "player", "enemy" },
			"UNIT_AURA",
			(function()
				local selfHavoc = BuildAuraHandler_Single("HELPFUL PLAYER", "good", "player", 80240)
				local enemyHavoc = BuildAuraHandler_Single("HARMFUL PLAYER", "bad", "enemy", 80240)
				return function(units, model)
					return selfHavoc(units, model) and enemyHavoc(units, model)
				end
			end)()
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
-- GLOBALS: print select string table tinsert GetPlayerBuff ShowStacks
