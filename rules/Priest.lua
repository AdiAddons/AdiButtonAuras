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
			-- Import all spells for ...
			"PRIEST",
			-- ... but ...
			   17, -- Power Word: Shield
			81661, -- Evangelism
		},
		ShowPower {
			{
				 2944, -- Devouring Plague
				64044, -- Psychic Horror
			},
			"SHADOW_ORBS",
		},
		Configure {
			"PWShield",
			L["Show Power Word: Shield or Weakened Soul on targeted ally."],
			17, -- Power Word: Shield
			"ally",
			"UNIT_AURA",
			(function()
				local hasPWShield = BuildAuraHandler_Single("HELPFUL", "good", "ally", 17)
				local hasWeakenedSoul = BuildAuraHandler_Single("HARMFUL", "bad", "ally", 6788)
				return function(units, model)
					return hasPWShield(units, model) or hasWeakenedSoul(units, model)
				end
			end)(),
		},
		ShowStacks {
			81700,    -- on Archangel
			81661,    -- show the stacks of Evangelism (buff)
			5,        -- number of max stacks
			"player", -- unit to track the buff on
			nil,      -- no handler (else it will get a hint)
			nil,      -- no highlight (the default ui highlights it)
			81662,    -- provider spell -> Evangelism (passive)
		},
		ShowStacks {
			{
				   596, -- Prayer of Healing
				  2060, -- Heal
				155245, -- Clarity of Purpose
			},
			63735,      -- Serendipity (buff)
			2,          -- Max two stacks
			"player",
			2,          -- Hint at 2 stacks
			"hint",
			63733,      -- Serendipity (passive)
		},
		ShowStacks {
			33076,  -- Prayer of Mending
			155362, -- Word of Mending (buff)
			10,     -- Max 10 stacks
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
