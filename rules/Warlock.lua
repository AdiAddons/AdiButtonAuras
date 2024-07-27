--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2023 Adirelle (adirelle@gmail.com)
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

AdiButtonAuras:RegisterRules(function()
	Debug('Rules', 'Adding warlock rules')

	return {
		ImportPlayerSpells { 'WARLOCK' },

		ShowPower {
			{
				  5740, -- Rain of Fire (Destruction)
				 17877, -- Shadowburn (Destruction)
				 27243, -- Seed of Corruption (Affliction)
				104316, -- Call Dreadstalkers (Demonology)
				105174, -- Hand of Gul'dan (Demonology)
				111898, -- Grimoire: Felguard (Demonology)
				116858, -- Chaos Bolt (Destruction)
				264119, -- Summon Vilefiend (Destruction)
				278350, -- Vile Taint (Affliction)
				324536, -- Malefic Rapture (Affliction)
				342601, -- Ritual of Doom
				385899, -- Soulburn (Destruction)
				417537, -- Oblivion (Affliction)
			},
			'SoulShards',
		},
	}
end)
