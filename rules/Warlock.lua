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

if not addon.isClass("WARLOCK") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding warlock rules')

	local function BuildTotemHandler(texture)
		return function(_, model)
			for slot = 1, 5 do
				local found, _, start, duration, tex = GetTotemInfo(slot)
				if found and tex == texture then
					model.highlight = "good"
					model.expiration = start + duration
					break
				end
			end
		end
	end

	return {
		ImportPlayerSpells { "WARLOCK" },

		ShowPower {
			{
				  5740, -- Rain of Fire
				 17887, -- Shadowburn
				 27243, -- Seed of Corruption
				 30108, -- Unstable Affliction
				104316, -- Call Dreadstalkers
				105174, -- Hand of Gul'dan
				116858, -- Chaos Bolt
			},
			"SoulShards",
		},

		Configure {
			"BurningRush",
			L["Show your current health percentage."],
			111400, -- Burning Rush
			"player",
			{ "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_AURA" },
			function(_, model)
				local hasBurningRush = GetPlayerBuff("player", 111400)
				if hasBurningRush then
					local maxHealth = UnitHealthMax("player")
					if maxHealth <= 0 then return end
					model.count = floor(UnitHealth("player") / maxHealth * 100 + 0.5)
				end
			end,
		},

		Configure {
			"Dreadstalkers",
			L["Show the duration of your Dreadstalkers."],
			104316,
			"player",
			"PLAYER_TOTEM_UPDATE",
			BuildTotemHandler("Interface\\Icons\\spell_warlock_calldreadstalkers")
		},

		Configure {
			"WildImps",
			L["Show the duration of your Wild Imps."],
			105174,
			"player",
			"PLAYER_TOTEM_UPDATE",
			BuildTotemHandler("Interface\\Icons\\spell_warlock_summonimpoutland")
		},
	}
end)
