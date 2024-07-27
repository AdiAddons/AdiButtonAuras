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

if not addon.isClass('PALADIN') then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Rules', 'Adding paladin rules')

	return {
		ImportPlayerSpells { 'PALADIN' },

		ShowPower {
			{
				 53385, -- Divine Storm (Retribution)
				 53600, -- Shield of the Righteous
				 85222, -- Light of Dawn (Holy)
				 85256, -- Templar's Verdict (Retribution)
				 85673, -- Word of Glory
				156322, -- External Flame (Holy)
				215661, -- Judicar's Vengeance (Retribution)
				383328, -- Final Verdict (Retribution)
				415091, -- Shield of the Righteous (Holy)
			},
			'HolyPower',
		},
	}
end)
