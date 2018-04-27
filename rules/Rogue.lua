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
along with AdiButtonAuras.  If not, see <http://www.gnu.org/licenses/>.
--]]

local _, addon = ...

if not addon.isClass("ROGUE") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding rogue rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			"ROGUE",
			-- except
			192425, -- Surge of Toxins (Assassination artifact) (not game changing)
			192432, -- From the Shadows (Assassination artifact) (to emphasize Vendetta's debuff)
			192925, -- Blood of the Assassinated (Assassination artifact) (completely within Rupture's own debuff)
			193538, -- Alacity (not game changing)
			206760, -- Night Terrors (to emphasize Nightblade's DoT)
		},

		ShowPower {
			{
				   408, -- Kidney Shot
				  1943, -- Rupture
				  2098, -- Run Through
				  5171, -- Slice and Dice
				 32645, -- Envenom
				152150, -- Death from Above
				193316, -- Roll the Bones
				195452, -- Nightblade
				196819, -- Eviscerate
				199804, -- Between the Eyes
				245388, -- Toxic Blade
			},
			"ComboPoints",
		},
	}
end)
