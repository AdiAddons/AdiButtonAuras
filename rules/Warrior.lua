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

if not addon.isClass("WARRIOR") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding warrior rules')

	return {
		ImportPlayerSpells { "WARRIOR" },

		Configure {
			"Execute",
			format(L["%s when %s is below %s%% health."], DescribeHighlight("hint"), DescribeAllTokens("enemy"), 20),
			{ 5308, 163201 }, -- Execute
			"enemy",
			{ "UNIT_HEALTH", "UNIT_MAXHEALTH" },
			function(units, model)
				local foe = units.enemy
				local maxHealth = UnitHealthMax(foe)
				if maxHealth <= 0 then return end
				if UnitHealth(foe) / maxHealth <= 0.20 then
					model.hint = true
				end
			end,
		},
	}
end)
