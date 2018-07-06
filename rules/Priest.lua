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
along with AdiButtonAuras. If not, see <http://www.gnu.org/licenses/>.
--]]

local _, addon = ...

if not addon.isClass('PRIEST') then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding priest rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			'PRIEST',
			-- except for
			   605, -- Mind Control
			196773, -- Inner Focus (Holy honor talent)
		},

		SelfBuffAliases {
			196762,  -- Inner Focus (Holy honor talent)
			196773,  -- Inner Focus
		},

		-- TODO: crowd control rules are evaluated after class rules
		Configure {
			'MindControl',
			L['Show the duration of @NAME.'],
			605, -- Mind Control
			'pet',
			{ 'UNIT_AURA', 'UNIT_PET' },
			function(_, model)
				local found, _, expiration = GetPlayerDebuff('pet', 605)
				if found then
					model.expiration = expiration
					model.highlight = 'good'
				end
			end,
		},
	}
end)
