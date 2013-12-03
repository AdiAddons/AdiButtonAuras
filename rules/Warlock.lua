--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013 Adirelle (adirelle@gmail.com)
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

if select(2, UnitClass("player")) ~= "WARLOCK" then return end

-- Globals: AddRuleFor Configure SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower SharedSimpleBuffs
-- Globals: BuildAuraHandler_Longest ImportPlayerSpells bit BuildAuraHandler_Single
-- Globals: math

AdiButtonAuras:RegisterRules(function(addon)
	addon.Debug('Rules', 'Adding warlock rules')

	return {
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
		SelfBuffs {
			  6229, -- Twilight Ward
			  7812, -- Sacrifice (voidwalker buff)
			 48018, -- Demonic Circle: Summon
			 80240, -- Havoc
			 91713, -- Nether Ward (talent)
			104025, -- Immolation Aura (demon form)
			104773, -- Unending Resolve
			108416, -- Sacrificial Pact (talent)
			108503, -- Grimoire of Sacrifice (talent)
			108508, -- Mannoroth's Fury (talent)
			108559, -- Demonic Rebirth
			110913, -- Dark Bargain (talent)
			111397, -- Blood Horror (talent)
			113858, -- Dark Soul: Instability
			113860, -- Dark Soul: Misery
			113861, -- Dark Soul: Knowledge
			114635, -- Ember Tap
			116198, -- Aura of Enfeeblement (demon form)
			119839, -- Fury Ward (Dark Apotheosis)
			120451, -- Flames of Xoroth
			132413, -- Shadow Bulwark (Grimoire of Sacrifice)
		},
		SharedSimpleBuffs {
			  5697, -- Unending Breath
			 20707, -- Soulstone
		},
		PetBuffs {
			   755, -- Health Funnel
			  1098, -- Enslave Demon
		},
		SimpleDebuffs {
			   172, -- Corruption
			   603, -- Metamorphosis: Doom
			   980, -- Agony
			 27243, -- Seed of Corruption
			 30108, -- Unstable Affliction
			 48181, -- Haunt
		},
		DebuffAliases {
			{
				   348, -- Immolate
				108686, -- Immolate (Fire and Brimstone)
			},
			348, -- Immolate
		},
		DebuffAliases {
			{
				 17962, -- Conflagrate
				108685, -- Conflagrate (Fire and Brimstone)
			},
			17962, -- Conflagrate
		},
		PassiveModifier {
			117896, -- Backdraft
			{
				 29722, -- Incinerate
				114654, -- Incinerate (Fire and Brimstone)
			},
			117828, -- Backdraft (buff)
		},
		--[[ Check if it already used or not
		PassiveModifier {
			108563, -- Backlash
			 29722, -- Incinerate
			108563, -- Backlash
			"player",
		},
		]]
		PassiveModifier {
			122351, -- Molten Core
			  6353, -- Soul Fire
			122351, -- Molten Core
		},
		DebuffAliases {
			105174, -- Hand of Gul'dan
			 47960, -- Shadowflame
		},
		Configure {
			"Pyroclasm",
			format(addon.L["%s when you have 3 or more stacks of %s."], addon.DescribeHighlight("good"), GetSpellInfo(117828)),
			116858, -- Chaos Bolt
			"player",
			"UNIT_AURA",
			(function()
				local backdraft = GetSpellInfo(117828)
				return function(_, model)
					local name, _, _, count = UnitAura("player", backdraft, nil, "PLAYER HELPFUL")
					if name and count >= 3 then
						model.highlight = "good"
					end
				end
			end)(),
			123686, -- Provided by: Pyroclasm
		},
	}

end)
