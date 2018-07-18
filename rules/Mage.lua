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

if not addon.isClass('MAGE') then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding mage rules')

	return {
		ImportPlayerSpells {
			-- import all spell for
			'MAGE',
			-- except for
			 41425, -- Hypothermia
			 45438, -- Ice Block
			116014, -- Rune of Power (Frost talent)
			205473, -- Icicles (Frost)
			205708, -- Chilled (Frost)
			205766, -- Bone Chilling (Frost talent)
		},

		-- show the stacks of Icicles on Glacial Spike and Ice Lance
		ShowStacks {
			{
				 30455, -- Ice Lance (Frost)
				199786, -- Glacial Spike (Frost talent)
			},
			205473, -- Icicles (Frost)
			5,
			'player',
			nil,
			nil,
			76613, -- Mastery: Icicles (Frost)
		},

		Configure {
			'IceBlockHypothermia',
			format(
				'%s %s',
				BuildDesc('HELPFUL PLAYER', 'good', 'player', 45438), -- Ice Block
				BuildDesc('HARMFUL PLAYER', 'bad', 'player', 41425) -- Hypothermia
			),
			45438, -- Ice Block
			'player',
			'UNIT_AURA',
			(function()
				local hasIceBlock = BuildAuraHandler_Single('HELPFUL PLAYER', 'good', 'player', 45438)
				local hasHypothermia = BuildAuraHandler_Single('HARMFUL PLAYER', 'bad', 'player', 41425)
				return function(_, model)
					return hasIceBlock(_, model) or hasHypothermia(_, model)
				end
			end)(),
		},

		-- track if the player is in range of Rune of Power
		Configure {
			'RuneOfPower',
			format(
				'%s %s',
				BuildDesc('HELPFUL PLAYER', 'good', 'player', 116014), -- Rune of Power
				format(L['Show the "bad" border when your buff %s is not found on yourself.'], GetSpellInfo(116014))
			),
			116011, -- Rune of Power (Frost talent)
			'player',
			{ 'UNIT_AURA', 'PLAYER_TOTEM_UPDATE' },
			function(_, model)
				local hasTotem, _, start, duration = GetTotemInfo(1) -- Rune of Power is always the first totem

				if hasTotem then
					local hasBuff = GetPlayerBuff('player', 116014) -- Rune of Power
					model.highlight = hasBuff and 'good' or 'bad'
					model.expiration = start + duration
				end
			end,
		},

		-- prioritize Bone Chilling (Frost talent) over Chilled (Frost)
		Configure {
			'ChilledBoneChilling',
			format(
				'%s %s',
				BuildDesc('HELPFUL PLAYER', 'good', 'player', 205766), -- Bone Chilling (Frost talent)
				BuildDesc('HARMFUL PLAYER', 'bad', 'enemy', 205708) -- Chilled (Frost)
			),
			{
				   116, -- Frostbolt
				 84714, -- Frozen Orb
				190356, -- Blizzard
			},
			{ 'player', 'enemy' },
			'UNIT_AURA',
			(function()
				local hasBoneChilling = BuildAuraHandler_Single('HELPFUL PLAYER', 'good', 'player', 205766)
				local isChilled = BuildAuraHandler_Single('HARMFUL PLAYER', 'bad', 'enemy', 205708)
				return function(units, model)
					return hasBoneChilling(units, model) or isChilled(units, model)
				end
			end)(),
		}
	}
end)
