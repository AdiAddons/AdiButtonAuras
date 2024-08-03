--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2023 Adirelle (adirelle@gmail.com)
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
along with AdiButtonAuras. If not, see <http://www.gnu.org/licenses/>.
--]]

local _, addon = ...

if not addon.isClass('MONK') then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Rules', 'Adding monk rules')

	return {
		ImportPlayerSpells { 'MONK' },

		ShowPower {
			{
				113656, -- Fists of Fury (Windwalker)
				392983, -- Strike of the Windlord (Windwalker)
			},
			'Chi',
		},

		ShowTempPet { 123904, 63508 }, -- Invoke Xuen, the White Tiger (Windwalker)

		ShowTotem { 115313, 620831 }, -- Summon Jade Serpent Statue (Mistweaver)
		ShowTotem { 132578, 608951 }, -- Invoke Niuzao, the Black Ox (Brewmaster)
		ShowTotem { 322118, 574571 }, -- Invoke Yu'lon, the Jade Serpent (Mistweaver)
		ShowTotem { 325197, 877514 }, -- Invoke Chi-Ji, the Red Crane (Mistweaver)
	}
end)
