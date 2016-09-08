--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2016 Adirelle (adirelle@gmail.com)
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

	return {
		ImportPlayerSpells { "DEATHKNIGHT" },
		-- show the stacks of Razorice on Frost Strike if Shattering Strikes is known
		ShowStacks {
			49143, -- Frost Strike
			51714, -- Razorice
			5, -- max
			"enemy",
			nil,
			nil,
			207057, -- Shattering Strikes
		},

		Configure {
			"BurstFesteringWound",
			format(L["%s when %s has %d or more stacks"], DescribeHighlight("hint"), GetSpellInfo(194310), 7), -- Festering Wound
			{
				 55090, -- Scourge Strike
				207311, -- Clawing Shadows
			},
			"enemy",
			"UNIT_AURA",
			function(units, model)
				local found, count = GetPlayerDebuff(units.enemy, 194310) -- Festering Wound
				if found and count >= 7 then
					model.hint = true
				end
			end,
		},

		Configure {
			"SummonGargoyle",
			format("%s when you summoned either your Gargoyle or Dark Arbiter.", DescribeHighlight("good")),
			{
				 49206, -- Summon Gargoyle
				207349, -- Dark Arbiter
			},
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(_, model)
				local found, _, startTime, duration = GetTotemInfo(3) -- both are always the third totem
				if found then
					model.highlight = "good"
					model.expiration = startTime + duration
				end
			end,
		},

		Configure {
			"RaiseDead",
			format(L["%s when you don't have a summoned ghoul."], DescribeHighlight("hint")),
			46584,
			"player",
			"UNIT_PET",
			function(_, model)
				if HasPetSpells() then
					model.highlight = "good"
				else
					model.hint = true
				end
			end,
		},
	}
end)
