--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2022 Adirelle (adirelle@gmail.com)
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

if not addon.isClass('WARRIOR') then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding warrior rules')

	return {
		ImportPlayerSpells {
			-- add all spells for
			'WARRIOR',
			-- except for
			  6673, -- Battle Shout
			115767, -- Deep Wounds (Protection)
			236321, -- War Banner (Arms honor talent)
			262115, -- Deep Wounds (Arms)
		},

		DebuffAliases {
			 20243, -- Devastate (Protection)
			115767, -- Deep Wounds
			115768, -- Deep Wounds (Protection)
		},

		Configure {
			'WarBanner',
			L['Show the duration of %NAME.'],
			236320, -- War Banner (Arms honor talent)
			'player',
			{ 'PLAYER_TOTEM_UPDATE', 'UNIT_AURA' },
			function(_, model)
				local found, _, start, duration = GetTotemInfo(1)
				if found then
					model.expiration = start + duration
					model.highlight = GetPlayerBuff('player', 236321) and 'good' or nil
				end
			end,
		},

		Configure {
			'BattleShout',
			L['Show the number of group members missing @NAME.'],
			6673, -- Battle Shout
			'group',
			{'GROUP_ROSTER_UPDATE', 'UNIT_AURA'},
			function(units, model)
				local missing = 0
				local shortest
				for unit in next, units.group do
					if UnitIsPlayer(unit) and not UnitIsDeadOrGhost(unit) then
						local found, _, expiration = GetBuff(unit, 6673)
						if found then
							if not shortest or expiration < shortest then
								shortest = expiration
							end
						else
							missing = missing + 1
						end
					end
				end

				if shortest then
					model.expiration = shortest
					model.highlight = 'good'
				end
				if missing > 0 then
					model.count = missing
					model.hint = true
				end
			end,
		},
	}
end)
