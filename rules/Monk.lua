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

if not addon.isClass("MONK") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding monk rules')

	-- GLOBALS: STAGGER_YELLOW_TRANSITION SPELL_POWER_MANA

	-- Mistweaver constants
	local TFT_COUNT    = 4 -- Minimum number of Renewing Mist to highlight Thunder Focus Tea
	local TFT_DURATION = 6 -- Duration threshold to highlight Thunder Focus Tea
	local UPLIFT_THRESHOLD = 3 -- Heal multiplier to highlight Uplight

	return {
		ImportPlayerSpells {
			-- Import all spells for ...
			"MONK",
			-- ... but ...
			115151, -- Renewing Mist
			115294, -- Mana Tea
			116670, -- Uplift
			116680, -- Thunder Focus Tea
			119582, -- Purifying Brew
			123273, -- Surging Mist
			123761, -- Mana Tea (glyphed)
			125195, -- Tigereye Brew (stacking buff)
			128939, -- Elusive Brew (stacking buff)
			134563, -- Healing Elixirs (buff)
		},
		ShowPower {
			-- Show current Chi on spenders and flash when reaching maximum
			{
				100784, -- Blackout Kick
				107428, -- Rising Sun Kick
				113656, -- Fists of Fury
				115181, -- Breath of Fire
				116670, -- Uplift
				124682, -- Enveloping Mist
				157675, -- Chi Explosion (Mistweaver)
				157676, -- Chi Explosion (Brewmaster)
				152174, -- Chi Explosion (Windwalker)
			},
			"CHI"
		},
		Configure {
			"HealingElixirs",
			BuildDesc("HELPFUL PLAYER", "good", "player", 122280),
			{
				115203, -- Fortifying Brew
				115288, -- Energizing Brew
				115294, -- Mana Tea
				115308, -- Elusive Brew
				115399, -- Chi Brew
				116680, -- Thunder Focus Tea
				116740, -- Tigereye Brew
				119582, -- Purifying Brew
				137562, -- Nimble Brew
			},
			"player",
			"UNIT_AURA",
			function(units, model)
				if GetPlayerBuff("player", 134563) then -- Healing Elixirs (buff)
					model.highlight = "good"
				end
			end,
			122280, -- Provided by: healing Elixirs (passive)
		},
		Configure {
			"PurifyingBrew",
			format(L["Show %s."], L["stagger level"]),
			119582, -- Purifying Brew
			"player",
			{ "UNIT_AURA", "UNIT_HEALTH_MAX" },
			(function()
				local STANCE_OF_THE_STURY_OX_ID = 23
				local STAGGER_YELLOW_TRANSITION = STAGGER_YELLOW_TRANSITION
				return function(units, model)
					local stagger = GetShapeshiftFormID() == STANCE_OF_THE_STURY_OX_ID and UnitStagger("player")
					if stagger then
						local percent = stagger / UnitHealthMax("player")
						model.count = ceil(percent * 100)
						if percent >= STAGGER_YELLOW_TRANSITION then
							model.hint = true
						end
					end
				end
			end)(),
		},
		Configure {
			"ManaTea",
			L["Suggest using @NAME under 92% mana."],
			123761, -- Mana Tea (glyphed)
			"player",
			{ "UNIT_AURA", "UNIT_POWER", "UNIT_POWER_MAX" },
			function(_, model)
				local found, count, expiration = GetPlayerBuff("player", 115867) -- Mana Tea (stacking buff)
				if found then
					model.expiration = expiration
					if count >= 2 and UnitPower("player", SPELL_POWER_MANA) / UnitPowerMax("player", SPELL_POWER_MANA) <= 0.92 then
						model.hint = true
					end
				end
			end
		},
		Configure {
			"RenewingMist",
			L["Show the number of group member affected by @NAME and the shortest duration."],
			115151, -- Renewing Mist
			"group",
			"UNIT_AURA",
			function(units, model)
				local count, minExpiration = 0, math.huge
				for unit in pairs(units.group) do
					local found, _, expiration = GetPlayerBuff(unit, 115151)
					if found then
						count, minExpiration = count + 1, min(minExpiration, expiration)
					end
				end
				if count > 0 then
					model.highlight, model.count, model.expiration = "good", count, minExpiration
				end
				if count < 4 and GetNumGroupMembers() >= 5 then
					model.hint = true
				end
			end
		},
		Configure {
			"Uplift",
			format(L["Suggest when total effective healing would be at least %d times the base healing."], UPLIFT_THRESHOLD),
			116670, -- Uplift
			"group",
			{ "UNIT_AURA", "UNIT_HEALTH", "UNIT_HEALTH_MAX" },
			function(units, model)
				-- Rough estimation at level 90
				local heal = 1.2 * ((7210+8379)/2 + 0.68 * GetSpellBonusHealing())
				local totalHeal = 0
				for unit in pairs(units.group) do
					if GetPlayerBuff(unit, 115151) then -- Renewing Mist
						totalHeal = totalHeal + min(heal, UnitHealthMax(unit) - UnitHealth(unit))
					end
				end
				if totalHeal >= UPLIFT_THRESHOLD * heal then
					model.hint = true
				end
			end
		},
		Configure {
			"StatueTimer",
			L["Show good border and remaining time of your summoned statue."],
			{
				115313, -- Summon Jade Serpent Statue
				115315, -- Summon Black Ox Statue
			},
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(units, model)
				local found, _, startTime, duration = GetTotemInfo(1)
				if found then
					model.highlight, model.expiration = "good", startTime + duration
				end
			end,
		},
		Configure {
			"StatueHint",
			L["Suggests to summon your statue."],
			{
				115313, -- Summon Jade Serpent Statue
				115315, -- Summon Black Ox Statue
			},
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(units, model)
				if not GetTotemInfo(1) then
					model.hint = true
				end
			end,
		},
		Configure {
			"DesperateMeasures",
			L["Show hint when your health is below 35%."],
			115072, -- Expel Harm
			"player",
			{ "UNIT_HEALTH_FREQUENT", "UNIT_HEALTH_MAX" },
			function(_, model)
				if UnitHealth("player") / UnitHealthMax("player") < 0.35 then
					model.hint = true
				end
			end,
			126060, -- Desperate Measures
		},
		ShowStacks {
			115308, -- Elusive Brew
			128939, -- Elusive Brew (stacking buff)
			20, -- 20 stacks max
			"player",
			10 -- highlight at 10 stacks,
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
