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

local _G = _G
local strmatch = _G.strmatch

if not addon.isClass('SHAMAN') then return end

local function BuildTotemHandler(totem)
	return function(_, model)
		for slot = 1, 4 do
			local found, name, start, duration = GetTotemInfo(slot)
			if found and strmatch(name, totem) then
				model.expiration = start + duration
				model.highlight = 'good'
				break
			end
		end
	end
end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding shaman rules')

	-- All totem ranks
	local earthbindTotem        = {2484}
	local diseaseCleansingTotem = {8170}
	local fireNovaTotem         = {1535, 8498, 8499, 11314, 11315}
	local fireResistanceTotem   = {8184, 10478, 10479}
	local flametongueTotem      = {8227, 8249, 10526, 16387}
	local frostResistanceTotem  = {8181, 10478, 10479}
	local graceOfAirTotem       = {8835, 10627, 25359}
	local groundingTotem        = {8177}
	local healingStreamTotem    = {5394, 6375, 6377, 10462, 10463}
	local magmaTotem            = {8190, 10585, 10586, 10587}
	local manaSpringTotem       = {5675, 10495, 10496, 10497}
	local natureResistanceTotem = {10595, 10600, 10601}
	local poisonCleansingTotem  = {8166}
	local searingTotem          = {3599, 6363, 6364, 6365, 10437, 10438}
	local setryTotem            = {6495}
	local stoneclawTotem        = {5730, 6390, 6391, 6392, 10427, 10428}
	local stoneskinTotem        = {8071, 8154, 8155, 10406, 10407, 10408}
	local strengthOfEarthTotem  = {8075, 8160, 8161, 10442, 25361}
	local tranquilAirTotem      = {25908}
	local tremorTotem           = {8143}
	local windfuryTotem         = {8512, 10613, 10614}
	local windwallTotem         = {15107, 15111, 15112}

	return {
		ImportPlayerSpells {
			'SHAMAN',
		},

		Configure {
			'EarthbindTotem',
			L['Show the duration of @NAME.'],
			earthbindTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(earthbindTotem[1])),
		},

		Configure {
			'DiseaseCleansingTotem',
			L['Show the duration of @NAME.'],
			diseaseCleansingTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(diseaseCleansingTotem[1])),
		},

		Configure {
			'FireNovaTotem',
			L['Show the duration of @NAME.'],
			fireNovaTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(fireNovaTotem[1])),
		},

		Configure {
			'FireResistanceTotem',
			L['Show the duration of @NAME.'],
			fireResistanceTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(fireResistanceTotem[1])),
		},

		Configure {
			'FlametongueTotem',
			L['Show the duration of @NAME.'],
			flametongueTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(flametongueTotem[1])),
		},

		Configure {
			'FrostResistanceTotem',
			L['Show the duration of @NAME.'],
			frostResistanceTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(frostResistanceTotem[1])),
		},

		Configure {
			'GraceOfAirTotem',
			L['Show the duration of @NAME.'],
			graceOfAirTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(graceOfAirTotem[1])),
		},

		Configure {
			'GroundingTotem',
			L['Show the duration of @NAME.'],
			groundingTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(groundingTotem[1])),
		},

		Configure {
			'HealingStreamTotem',
			L['Show the duration of @NAME.'],
			healingStreamTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(healingStreamTotem[1])),
		},

		Configure {
			'MagmaTotem',
			L['Show the duration of @NAME.'],
			magmaTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(magmaTotem[1])),
		},

		Configure {
			'ManaSpringTotem',
			L['Show the duration of @NAME.'],
			manaSpringTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(manaSpringTotem[1])),
		},

		Configure {
			'NatureResistanceTotem',
			L['Show the duration of @NAME.'],
			natureResistanceTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(natureResistanceTotem[1])),
		},

		Configure {
			'PoisonCleansingTotem',
			L['Show the duration of @NAME.'],
			poisonCleansingTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(poisonCleansingTotem[1])),
		},

		Configure {
			'TremorTotem',
			L['Show the duration of @NAME.'],
			tremorTotem,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(GetSpellInfo(tremorTotem[1])),
		},

		Configure {
			'SearingTotem',
			L['Show the duration of @NAME.'],
			{3599, 6363}, -- Searing Totem
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler('Searing Totem'),
		},

		Configure {
			'DiseaseCleansingTotem',
			L['Show the duration of @NAME.'],
			8170, -- Searing Totem
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler('Searing Totem'),
		},
	}
end)
