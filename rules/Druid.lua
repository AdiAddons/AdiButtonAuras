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

if not addon.isClass('DRUID') then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Rules', 'Adding druid rules')

	return {
		ImportPlayerSpells {
			-- import all spells for
			'DRUID',
			-- except for
			114108, -- Soul of the Forest (Restoration talent)
			135700, -- Clearcasting (Feral)
			145152, -- Bloodtalons (Feral talent)
			203059, -- King of the Jungle (Feral honor talent)
			203407, -- Revitalize (Restoration honor talent)
			203554, -- Focused Growth (Restoration honor talent)
			207386, -- Spring Blossoms (Restoration talent)
			207640, -- Abundance (Restoration talent)
			209746, -- Moonkin Aura (Balance honor talent)
			236187, -- Master Shapeshifter (Guardian honor talent)
			279709, -- Starfond (Balance talent)
			285646, -- Scent of Blood (Feral talent)
		},

		-- show combo points on spenders
		ShowPower {
			{
				  1079, -- Rip
				 22568, -- Ferocious Bite
				 22570, -- Maim (Feral)
				 52610, -- Savage Roar (Feral talent)
				236026, -- Enraged Maim (Feral honor talent)
				285381, -- Primal Wrath (Feral talent)
			},
			'ComboPoints'
		},

		-- don't show Clearcasting (Feral) on Thrash
		SelfBuffAliases {
			{
				  5221, -- Shred
				106785, -- Swipe
				202028, -- Brutal Slash (Feral talent)
			},
			135700, -- Clearcasting (Feral)
		},

		-- show Soul of the Forest on Swiftmend
		PassiveModifier {
			158478, -- Soul of the Forest (Restoration talent)
			 18562, -- Swiftmend
			114108, -- Soul of the Forest
		},

		-- show the stacks of Abundance on Regrowth
		ShowStacks {
			8936, -- Regrowth
			207640, -- Abundance
			nil,
			'player',
			nil,
			nil,
			207383, -- Abundance (Restoration talent)
		},

		-- show the stacks of Revitalize on Rejuvenation
		ShowStacks {
			774, -- Rejuvenation
			203407, -- Revitalize
			2,
			'ally',
			nil,
			nil,
			203399, -- Revitalize (Restoration honor talent)
		},

		Configure {
			'Efflorescence',
			L['Show the duration of @NAME.'],
			145205,
			'player',
			'PLAYER_TOTEM_UPDATE',
			function(_, model)
				local present, _, startTime, duration = GetTotemInfo(1)
				if present then
					model.highlight = 'good'
					model.expiration = startTime + duration
				end
			end,
		},

		-- show Scent of Blood on Swipe
		Configure {
			'ScentOfBlood',
			BuildDesc(),
			106785, -- Swipe
			'player',
			'UNIT_AURA',
			function(_, model)
				local found, _, expiration = GetPlayerBuff('player', 285646) -- Scent of Blood (Feral talent)
				if found then
					model.highlight = 'good'
					model.expiration = expiration
				end
			end,
			285564, -- Scent of Blood (Feral talent)
		},
	}
end)
