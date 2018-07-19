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

if not addon.isClass('WARLOCK') then return end

local darkglare = 1416161
local felLord   = 1113433
local infernal  = 136219
local observer  = 538445

local function BuildDemonHandler(demon)
	return function(_, model)
		for slot = 1, 5 do
			local _, _, start, duration, texture = GetTotemInfo(slot)
			if texture == demon then
				model.expiration = start + duration
				model.highlight = 'good'
			end
		end
	end
end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding warlock rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			'WARLOCK',
			-- except
			111400, -- Burning Rush (talent)
			212580, -- Eye of the Observer (Demonology honor talent)
			233490, -- Unstable Affliction (Affliction)
			233496, -- Unstable Affliction (Affliction)
			233497, -- Unstable Affliction (Affliction)
			233498, -- Unstable Affliction (Affliction)
			233499, -- Unstable Affliction (Affliction)
		},

		-- show Soul Shards on consumers
		ShowPower {
			{
				  5740, -- Rain of Fire (Destruction)
				 27243, -- Seed of Corruption (Affliction)
				-- 30108, -- Unstable Affliction (Affliction)
				104316, -- Call Dreadstalkers (Demonology)
				105174, -- Hand of Gul'dan (Demonology)
				116858, -- Chaos Bolt (Destruction)
				212459, -- Call Fel Lord (Demonology honor talent)
				267211, -- Bilescourge Bombers (Demonology talent)
				267217, -- Nether Portal (Demonology talent)
			},
			'SoulShards',
		},

		-- number of applications and shortest duration of Unstable Affliction
		Configure {
			'UnstableAffliction',
			BuildDesc('HARMFUL PLAYER', 'bad', 'enemy', 233490),
			30108, -- Unstable Affliction (Affliction)
			'enemy',
			'UNIT_AURA',
			(function()
				local isAffliction = {
					[233490] = true, -- Unstable Affliction (Affliction)
					[233496] = true, -- Unstable Affliction (Affliction)
					[233497] = true, -- Unstable Affliction (Affliction)
					[233498] = true, -- Unstable Affliction (Affliction)
					[233499] = true, -- Unstable Affliction (Affliction)
				}
				local IterateAuras = addon.GetAuraIterator('HARMFUL PLAYER')

				return function(units, model)
					local unit = units.enemy
					if not unit or unit == '' then return end

					local shortest = 0
					local count = 0
					for _, id, _, expiration in IterateAuras(unit) do
						if isAffliction[id] then
							count = count + 1
							if shortest == 0 or expiration < shortest then
								shortest = expiration
							end
						end
					end

					model.highlight = count > 0 and 'bad' or nil
					model.expiration = shortest
					model.count = count
				end
			end)(),
		},

		Configure {
			'DemonicGateway',
			BuildDesc('HARMFUL', 'bad', 'player', 113942),
			111771, -- Demonic Gateway
			'player',
			'UNIT_AURA',
			function(_, model)
				local found, _, expiration = GetDebuff('player', 113942)
				if found then
					model.expiration = expiration
					model.highlight = 'bad'
				end
			end,
		},

		Configure {
			'SummonInfernal',
			L['Show the duration of @NAME.'],
			1122, -- Summon Infernal (Destruction)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildDemonHandler(infernal),
		},

		Configure {
			'CallFelLord',
			L['Show the duration of @NAME.'],
			212459, -- Call Fel Lord (Demonology honor talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildDemonHandler(felLord),
		},

		Configure {
			'Observer',
			L['Show the duration of @NAME.'],
			201996, -- Call Observer (Demonology honor talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildDemonHandler(observer),
		},

		Configure {
			'Darkglare',
			L['Show the duration of @NAME.'],
			205180, -- Summon Darkglare (Affliction)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildDemonHandler(darkglare),
		},
	}
end)
