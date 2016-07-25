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

if not addon.isClass("PALADIN") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding paladin rules')

	local function ShortenHealth(value)
		if (value >= 1e6) then
			return math.floor(value / 1e6 + .5)
		elseif (value >= 1e4) then
			return math.floor(value / 1e3 + .5)
		else
			return value
		end
	end

	return {
		ImportPlayerSpells {
			-- import all spells for
			"PALADIN",
			-- except
			  633, -- Lay on Hands
			  642, -- Devine Shield
			 1022, -- Blessing of Protection
			25771, -- Forbearance
		},
		ShowPower {
			{
				 53385, -- Devine Storm
				 85256, -- Templar's Verdict
				202273, -- Seal of Light
				210191, -- Word of Glory
				213757, -- Execution Sentence
				215661, -- Judicar's Vengeance
			},
			"HOLY_POWER",
		},
		Configure {
			"DevineShield",
			format(L["%s %s"],
				BuildDesc("HELPFUL PLAYER", "good", "player", 642), -- Devine Shield
				BuildDesc("HARMFUL", "bad", "player", 25771) -- Forbearance
			),
		 	642, -- Devine Shield
			"player",
			"UNIT_AURA",
			(function()
				local hasForbearance = BuildAuraHandler_Single("HARMFUL", "bad", "player", 25771)
				local hasDevineShield = BuildAuraHandler_Single("HELPFUL", "good", "player", 642)
				return function(units, model)
					return hasDevineShield(units, model) or hasForbearance(units, model)
				end
			end)(),
		},
		Configure {
			"BlessingOfProtection",
			format(L["%s %s"],
				BuildDesc("HELPFUL", "good", "ally", 1022), -- Blessing of Protection
				BuildDesc("HARMFUL", "bad", "ally", 25771) -- Forbearance
			),
		 	1022, -- Blessing of Protection
			"ally",
			"UNIT_AURA",
			(function()
				local hasForbearance = BuildAuraHandler_Single("HARMFUL", "bad", "ally", 25771)
				local hasBlessingOfProtection = BuildAuraHandler_Single("HELPFUL", "good", "ally", 1022)
				return function(units, model)
					return hasBlessingOfProtection(units, model) or hasForbearance(units, model)
				end
			end)(),
		},
		Configure {
			"LayOnHands",
			BuildDesc("HARMFUL", "bad", "ally", 25771),
		 	633, -- Blessing of Protection
			"ally",
			"UNIT_AURA",
			(function()
				local hasForbearance = BuildAuraHandler_Single("HARMFUL", "bad", "ally", 25771)
				return function(units, model)
					return hasForbearance(units, model)
				end
			end)(),
		},
		Configure {
			"GreaterBlessings",
			format(L["Show the number of Greater Blessings placed on group members."]),
			{
				203528, -- Greater Blessing of Might
				203538, -- Greater Blessing of Kings
				203539, -- Greater Blessing of Wisdom
			},
			"group",
			"UNIT_AURA",
			function(units, model)
				local count = 0
				model.maxCount = 3
				for unit in pairs(units.group) do
					count = GetPlayerBuff(unit, 203528) and count + 1 or count
					count = GetPlayerBuff(unit, 203538) and count + 1 or count
					count = GetPlayerBuff(unit, 203539) and count + 1 or count
				end
				if count > 0 then
					model.count = count
				end
			end,
		},
		Configure {
			"HolyWrath",
			L["Show your missing health."],
			210220, -- Holy Wrath
			"player",
			{ "UNIT_HEALTH", "UNIT_MAXHEALTH" },
			function(_, model)
				local missingHealth = UnitHealthMax("player") - UnitHealth("player")
				if missingHealth > 0 then
					model.count = ShortenHealth(missingHealth)
				else
					model.highlight = "darken"
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
-- GLOBALS: print select string table tinsert GetPlayerBuff ShowStacks
