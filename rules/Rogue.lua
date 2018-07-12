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

if not addon.isClass('ROGUE') then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding rogue rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			'ROGUE',
			-- except for
			193538, -- Alacrity (Outlaw/Subtlety talent)
			193641, -- Elaborate Planning (Assassination talent)
			196980, -- Master of Shadows (Subtlety)
		},

		ShowPower {
			{
				   408, -- Kidney Shot (Assassination/Subtlety)
				  1943, -- Rupture (Assasination)
				  2098, -- Dispatch (Outlaw)
				  5171, -- Slice and Dice (Outlaw)
				 32645, -- Envenom (Assassination)
				121411, -- Crimson Tempest (Assassination talent)
				193316, -- Roll the Bones (Outlaw)
				196819, -- Eviscerate (Subtlety)
				195452, -- Nightblade (Subtlety)
				199804, -- Between the Eyes (Outlaw)
				269513, -- Death from Above (honor talent)
				280719, -- Secret Technique (Subtlety talent)
			},
			'ComboPoints',
		},

		-- don't show Master of Shadows (Subtlety) on Shadow Dance
		SelfBuffAliases {
			{
				  1784, -- Stealth
				115191, -- Stealth (with Subterfuge talent)
			},
			196980, -- Master of Shadows (Subtlety)
		},

		SelfBuffAliases {
			{
				  2098, -- Dispatch (Outlaw)
				196819, -- Eviscerate (Subtlety)
			},
			193538, -- Alacrity
			193539, -- Alacrity (Outlaw/Subtlety talent)
		},
	}
end)
