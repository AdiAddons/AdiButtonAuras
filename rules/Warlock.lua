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

if not addon.isClass("WARLOCK") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding warlock rules')

	return {
		ImportPlayerSpells {
			-- Import all spells for ...
			"WARLOCK",
			-- ... but ...
			 80240, -- Havoc
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
			format(L["%s when you have 3 or more stacks of %s."], DescribeHighlight("good"), GetSpellInfo(117828)),
			116858, -- Chaos Bolt
			"player",
			"UNIT_AURA",
			function(_, model)
				local found, count = GetPlayerBuff("player", 117828)
				if found and count >= 3 then
					model.highlight = "good"
				end
			end,
			123686, -- Provided by: Pyroclasm
		},
		Configure {
			"Havoc",
			format(
				L["%s Else %s"],
				BuildDesc("HARMFUL PLAYER", "bad", "enemy", 80240),
				BuildDesc("HELPFUL PLAYER", "good", "player", 80240)
			),
			80240, -- Havoc
			{ "player", "enemy" },
			"UNIT_AURA",
			(function()
				local selfHavoc = BuildAuraHandler_Single("HELPFUL PLAYER", "good", "player", 80240)
				local enemyHavoc = BuildAuraHandler_Single("HARMFUL PLAYER", "bad", "enemy", 80240)
				return function(units, model)
					return selfHavoc(units, model) and enemyHavoc(units, model)
				end
			end)()
		},
		Configure {
			"HavocHint",
			L["Suggest using Havoc when it is available."],
			80240,
			"player",
			"UNIT_AURA",
			function(_, model)
				if not GetPlayerAura("player", 80240) then
					model.hint = true
				end
			end
		},
	}

end)
