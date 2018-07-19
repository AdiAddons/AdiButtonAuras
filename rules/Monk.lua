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

	local blackOxStatue = 627607
	local jadeSerpentStatue = 620831

	local function BuildTotemHandler(statue)
		return function(_, model)
			-- monk have two totems at most
			-- BUG: statues override pets on Beta
			for slot = 1, 2 do
				local found, _, start, duration, texture = GetTotemInfo(slot)
				if found and texture == statue then
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
			129914, -- Power Strikes (Windwalker talent)
			198533, -- Soothing Mist (Mistweaver talent) <- Summon Jade Serpent Statue
			228563, -- Blackout Combo (Brewmaster talent)
			261769, -- Inner Strength (Windwalker talent)
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

		SelfBuffAliases {
			116680, -- Thunder Focus Tea (Mistweaver)
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
			'InvokePet',
			L['Show the duration of @NAME.'],
			{
				123904, -- Invoke Xuen, the White Tiger (Windwalker talent)
				132578, -- Invoke Niuzao, the Black Ox (Brewmaster talent)
				198664, -- Invoke Chi-Ji, the Red Crane (Mistweaver talent)
			},
			'player',
			'UNIT_PET',
			function(_, model)
				local remaining = GetPetTimeRemaining()
				if remaining then
					model.expiration = GetTime() + remaining / 1000
					model.highlight = 'good'
				end
			end,
		},

		Configure {
			'BlackOxStatue',
			L['Show the duration of @NAME.'],
			115315,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(blackOxStatue),
		},

		Configure {
			'JadeSerpentStatue',
			L['Show the duration of @NAME.'],
			115313,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(jadeSerpentStatue),
		},
	}
end)
