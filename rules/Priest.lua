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

local function BuildGuardianHandler(guardian)
	return function(_, model)
		for slot = 1, 5 do
			local found, name, start, duration = GetTotemInfo(slot)
			if found and name == guardian then
				model.expiration = start + duration
				model.highlight = 'good'
				return
			end
		end
	end
end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding priest rules')

	local mindbender = GetSpellInfo(123040)
	local shadowfiend = GetSpellInfo(34433)

	return {
		ImportPlayerSpells {
			-- import all spells for
			'PRIEST',
			-- except for
			   605, -- Mind Control
			194384, -- Atonement (Discipline)
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

		Configure {
			'Shadowfiend',
			L['Show the duration of @NAME.'],
			34433, -- Shadowfiend (Discipline)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildGuardianHandler(shadowfiend)
		},

		Configure {
			'Mindbender',
			L['Show the duration of @NAME.'],
			123040, -- Mindbender (Discipline talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildGuardianHandler(mindbender)
		},

		-- track Atonement on Shadow Mend
		-- NOTE:
		-- Shadow Mend is used as the display spell because:
		-- - Power Word: Shield tracks itself
		-- - Power Word: Radiance has charges
		Configure {
			'AtonementTracker',
			format(L['Show the shortest duration and the number of group members with %s.'], GetSpellInfo(194384)), -- Atonement
			186263, -- Shadow Mend (Discipline)
			'group',
			'UNIT_AURA',
			function(units, model)
				local count, minExpiration = 0
				for unit in next, units.group do
					local found, _, expiration = GetPlayerBuff(unit, 194384)
					if found then
						count = count + 1
						if (not minExpiration or expiration < minExpiration) then
							minExpiration = expiration
						end
					end
				end
				if count > 0 then
					model.count = count
					model.expiration = minExpiration
				end
			end,
			81749, -- Atonement (Discipline)
		}
	}
end)
