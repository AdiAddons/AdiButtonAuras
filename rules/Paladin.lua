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

if not addon.isClass("PALADIN") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding paladin rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			"PALADIN",
			-- except for
			269571, -- Zeal (Retribution talent)
		},

		ShowPower {
			{
				 85256, -- Templar's Verdict (Retribution)
				 53385, -- Divine Storm (Retribution)
				 84963, -- Inquisition (Retribution talent)
				210191, -- Word of Glory (Retribution talent)
				215661, -- Justicar's Vengeance (Retribution talent)
				267798, -- Execution Sentence (Retribution talent)
			},
			'HolyPower'
		},
	}
end)
