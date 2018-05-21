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

if not addon.isClass('DEATHKNIGHT') then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding deathknight rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			'DEATHKNIGHT',
			-- except for
			273977, -- Grip of the Dead (Blood talent)
		},

		ShowStacks {
			219809, -- Tombstone (Blood talent)
			195181, -- Bone Shield (Blood)
			5,
		},
	}
end)
