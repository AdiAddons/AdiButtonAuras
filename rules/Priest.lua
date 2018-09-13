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

	return {
		ImportPlayerSpells {
			-- import all spells for
			'PRIEST',
			-- except for
			   605, -- Mind Control
			 21562, -- Power Word: Fortitude
			194384, -- Atonement (Discipline)
			193223, -- Surrender to Madness (Shadow)
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
			123040, -- Mindbender (Discipline/Shadow talent)
			'player',
			'PLAYER_TOTEM_UPDATE',
			BuildGuardianHandler(mindbender)
		},

		-- track Atonement on Shadow Mend
		-- NOTE: Shadow Mend is used as the display spell because:
		-- - Power Word: Shield tracks itself
		-- - Power Word: Radiance has charges
		-- - the debuff from Shadow Mend is not that important
		Configure {
			'AtonementTracker',
			format(L['Show the shortest duration and the number of group members with %s.'], GetSpellInfo(194384)), -- Atonement
			186263, -- Shadow Mend (Discipline)
			'group',
			{'GROUP_ROSTER_UPDATE', 'UNIT_AURA'},
			function(units, model)
				local count, minExpiration = 0
				for unit in next, units.group do
					local found, _, expiration = GetPlayerBuff(unit, 194384)
					if found then
						count = count + 1
						if (not minExpiration or expiration < minExpiration) then
							minExpiration = expiration
						end
					end
				end
				if count > 0 then
					model.count = count
					model.expiration = minExpiration
				end
			end,
			81749, -- Atonement (Discipline)
		},

		Configure {
			'SurrenderToDarkness',
			format(
				'%s %s',
				BuildDesc('HELPFUL PLAYER', 'good', 'player', 193223), -- Surrender to Madness
				BuildDesc('HARMFUL PLAYER', 'bad', 'player', 263406) -- Surrendered to Madness
			),
			193223, -- Surrender to Madness (Shadow)
			'player',
			'UNIT_AURA',
			(function()
				local isSurrendering = BuildAuraHandler_Single('HELPFUL PLAYER', 'good', 'player', 193223)
				local hasSurrendered = BuildAuraHandler_Single('HARMFUL PLAYER', 'bad', 'player', 263406)
				return function(units, model)
					return isSurrendering(units, model) or hasSurrendered(units, model)
				end
			end)(),
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
	}
end)
