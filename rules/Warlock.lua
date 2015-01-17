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
			  6353, -- Soul Fire
			104027, -- Soul Fire (metamorphosis)
			103958, -- Metamorphosis
		},
		ShowPower {
			{
				17877,  -- Shadowburn
				114635, -- Ember Tap
				108683, -- Fire and Brimstone
				116858, -- Chaos Bolt
			},
			"BURNING_EMBERS",
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
			"Pyroclasm",
			format(L["%s when you have 3 or more stacks of %s."], DescribeHighlight("good"), GetSpellInfo(117828)),
			116858, -- Chaos Bolt
			"player",
			"UNIT_AURA",
			function(_, model)
				local found, count = GetPlayerBuff("player", 117828)
				if found and count >= 3 then
					model.highlight = "good"
				end
			end,
			123686, -- Provided by: Pyroclasm
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
		Configure {
			"HavocHint",
			L["Suggest using Havoc when it is available."],
			80240,
			"player",
			"UNIT_AURA",
			function(_, model)
				if not GetPlayerBuff("player", 80240) then
					model.hint = true
				end
			end
		},
		Configure {
			"MoltenCore",
			L["Show Molten Core expiry on Soul Fire, hint on 5+ stacks"],
			{6353, 104027},
			"player",
			"UNIT_AURA",
			(function()
				local hasMoltenCore = BuildAuraHandler_FirstOf("HELPFUL PLAYER", nil, "player", {122355, 140074})
				return function(units, model)
					if hasMoltenCore(units, model) then
						if model.count >= 5 then
							model.hint = true
						end
					end
				end
			end)()
		},
		Configure {
			"Chaos Bolt",
			L["Highlight Chaos Bolt when at 3+ Burning Embers, hint at max"],
			116858,
			"player",
			"UNIT_POWER",
			function(_, model)
				local embers = UnitPower("player", SPELL_POWER_BURNING_EMBERS)
				if embers >= 3 then
					model.flash = true
				end
				if embers >= 4 then
					model.hint = true
				end
			end
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
