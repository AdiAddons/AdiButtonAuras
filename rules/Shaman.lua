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

if not addon.isClass('SHAMAN') then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Rules', 'Adding shaman rules')

	return {
		ImportPlayerSpells { 'SHAMAN' },

		ShowTempPet { 192249, 77942 }, -- Storm Elemental (with Primal Elementalist)
		ShowTempPet { 198067, 61029 }, -- Fire Elemental (with Primal Elementalist)
		ShowTempPet { 198103, 61056 }, -- Earth Elemental (with Primal Elementalist)

		ShowTempWeaponEnchant {  33757, 5401 }, -- Windfury Weapon (Enhancement)
		ShowTempWeaponEnchant { 318038, 5400 }, -- Flametoungue Weapon
		ShowTempWeaponEnchant { 382021, 6498 }, -- Earthliving Weapon (Restoration)
		ShowTempWeaponEnchant { 462757, 7587 }, -- Thunderstrike Ward (Elemental)

		ShowTotem { 192249, 1020304 }, -- Storm Elemental
		ShowTotem { 198067,  135790 }, -- Fire Elemental
		ShowTotem { 198103,  136024 }, -- Earth Elemental

		ShowTotem {   2484,  136102 }, -- Earthbind Totem
		ShowTotem {   5394,  135127 }, -- Healing Stream Totem
		ShowTotem {   8143,  136108 }, -- Tremor Totem
		ShowTotem {  16191, 4667424 }, -- Mana Tide Totem (Restoration)
		ShowTotem {  51485,  136100 }, -- Earthgrab Totem
		ShowTotem {  98008,  237586 }, -- Spirit Link Totem (Restoration)
		ShowTotem { 108280,  538569 }, -- Healing Tide Totem (Restoration)
		ShowTotem { 192077,  538576 }, -- Wind Rush Totem
		ShowTotem { 198838,  136098 }, -- Earthen Wall Totem (Restoration)
		ShowTotem { 201764,  971076 }, -- Recall Cloudburst Totem (Restoration)
		ShowTotem { 207399,  136080 }, -- Ancestral Protection Totem (Restoration)
		ShowTotem { 383013,  136070 }, -- Poison Cleansing Totem
		ShowTotem { 108270,  538572 }, -- Stone Bulwark Totem
		ShowTotem { 192222,  971079 }, -- Liquid Magma Totem (Elemental)
	}
end)
