--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013 Adirelle (adirelle@gmail.com)
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

if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local addonName, addon = ...

AdiButtonAuras:RegisterRules(function()
	Debug('Adding deathknight rules')
	return {
		ImportPlayerSpells {
		-- Import all spells for ...
			"DEATHKNIGHT",
		-- ... but ...
			115635, -- Death Barrier
			114851, -- Blood Charge
			 50421, -- Scent of Blood
			 81141, -- Crimson Scourge
			 51124, -- Killing Machine
			 59052, -- Freezing Fog
			 81340, -- Sudden Doom
			 91342, -- Shadow Infusion
		},
		Configure {
			"Soul Reaper",
			L["Shows Hint when target is below 35% health."],
			{
				114866, -- Soul Reaper (Blood)
				130735, -- Soul Reaper (Frost)
				130736, -- Soul Reaper (Unholly)
			}, 
			"target",
			{ "UNIT_HEALTH", "UNIT_HEALTH_MAX" },
			function(_, model)
				if UnitHealth("target") / UnitHealthMax("target") < 0.35 then
					model.hint = true
				end
			end,
		}
	}
end)
