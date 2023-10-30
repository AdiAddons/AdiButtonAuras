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

if not addon.isClass('PRIEST') then return end

local function BuildGuardianHandler(guardian)
	return function(_, model)
		for slot = 1, 5 do
			local found, name, start, duration = GetTotemInfo(slot)
			if found and name == guardian then
				model.expiration = start + duration
				model.highlight = 'good'
				return
			end
		end
	end
end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding priest rules')

	local mindbender = GetSpellInfo(123040)
	local shadowfiend = GetSpellInfo(34433)

	local hasWeakenedSoul = BuildAuraHandler_Single('HARMFUL', 'bad', 'ally', 6788) -- Weakened Soul
	local isShielded = BuildAuraHandler_Single('HELPFUL', 'good', 'ally', 17) -- Power Word: Shield

	return {
		ImportPlayerSpells {
			-- import all spells for
			'PRIEST',
			-- except for
			    17, -- Power Word: Shield
			   605, -- Mind Control
			 21562, -- Power Word: Fortitude
			194384, -- Atonement (Discipline)
			196773, -- Inner Focus (Holy honor talent)
			263406, -- Surrendered to Madness (Shadow)
		},

		SelfBuffAliases {
			196762,  -- Inner Focus (Holy honor talent)
			196773,  -- Inner Focus
		},

		-- TODO: crowd control rules are evaluated after class rules
		Configure {
			'MindControl',
			L['Show the duration of @NAME.'],
			605, -- Mind Control
			'pet',
			{ 'UNIT_AURA', 'UNIT_PET' },
			function(_, model)
				local found, _, expiration = GetPlayerDebuff('pet', 605)
				if found then
					model.expiration = expiration
					model.highlight = 'good'
				end
			end,
		},

		Configure {
			'Shadowfiend',
			L['Show the duration of @NAME.'],
			34433, -- Shadowfiend (Discipline/Shadow)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildGuardianHandler(shadowfiend)
		},

		Configure {
			'Mindbender',
			L['Show the duration of @NAME.'],
			{
				123040, -- Mindbender (Discipline/Shadow talent)
				200174, -- Mindbender (Shadow talent)
			},
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildGuardianHandler(mindbender)
		},

		Configure {
			'PowerWordFortitude',
			L['Show the number of group members missing @NAME.'],
			21562, -- Power Word: Fortitude
			'group',
			{'GROUP_ROSTER_UPDATE', 'UNIT_AURA'},
			function(units, model)
				local missing = 0
				local shortest
				for unit in next, units.group do
					if UnitIsPlayer(unit) and not UnitIsDeadOrGhost(unit) then
						local found, _, expiration = GetBuff(unit, 21562)
						if found then
							if not shortest or expiration < shortest then
								shortest = expiration
							end
						else
							missing = missing + 1
						end
					end
				end

				if shortest then
					model.expiration = shortest
					model.highlight = 'good'
				end
				if missing > 0 then
					model.count = missing
					model.hint = true
				end
			end,
		},

		Configure {
			'PowerWordShieldRapture',
			format(
				'%s %s',
				BuildDesc('HARMFUL', 'bad', 'ally', 6788), -- Weakened Soul
				BuildDesc('HELPFUL', 'good', 'ally', 17) -- Power Word: Shield
			),
			17, -- Power Word: Shield
			'ally',
			'UNIT_AURA',
			(function()
				return function(units, model)
					local hasRapture = GetPlayerBuff('player', 47536)
					return not hasRapture and hasWeakenedSoul(units, model) or isShielded(units, model)
				end
			end)(),
		}
	}
end)
