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

if not addon.isClass("DEATHKNIGHT") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding deathknight rules')

	local BloodCharge = GetSpellInfo(114851)

	return {
		ImportPlayerSpells {
		-- Import all spells for ...
			"DEATHKNIGHT",
		-- ... but ...
			 46584, -- Raise Dead (Unholy)
			 51124, -- Killing Machine
			 59052, -- Freezing Fog
			 81340, -- Sudden Doom
			 91342, -- Shadow Infusion
			114851, -- Blood Charge
		},
		Configure {
			"Blood Charge",
			format(L["%s when you have 5 or more stacks of %s."], DescribeHighlight("hint"), BloodCharge),
			45529, -- Blood Tap
			"player",
			"UNIT_AURA",
			function(_, model)
				local found, count = GetPlayerBuff("player", 114851) -- Blood Charge
				if found and count >= 5 then
					model.hint = true
				end
			end,
			45529, -- Provided by: Blood Tap
		},
		Configure {
			"Blood Charge Capping",
			format(L["%s when you have 10 or more stacks of %s."], DescribeHighlight("flash"), BloodCharge),
			45529, -- Blood Tap
			"player",
			"UNIT_AURA",
			function(_, model)
				local found, count = GetPlayerBuff("player", 114851) -- Blood Charge
				if found and count >= 10 then
					model.flash, model.hint = true, false
				end
			end,
			45529, -- Provided by: Blood Tap
		},
		Configure {
			"Soul Reaper",
			L["Shows a hint when the target is below 35% health."],
			{
				114866, -- Soul Reaper (Blood)
				130735, -- Soul Reaper (Frost)
				130736, -- Soul Reaper (Unholy)
			},
			"enemy",
			{ "UNIT_HEALTH", "UNIT_HEALTH_MAX" },
			function(units, model)
				if UnitHealth(units.enemy) / UnitHealthMax(units.enemy) < 0.35 then
					model.hint = true
				end
			end,
			{ 114866, 130735, 130736, },
		},
		Configure {
			"Improved Soul Reaper",
			L["Shows a hint when the target is below 45% health. (Unholy Perk)"],
			{
				130736, -- Soul Reaper (Unholy)
			},
			"enemy",
			{ "UNIT_HEALTH", "UNIT_HEALTH_MAX" },
			function(units, model)
				if UnitHealth(units.enemy) / UnitHealthMax(units.enemy) < 0.45 then
					model.hint = true
				end
			end,
			157342, -- Improved Soul Reaper
		},
		Configure {
			"Raise Dead",
			L['Suggests summoning your pet'],
			46584, -- Raise Dead
			"player",
			"UNIT_PET",
			function(units, model)
				if not HasPetSpells() then
					model.hint = true
				else
					model.highlight = "good"
				end
			end,
			46584, -- Raise Dead
		},
		Configure {
			"Outbreak",
			format(L["Show the shortest duration of %s and %s."], DescribeAllSpells(55095, 55078)), -- Frost Fever, Blood Plague
			77575, -- Outbreak
			"enemy",
			"UNIT_AURA",
			function(units, model)
				local hasFrostFever, _, ffExpiration = GetPlayerDebuff(units.enemy, 55095)
				local hasBloodPlague, _, bpExpiration = GetPlayerDebuff(units.enemy, 55078)
				if hasFrostFever and hasBloodPlague then
					model.highlight, model.count, model.expiration = "bad", 2, math.min(ffExpiration, bpExpiration)
				elseif hasFrostFever then
					model.highlight, model.expiration = "bad", ffExpiration
				elseif hasBloodPlague then
					model.highlight, model.expiration = "bad", bpExpiration
				end
			end,
		},
		Configure {
			"PlagueLeech",
			L["Suggests using Plague Leech."],
			123693, -- Plague Leech
 			"enemy",
			{"UNIT_AURA", "RUNE_POWER_UPDATE"},
			function(units, model)
				local hasFrostFever = GetPlayerDebuff(units.enemy, 55095)
				local hasBloodPlague = GetPlayerDebuff(units.enemy, 55078)
				if hasFrostFever and hasBloodPlague then
					local numDepleted = 0
					local sameTypeOnCD = 0
					for i = 1, 6 do
						local start = GetRuneCooldown(i)
						sameTypeOnCD = start > 0 and (sameTypeOnCD + 1) or sameTypeOnCD
						-- if two runes of the same type are on CD, then one is fully depleted
						numDepleted = sameTypeOnCD == 2 and (numDepleted + 1) or numDepleted
						-- reset the counter on even runes
						sameTypeOnCD = i % 2 == 0 and 0 or sameTypeOnCD

						if numDepleted >= 2 then break end
					end
					if numDepleted >= 2 then
						model.hint = true
					end
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
-- GLOBALS: print select string table tinsert GetPlayerBuff ShowStacks GetRuneCooldown
