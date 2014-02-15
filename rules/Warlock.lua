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

	local _G = _G
	local format = _G.format
	local GetSpellInfo = _G.GetSpellInfo
	local UnitAura = _G.UnitAura

	return {
		ImportPlayerSpells {
			-- Import all spells for ...
			"WARLOCK",
			-- ... but ...
			116858, -- Chaos Bolt
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
