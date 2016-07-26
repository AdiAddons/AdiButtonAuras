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

if not addon.isClass("MAGE") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding mage rules')

	local function BuildTotemHandler(slot)

	end

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
				L["Show duration for @NAME."]
			),
			116011, -- Rune of Power
			"player",
			{ "UNIT_AURA", "PLAYER_TOTEM_UPDATE" },
			(function()
				local hasRuneOfPower = BuildAuraHandler_Single("HELPFUL PLAYER", "good", "player", 116014)
				local hasTotem = function(_, model)
					local found, _, start, duration = GetTotemInfo(1) -- Arcane mages have only one totem
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
		}
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
