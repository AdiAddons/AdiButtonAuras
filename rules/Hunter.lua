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

if not addon.isClass("HUNTER") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding hunter rules')

	return {
		ImportPlayerSpells { "HUNTER" },
		Configure {
			"Call Pet",
			L['Suggests summoning a pet'],
			{
				883,      -- Call Pet 1
				-- 83242, -- Call Pet 2
				-- 83243, -- Call Pet 3
				-- 83244, -- Call Pet 4
				-- 83245, -- Call Pet 5
			},
			"player",
			"UNIT_PET",
			function(units, model)
				if not HasPetSpells() then
					if not IsPlayerSpell(155228) then -- Lone Wolf
						model.hint = true
					end
				else
					model.highlight = "good"
				end
			end,
			883, -- Requires Call Pet
		},
		Configure {
			"Exotic Munitions",
			L["Suggest using your exotic munitions."],
			{
				162536, -- Incendiary Ammo
				162537, -- Poisoned Ammo
				162539, -- Frozen Ammo
			},
			"player",
			"UNIT_AURA",
			function(units, model)
				if not GetPlayerBuff("player", 162536) and
					not GetPlayerBuff("player", 162537) and
					not GetPlayerBuff("player", 162539)
				then
					model.hint = true
				end
			end
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
-- GLOBALS: print select string table tinsert GetPlayerBuff IsPlayerSpell ShowStacks
