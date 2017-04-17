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

if not addon.isClass("MONK") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding monk rules')

	return {
		ImportPlayerSpells { "MONK" },

		Configure {
			"InvokePets",
			L["Show the duration of @NAME."],
			{
				123904, -- Invoke Xuen, the White Tiger
				132578, -- Invoke Niuzao, the Black Ox
				198664, -- Invoke Chi-Ji, the Red Crane
			},
			"player",
			"UNIT_PET",
			function(_, model)
				local remaining = GetPetTimeRemaining()
				if remaining then
					model.expiration = GetTime() + remaining / 1000
					model.highlight = "good"
				end
			end,
		},

		Configure {
			"Statues",
			L["Show the duration of your summoned statue."],
			{
				115313, -- Summon Jade Serpent Statue
				115315, -- Summon Black Ox Statue
			},
			"player",
			"PLAYER_TOTEM_UPDATE",
			function(_, model)
				local found, _, start, duration = GetTotemInfo(1) -- monks have only one totem
				if found then
					model.highlight = "good"
					model.expiration = start + duration
				end
			end,
		},
		Configure {
			"TouchOfDeathHint",
			L["Show hint when Touch of Death can be cast."],
			115080, -- Touch of Death
			"player",
			"UNIT_AURA",
			function(_, model)
				local found, _, _ = GetPlayerBuff("player", 121125) -- Death Note
				if found then
					model.hint = true
				end
			end,
		},
	}
end)
