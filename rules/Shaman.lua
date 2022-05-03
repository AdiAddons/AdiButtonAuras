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

if not addon.isClass('SHAMAN') then return end

-- primal elementals' GUIDs
local primalEarthElemental = 61056
local primalFireElemental  = 61029
local primalStormElemental = 77942

-- guardians' totem textures
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
				if remaining > 600000 then
					remaining = 600000
				end
				model.expiration = GetTime() + remaining / 1000
				model.highlight = 'good'
			end
		end
	end
end

local function BuildTotemHandler(totem)
	return function(_, model)
		for slot = 1, 5 do
			local found, name, start, duration = GetTotemInfo(slot)
			if found and name == totem then
				model.expiration = start + duration
				model.highlight = 'good'
				break
			end
		end
	end
end

-- matches the totems by texture instead of name
-- because of spell name - totem name disparity for elementals
-- i.e. Fire Elemental spawns Greater Fire Elemental
-- Feral Spirit spawns Spirit Wolf
local function BuildGuardianHandler(guardian)
	return function(_, model)
		for slot = 1, 5 do
			local found, _, start, duration, texture = GetTotemInfo(slot)
			if found and texture == guardian then
				model.expiration = start + duration
				model.highlight = 'good'
			end
		end
	end
end

local function BuildWeaponEnchantHandler(enchantId)
	return function(_, model)
		local hasMainHandEnchant, mainHandExpiration, _, mainBuffId,
			  hasOffHandEnchant, offHandExpiration, _, offBuffId = GetWeaponEnchantInfo()

		if hasMainHandEnchant and mainBuffId == enchantId then
			model.highlight = 'good'
			model.expiration = GetTime() + mainHandExpiration / 1000
		elseif hasOffHandEnchant and offBuffId == enchantId then
			model.highlight = 'good'
			model.expiration = GetTime() + offHandExpiration / 1000
		end
	end
end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding shaman rules')

	local ancestralProtTotem = GetSpellInfo(207399)
	local capacitorTotem     = GetSpellInfo(192058)
	local cloudBurstTotem    = GetSpellInfo(157153)
	local counterstrikeTotem = GetSpellInfo(204331)
	local earthbindTotem     = GetSpellInfo(2484)
	local earthgrabTotem     = GetSpellInfo(51485)
	local earthenWallTotem   = GetSpellInfo(198838)
	local groundingTotem     = GetSpellInfo(204336)
	local healingTideTotem   = GetSpellInfo(108280)
	local healingStreamTotem = GetSpellInfo(5394)
	local liquidMagmaTotem   = GetSpellInfo(192222)
	local skyfuryTotem       = GetSpellInfo(204330)
	local spiritLinkTotem    = GetSpellInfo(98008)
	local totemMastery       = GetSpellInfo(262395)
	local tremorTotem        = GetSpellInfo(8143)
	local windRushTotem      = GetSpellInfo(192077)

	return {
		ImportPlayerSpells {
			-- import all spells for
			'SHAMAN',
			-- except for
			197211, -- Fury of Air (Enhancement talent)
			207400, -- Ancestral Vigor (Restoration talent)
			224125, -- Molten Weapon (Enhancement talent)
			224127, -- Crackling Surge (Enhancement talent)
			262652, -- Forceful Winds (Enhancement talent)
			263806, -- Wind Gust (Elemental talent)
			280815, -- Flash Flood (Restoration talent)
		},

		Configure {
			'AncestralProtectionTotem',
			L['Show the duration of @NAME.'],
			207399, -- Ancestral Protection Totem (Restoration talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(ancestralProtTotem),
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
			'CloudburstTotem',
			L['Show the duration of @NAME.'],
			201764, -- Recall Cloudburst Totem
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(cloudBurstTotem),
			157153, -- Cloudburst Totem (Restoration talent)
		},

		Configure {
			'CounterstrikeTotem',
			L['Show the duration of @NAME.'],
			204331, -- Counterstrike Totem (talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(counterstrikeTotem),
		},

		Configure {
			'EarthbindTotem',
			L['Show the duration of @NAME.'],
			2484, -- Earthbind Totem
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(earthbindTotem),
		},

		Configure {
			'EarthgrabTotem',
			L['Show the duration of @NAME.'],
			51485, -- Earthgrab Totem (Restoration talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(earthgrabTotem),
		},

		Configure {
			'EarthenWallTotem',
			L['Show the duration of @NAME.'],
			198838, -- Earthen Wall Totem (Restoration talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(earthenWallTotem),
		},

		Configure {
			'GroundingTotem',
			L['Show the duration of @NAME.'],
			204336, -- Grounding Totem (honor talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(groundingTotem),
		},

		Configure {
			'HealingTideTotem',
			L['Show the duration of @NAME.'],
			108280, -- Healing Tide Totem (Restoration)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(healingTideTotem),
		},

		Configure {
			'HealingStreamTotem',
			L['Show the duration of @NAME.'],
			5394, -- Healing Stream Totem (Restoration)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(healingStreamTotem),
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
			204330, -- Skyfury Totem (honor talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(skyfuryTotem),
		},

		Configure {
			'SpiritLinkTotem',
			L['Show the duration of @NAME.'],
			98008, -- Spirit Link Totem (Restoration)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(spiritLinkTotem),
		},

		Configure {
			'TotemMastery',
			L['Show the duration of @NAME.'],
			{
				210643, -- Totem Mastery (Elemental talent)
				262395, -- Totem Mastery (Enhancement talent)
			},
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildTotemHandler(totemMastery),
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
			BuildGuardianHandler(earthElemental),
		},

		Configure {
			'FireElemental',
			L['Show the duration of @NAME.'],
			198067, -- Fire Elemental (Elemental)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildGuardianHandler(fireElemental),
		},

		Configure {
			'StormElemental',
			L['Show the duration of @NAME.'],
			192249, -- Storm Elemental (Elemental talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildGuardianHandler(stormElemental),
		},

		Configure {
			'FeralSpirit',
			L['Show the duration of @NAME.'],
			51533, -- Feral Spirit (Enhancement)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildGuardianHandler(feralSpirit),
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

		Configure {
			'FlametongueWeapon',
			L['Show if @NAME up on your Weapon.'],
			318038, -- Flametongue Weapon
			'player',
			'UNIT_INVENTORY_CHANGED',
			BuildWeaponEnchantHandler(5400),
		},

		Configure {
			'WindfuryWeapon',
			L['Show if @NAME up on your Weapon.'],
			33757, -- Windfury Weapon
			'player',
			'UNIT_INVENTORY_CHANGED',
			BuildWeaponEnchantHandler(5401),
		},
	}
end)
