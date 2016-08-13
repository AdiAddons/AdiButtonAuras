--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2016 Adirelle (adirelle@gmail.com)
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

if not addon.isClass("MAGE") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding mage rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			"MAGE",
			-- except
			 41425, -- Hypothermia
			 45438, -- Ice Block
			110960, -- Greater Invisibility
			113862, -- Greater Invisibility (dmg reduction)
			116014, -- Rune of Power
			199844, -- Glacial Spike!
			205022, -- Arcane Familiar
		},

		ShowPower {
			{
				 44425, -- Arcane Barrage
				114923, -- Nether Tempest
			},
			"ARCANE_CHARGES",
			5, -- an unreachable value, so that no hint is shown as the usage is situational
		},

		Configure {
			"RuneOfPower",
			format(L["%s %s"],
				BuildDesc("HELPFUL PLAYER", "good", "player", 116014), -- Rune of Power buff
				L["Show the duration of @NAME."]
			),
			116011, -- Rune of Power
			"player",
			{ "UNIT_AURA", "PLAYER_TOTEM_UPDATE" },
			(function()
				local hasRuneOfPower = BuildAuraHandler_Single("HELPFUL PLAYER", "good", "player", 116014)
				local hasTotem = function(_, model)
					local found, _, start, duration = GetTotemInfo(1) -- Rune of Power is always the first totem
					if found then
						model.highlight = "bad" -- to signify you don't have the buff you strive for
						model.expiration = start + duration
					end
				end
				return function(units, model)
					return hasRuneOfPower(units, model) or hasTotem(units, model)
				end
			end)(),
		},

		Configure {
			"ArcaneFamiliar",
			L["Show the duration of @NAME."],
			205022, -- Arcane Familiar
			"player",
			"UNIT_AURA",
			function(_, model)
				local found, _, start, duration = GetTotemInfo(4) -- Arcane Familiar is always the forth totem
				if found then
					model.highlight = "good"
					model.expiration = start + duration
				end
			end,
		},

		Configure {
			"IceBlockHypothermia",
			format(L["%s %s"],
				BuildDesc("HELPFUL PLAYER", "good", "player", 45438), -- Ice Block
				BuildDesc("HARMFUL PLAYER", "bad", "player", 41425) -- Hypothermia
			),
			45438, -- Ice Block
			"player",
			"UNIT_AURA",
			(function()
				local hasIceBlock = BuildAuraHandler_Single("HELPFUL PLAYER", "good", "player", 45438)
				local hasHypothermia = BuildAuraHandler_Single("HARMFUL PLAYER", "bad", "player", 41425)
				return function(_, model)
					return hasIceBlock(_, model) or hasHypothermia(_, model)
				end
			end)(),
		},

		Configure {
			"GreaterInvisibility",
			BuildDesc("HELPFUL PLAYER", "good", "player", 110960), -- Greater Invisibility
			110959, -- Greater Invisibility
			"player",
			"UNIT_AURA",
			(function()
				local isInvisible = BuildAuraHandler_Single("HELPFUL PLAYER", "good", "player", 110960)
				local hasDmgReduction = BuildAuraHandler_Single("HELPFUL PLAYER", "good", "player", 113862)
				return function(_, model)
					return isInvisible(_, model) or hasDmgReduction(_, model)
				end
			end)(),
		},
		-- Suggest using Fire Blast when you have Heating Up
		Configure {
			"HeatingUp",
			BuildDesc("HELPFUL PLAYER", "hint", "player", 48107), -- Heating Up
			108853, -- Fire Blast
			"player",
			"UNIT_AURA",
			function(_, model)
				local found, _, expiration = GetPlayerBuff("player", 48107) -- Heating Up
				if found then
					model.expiration = expiration
					model.hint = true
				end
			end,
			195283, -- Hot Streak (passive provider)
		},
		-- Suggest using Frostbolt when Water Jet in on the target
		Configure {
			"WaterJetFrostbolt",
			BuildDesc("HARMFUL PLAYER", "hint", "enemy", 135029), -- Water Jet
			116, -- Frostbolt
			"enemy",
			"UNIT_AURA",
			function(units, model)
				local found = GetPlayerDebuff(units.enemy, 135029) -- Water Jet
				if found then
					model.hint = true
				end
			end,
			135029, -- Water Jet
		},

		ShowStacks {
			199786, -- on Glacial Spikes
			205473, -- the stacks of Icicles
			5, -- max
		}
	}
end)

-- ABA
-- GLOBALS: AddRuleFor BuffAliases BuildAuraHandler_FirstOf BuildAuraHandler_Longest
-- GLOBALS: BuildAuraHandler_Single BuildDesc BuildKey Configure DebuffAliases Debug
-- GLOBALS: DescribeAllSpells DescribeAllTokens DescribeFilter DescribeHighlight
-- GLOBALS: DescribeLPSSource GetBuff GetDebuff GetLib GetPlayerBuff GetPlayerDebuff
-- GLOBALS: ImportPlayerSpells IterateBuffs IterateDebuffs IteratePlayerBuffs
-- GLOBALS: IteratePlayerDebuffs L LongestDebuffOf PassiveModifier PetBuffs PLAYER_CLASS
-- GLOBALS: SelfBuffAliases SelfBuffs SharedSimpleBuffs SharedSimpleDebuffs ShowPower
-- GLOBALS: ShowStacks SimpleBuffs SimpleDebuffs

-- WoW API
-- GLOBALS: GetNumGroupMembers GetPetTimeRemaining GetRuneCooldown GetShapeshiftFormID
-- GLOBALS: GetSpellCharges GetSpellBonusHealing GetSpellInfo GetTime GetTotemInfo
-- GLOBALS: HasPetSpells IsPlayerSpell UnitCanAttack UnitCastingInfo UnitChannelInfo
-- GLOBALS: UnitClass UnitHealth UnitHealthMax UnitIsDeadOrGhost UnitIsPlayer UnitName
-- GLOBALS: UnitPower UnitPowerMax UnitStagger

-- Lua API
-- GLOBALS: bit ceil floor format ipairs math min pairs print select string table
-- GLOBALS: tinsert type
