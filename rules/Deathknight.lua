--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2021 Adirelle (adirelle@gmail.com)
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

if not addon.isClass('DEATHKNIGHT') then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding deathknight rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			'DEATHKNIGHT',
			-- except for
			194879, -- Icy Talons
			207203, -- Frost Shield (Frost talent)
			273977, -- Grip of the Dead (Blood talent)
			281209, -- Cold Heart (Frost talent)
			287254, -- Dead of Winter (Frost honor talent)
		},

		ShowStacks {
			219809, -- Tombstone (Blood talent)
			195181, -- Bone Shield (Blood)
			5,
		},

		ShowStacks {
			{
				 55090, -- Scourge Strike (Unholy)
				207311, -- Clawing Shadows (Unholy talent)
				223829, -- Necrotic Strike (Unholy honor talent)
				275699, -- Apocalypse (Unholy)
			},
			194310,
			6,
			'enemy',
		},

		ShowStacks {
			 45524, -- Chains of Ice
			281209, -- Cold Heart (Frost talent)
			20,
			'player',
			1,
			'hint',
			281208, -- Cold Heart (Frost talent)
		},

		Configure {
			'IcyTalons',
			BuildDesc('HELPFUL PLAYER', 'good', 'player', 194879), -- Icy Talons
			49143, -- Frost Strike (Frost)
			'player',
			'UNIT_AURA',
			function(_, model)
				local found, count, expiration = GetPlayerBuff('player', 194879) -- Icy Talons
				if found then
					model.highlight = 'good'
					model.expiration = expiration
					if count and count > 1 then
						model.count = count
					end
				end
			end,
			194878, -- Icy Talons (Frost talent)
		},

		Configure {
			'RaiseDeadUnholy',
			format(L["%s when you don't have a summoned ghoul."], DescribeHighlight('hint')),
			46584, -- Rank 2 Unholy
			'player',
			'UNIT_PET',
			function(_, model)
				if HasPetSpells() then
					model.highlight = 'good'
				else
					model.hint = true
				end
			end,
		},

		Configure {
			'RaiseDead',
			L['Show the remaining duration of @NAME.'],
			46585, -- Rank 1 Blood/Frost
			'player',
			'PLAYER_TOTEM_UPDATE',
			function(_, model)
				local found, _, startTime, duration = GetTotemInfo(1) -- Risen Ghoul is always the first totem
				if found then
					model.highlight = 'good'
					model.expiration = startTime + duration
				end
			end,
		},

		Configure {
			'SummonGargoyle',
			L['Show the remaining duration of @NAME.'],
			49206, -- Summon Gargoyle (Unholy talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			function(_, model)
				local found, _, startTime, duration = GetTotemInfo(3) -- Gargoyle is always the third totem
				if found then
					model.highlight = 'good'
					model.expiration = startTime + duration
				end
			end,
		},

		Configure {
			'RaiseAbomination',
			L['Show the remaining duration of @NAME.'],
			288853, -- Summon Gargoyle (Unholy talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			function(_, model)
				local found, _, startTime, duration = GetTotemInfo(1) -- Raise Abomination is always the first totem
				if found then
					model.highlight = 'good'
					model.expiration = startTime + duration
				end
			end,
		},
	}
end)
