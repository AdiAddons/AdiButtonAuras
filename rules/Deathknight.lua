--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2014 Adirelle (adirelle@gmail.com)
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

if not addon.isClass("DEATHKNIGHT") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding deathknight rules')
	return {
		ImportPlayerSpells {
		-- Import all spells for ...
			"DEATHKNIGHT",
		-- ... but ...
			114851, -- Blood Charge
			 59052, -- Freezing Fog
			 51124, -- Killing Machine
			 91342, -- Shadow Infusion
			 81340, -- Sudden Doom
			--  81141, -- Crimson Scourge
			-- 115635, -- Death Barrier
			--  50421, -- Scent of Blood
		},
		Configure {
			"Blood Charge",
			format(L["%s when you have 6 or more stacks of %s."], DescribeHighlight("flash"), GetSpellInfo(114851)),
			45529, -- Blood Tap
			"player",
			"UNIT_AURA",
			function(_, model)
				local found, count = GetPlayerBuff("player", 114851) -- Blood Charge
				if found and count >= 5 then
					model.highlight = "flash"
				end
			end,
			45529, -- Provided by: Blood Tap
		},
		Configure {
			"Soul Reaper",
			L["Shows Hint when target is below 35% health."],
			{
				114866, -- Soul Reaper (Blood)
				130735, -- Soul Reaper (Frost)
				130736, -- Soul Reaper (Unholy)
			},
			"enemy",
			{ "UNIT_HEALTH", "UNIT_HEALTH_MAX" },
			function(units, model)
				if UnitHealth(units.enemy) / UnitHealthMax(units.enemy) < 0.35 then
					model.hint = true
				end
			end,
		}
	}
end)
