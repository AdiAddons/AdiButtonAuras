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

if not addon.isClass("ROGUE") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding rogue rules')

	return {
		ImportPlayerSpells { "ROGUE" },
		Configure {
			"ComboPoints",
			format(
				L["Show %s and %s when it reaches its maximum."],
				L["combo points"],
				DescribeHighlight("flash")
			),
			{
				 32645, -- Envenom
				  2098, -- Eviscerate
				  5171, -- Slice and Dice
				121411, -- Crimson Tempest
				  1943, -- Rupture
				   408, -- Kidney Shot
				 73651, -- Recuperate
				 26679, -- Deadly Throw

				-- 73981, -- Redirect
			},
			{ "enemy", "player" },
			"UNIT_COMBO_POINTS",
			function(units, model)
				if not units.enemy then return end
				local points = GetComboPoints("player", units.enemy)
				if points and points > 0 then
					model.count = points or 0
					if points == 5 then
						model.highlight = "flash"
					end
					return true
				end
			end,
		},
	}

end)
