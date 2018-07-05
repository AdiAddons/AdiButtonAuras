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

if not addon.isClass('SHAMAN') then return end

-- primal elementals GUIDs
local primalEarthElemental = 61056
local primalFireElemental  = 61029
local primalStormElemental = 77942

-- totem textures
local capacitorTotem     = 136013
local counterstrikeTotem = 511726
local earthbindTotem     = 136102
local groundingTotem     = 136039
local liquidMagmaTotem   = 971079
local skyfuryTotem       = 135829
local tremorTotem        = 136108
local windRushTotem      = 538576
-- elementals totem textures
local earthElemental     = 136024
local fireElemental      = 135790
local stormElemental     = 1020304
local feralSpirit        = 237577

local function BuildTempPetHandler(id)
	return function(_, model)
		local guid = UnitGUID('pet')
		if guid and guid:match('%-' .. id .. '%-') then
			local remaining = GetPetTimeRemaining()
			if remaining then
				model.expiration = GetTime() + remaining / 1000
				model.highlight = 'good'
			end
		end
	end
end

-- matches the totems by texture instead of name
-- because of spell name - totem name disparity for elementals
-- i.e. Fire Elemental spawns Greater Fire Elemental
local function BuildTotemHandler(totem)
	return function(_, model)
		for slot = 1, 5 do
			local found, _, start, duration, texture = GetTotemInfo(slot)
			if found and texture == totem then
				model.expiration = start + duration
				model.highlight = 'good'
				break
			end
		end
	end
end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding shaman rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			'SHAMAN',
			-- except for
			  2645, -- Ghost Wolf
			197211, -- Fury of Air (Enhancement talent)
			262652, -- Forceful Winds (Enhancement talent)
			263806, -- Wind Gust (Elemental talent)
			224125, -- Molten Weapon (Enhancement talent)
			224127, -- Crackling Surge (Enhancement talent)
		},

		Configure {
			'CapacitorTotem',
			L['Show the duration of @NAME.'],
			192058,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(capacitorTotem),
		},

		Configure {
			'CounterstrikeTotem',
			L['Show the duration of @NAME.'],
			204331, -- Counterstrike Totem (Elemental/Enhancement talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(counterstrikeTotem),
		},

		Configure {
			'EarthbindTotem',
			L['Show the duration of @NAME.'],
			2484,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(earthbindTotem),
		},

		Configure {
			'GroundingTotem',
			L['Show the duration of @NAME.'],
			204336, -- Grounding Totem (Elemental/Enhancement honor talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(groundingTotem),
		},

		Configure {
			'LiquidMagmaTotem',
			L['Show the duration of @NAME.'],
			192222, -- Liquid Magma Totem (Elemental talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(liquidMagmaTotem),
		},

		Configure {
			'SkyfuryTotem',
			L['Show the duration of @NAME.'],
			204330, -- Skyfury Totem (Elemental/Enhancement honor talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(skyfuryTotem),
		},

		Configure {
			'TremorTotem',
			L['Show the duration of @NAME.'],
			8143,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(tremorTotem),
		},

		Configure {
			'WindRushTotem',
			L['Show the duration of @NAME.'],
			192077, -- Wind Rush Totem (talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(windRushTotem),
		},

		Configure {
			'EarthElemental',
			L['Show the duration of @NAME.'],
			198103,
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(earthElemental),
		},

		Configure {
			'FireElemental',
			L['Show the duration of @NAME.'],
			198067, -- Fire Elemental (Elemental)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(fireElemental),
		},

		Configure {
			'StormElemental',
			L['Show the duration of @NAME.'],
			192249, -- Storm Elemental (Elemental talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(stormElemental),
		},

		Configure {
			'FeralSpirit',
			L['Show the duration of @NAME.'],
			51533, -- Feral Spirit (Enhancement)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(feralSpirit),
		},

		Configure {
			'PrimalEarthElemental',
			L['Show the duration of @NAME.'],
			198103, -- Earth Elemental
			'player',
			'UNIT_PET',
			BuildTempPetHandler(primalEarthElemental),
			117013, -- Primal Elementalist (Elemental talent)
		},

		Configure {
			'PrimalFireElemental',
			L['Show the duration of @NAME.'],
			198067, -- Fire Elemental
			'player',
			'UNIT_PET',
			BuildTempPetHandler(primalFireElemental),
			117013, -- Primal Elementalist (Elemental talent)
		},

		Configure {
			'PrimalStormElemental',
			L['Show the duration of @NAME.'],
			192249, -- Storm Elemental (Elemental talent)
			'player',
			'UNIT_PET',
			BuildTempPetHandler(primalStormElemental),
			117013, -- Primal Elementalist (Elemental talent)
		},
	}
end)
