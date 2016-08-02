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

if not addon.isClass("PRIEST") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding priest rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			"PRIEST",
			-- except
			193223, -- Surrender to Madness
			194384, -- Atonement
			210027, -- Share in the Light (not game changing)
			212570, -- Surrendered Soul
			217673, -- Mind Spike
		},

		BuffAliases {
			{
				194509, -- Power Word: Radiance
				200829, -- Plea
			},
			194384
		},

		Configure {
			"Silence",
			format(L["%s when %s is casting/channelling a spell that you can interrupt."],
				DescribeHighlight("flash"),
				DescribeAllTokens("enemy")
			),
			15487, -- Silence
			"enemy",
			{ -- Events
				"UNIT_SPELLCAST_CHANNEL_START",
				"UNIT_SPELLCAST_CHANNEL_STOP",
				"UNIT_SPELLCAST_CHANNEL_UPDATE",
				"UNIT_SPELLCAST_DELAYED",
				"UNIT_SPELLCAST_INTERRUPTIBLE",
				"UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
				"UNIT_SPELLCAST_START",
				"UNIT_SPELLCAST_STOP",
			},
			-- Handler
			function(units, model)
				local unit = units.enemy
				if unit and UnitCanAttack("player", unit) and not UnitIsPlayer(unit) then
					local name, _, _, _, _, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
					if name and not notInterruptible then
						model.flash, model.expiration = true, endTime / 1000
						return
					end
					name, _, _, _, _, endTime, _, notInterruptible = UnitChannelInfo(unit)
					if name and not notInterruptible then
						model.flash, model.expiration = true, endTime / 1000
					end
				end
			end,
		},

		Configure {
			"MindSpike",
			BuildDesc("HARMFUL PLAYER", "bad", "enemy", 217673), -- Mind Spike
			8092, -- Mind Blast
			"enemy",
			"UNIT_AURA",
			function(units, model)
				local found, count, expiration = GetPlayerDebuff(units.enemy, 217673) -- Mind Spike
				if found then
					model.count = count
					model.maxCount = 10
					model.expiration = expiration
					model.highlight = "bad"
				end
			end,
			73510, -- Mind Spike
		},

		Configure {
			"SurrenderToMadness",
			format(L["%s %s"],
				BuildDesc("HELPFUL PLAYER", "good", "player", 193223), -- Surrender to Madness
				BuildDesc("HARMFUL PLAYER", "bad", "player", 212570) -- Surrendered Soul
			),
			193223, -- Surrender to Madness
			"player",
			"UNIT_AURA",
			(function()
				local hasMadness = BuildAuraHandler_Single("HELPFUL PLAYER", "good", "player", 193223) -- Surrender to Madness
				local hasNoSoul = BuildAuraHandler_Single("HARMFUL PLAYER", "bad", "player", 212570) -- Surrendered Soul
				return function(_, model)
					return hasMadness(_, model) or hasNoSoul(_, model)
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
-- GLOBALS: print select string table tinsert GetPlayerBuff GetPlayerDebuff ShowStacks
