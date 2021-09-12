--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2018 Adirelle (adirelle@gmail.com)
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
	Debug('Adding monk rules')

	local function BuildTotemHandler(totem)
		return function(_, model)
			-- statues fill the first free slot when re-cast
			-- due to statues' cooldowns the highest totem slot is 3
			for slot = 1, 3 do
				local found, _, start, duration, texture = GetTotemInfo(slot)
				if found and texture == totem then
					model.highlight = 'good'
					model.expiration = start + duration
					return
				end
			end
		end
	end

	return {
		ImportPlayerSpells {
			-- import all spells for
			'MONK',
			-- except
			116680, -- Thunder Focus Tea (Mistweaver)
			195630, -- Elusive Brawler (Brewmaster)
			201447, -- Ride the Wind (Windwalker pvp talent)
			202090, -- Teachings of the Monastery (Mistweaver)
			215479, -- Shuffle (Brewmaster)
			228563, -- Blackout Combo (Brewmaster talent)
			261769, -- Inner Strength (Windwalker talent)
		},

		SelfBuffAliases {
			116680, -- Thunder Focus Tea (Mistweaver)
		},

		SelfBuffAliases {
			{
				205523, -- Blackout Kick
				322729, -- Spinning Crane Kick
			},
			215479, -- Shuffle (Brewmaster)
			322120, -- Shuffle (Brewmaster passive)
		},

		ShowPower {
			{
				100784, -- Blackout Kick
				101546, -- Spinning Crane Kick
				107428, -- Rising Sun Kick
				113656, -- Fists of Fury
			},
			'Chi',
		},

		ShowStacks {
			100784, -- Blackout Kick
			202090, -- Teachings of the Monastery (Mistweaver)
			3,
			'player',
			3,
			'hint',
			116645, -- Teachings of the Monastery (Mistweaver)
		},

		Configure {
			'BlackoutCombo',
			BuildDesc('HELPFUL PLAYER', 'good', 'player', 228563),
			205523, -- Blackout Kick (Brewmaster)
			'player',
			'UNIT_AURA',
			function(_, model)
				local found, _, expiration = GetPlayerBuff('player', 228563) -- Blackout Combo
				if found then
					model.highlight = 'good'
					model.expiration = expiration
				end
			end,
			196736, -- Blackout Combo (Brewmaster talent)
		},

		Configure {
			'WhiteTigerPet',
			L['Show the duration of @NAME.'],
			123904, -- Invoke Xuen, the White Tiger (Windwalker talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(620832)
		},

		Configure {
			'JadeSerpentPet',
			L['Show the duration of @NAME.'],
			322118, -- Invoke Yu'lon, the Jade Serpent (Mistweaver)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(574571)
		},

		Configure {
			'RedCranePet',
			L['Show the duration of @NAME.'],
			325197, -- Invoke Chi-Ji, the Red Crane (Mistweaver talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(877514)
		},

		Configure {
			'BlackOxStatue',
			L['Show the duration of @NAME.'],
			115315,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(627607),
		},

		Configure {
			'JadeSerpentStatue',
			L['Show the duration of @NAME.'],
			115313,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(620831),
		},
	}
end)
