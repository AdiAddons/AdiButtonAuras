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

if not addon.isClass("DRUID") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Rules', 'Adding druid rules')

	return {
		ImportPlayerSpells { "DRUID" },

		ShowPower {
			{
				 1079, -- Rip
				22568, -- Ferocious Bite
				22570, -- Maim
				52610, -- Savage Roar
			},
			"ComboPoints"
		},

		Configure {
			"Efflorescence",
			L["Show the duration of @NAME."],
			145205,
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(_, model)
				local present, _, startTime, duration = GetTotemInfo(1)
				if present then
					model.highlight = "good"
					model.expiration = startTime + duration
				end
			end,
		},
	}
end)
