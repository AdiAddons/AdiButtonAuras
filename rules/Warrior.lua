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

if not addon.isClass("WARRIOR") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding warrior rules')

	return  {
		ImportPlayerSpells { "WARRIOR" },

		-- Flash Shield Barrier Button at 60 rage
		ShowPower {
			112048, -- Shield Barrier
			"RAGE",
			60,
			"flash"
		},

		-- Show Rage on Shield Barrier Button
		ShowPower {
			112048, -- Shield Barrier
			"RAGE",
		},

		-- Execute hint example
		Configure {
			"Execute",
			L["Show a hint when the target is below 20% health."],
			5308, -- Execute
			"enemy",
			{ "UNIT_HEALTH", "UNIT_HEALTH_MAX" },
			function(units, model)
				if UnitHealth(units.enemy) / UnitHealthMax(units.enemy) <= 0.20 then
					model.hint = true
				end
			end,
		},
}
end)
