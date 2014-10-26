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

if not addon.isClass("HUNTER") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding hunter rules')

	return {
		ImportPlayerSpells { "HUNTER" },
			Configure {
				"Call Pet",
				L['Suggests summoning your pet'],
				{
					883,      -- Call Pet 1
					-- 83242, -- Call Pet 2
					-- 83243, -- Call Pet 3
					-- 83244, -- Call Pet 4
					-- 83245, -- Call Pet 5
				},
				"player",
				"UNIT_PET",
				function(units, model)
					if not HasPetSpells() then
						model.hint = "true"
					else
						model.highlight = "good"
					end
				end,
				883, -- Requires Call Pet
			},
	}
end)
