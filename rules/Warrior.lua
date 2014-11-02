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

if not addon.isClass("WARRIOR") then return end

AdiButtonAuras:RegisterRules(function()
	Debug('Adding warrior rules')

	return  {
		ImportPlayerSpells { "WARRIOR" },

		-- Shield Barrier
		Configure {
			"Shield Barrier",
			L['Suggest using Shield Barrier at 60 Rage or more. Flash at maximum Rage.'],
			112048, -- Shield Barrier
			"player",
			"UNIT_POWER_FREQUENT",
			function(_, model)
				if UnitPower("player") == UnitPowerMax("player") then -- UnitPower defaults to Rage for Warrior anyway
					model.highlight = "flash"
				elseif UnitPower("player") >= 60 then
					-- model.highlight = "flash"
					model.hint = true
				end
			end,
			112048, -- Show for Protection Only (Shield Barrier)
		},

		-- Rend
		Configure {
			"RefreshRend",
			format(
			L["%s when %s should be refreshed on %s."],
			DescribeHighlight("flash"), -- hint or flash
			GetSpellInfo(772),          -- Rend
			DescribeAllTokens("enemy")  -- enemy string
			),
			772, -- Rend
			"enemy",
			{ "UNIT_AURA", "UNIT_COMBAT" }, -- fast enough to be usable
			(function()
				local hasRend = BuildAuraHandler_Single("HARMFUL", nil, "enemy", 772)
				return function(units, model)
					if hasRend(units, model) then
						local rendDuration = 18                              -- Rend lasts 18s
						local refreshWindow = rendDuration*0.3               -- New 30% rule for WoD ticks
						model.highlight = "bad"                              -- add standard bad border
						if model.expiration - GetTime() < refreshWindow then -- abuse sub 30% double tick mechanic :)
							-- model.hint =  true                            -- hint
							model.highlight = "flash"                        -- flash is better for this
						end
					end
				end
			end)(),
			772, -- Rend, Arms Only
		},

		-- Execute
		Configure {
			"Execute",
			L["Show a hint when the target is below 20% health."],
			{ 5308, 163201, }, -- Execute
			"enemy",
			{ "UNIT_HEALTH", "UNIT_HEALTH_MAX" },
			function(units, model)
				if UnitHealth(units.enemy) / UnitHealthMax(units.enemy) <= 0.20 then
					-- model.hint = true
					model.highlight = "flash"
				end
			end,
		},
	}
end)

-- GLOBALS: AddRuleFor BuffAliases BuildAuraHandler_FirstOf BuildAuraHandler_Longest
-- GLOBALS: BuildAuraHandler_Single BuildDesc BuildKey Configure DebuffAliases Debug
-- GLOBALS: DescribeAllSpells DescribeAllTokens DescribeFilter DescribeHighlight
-- GLOBALS: DescribeLPSSource GetComboPoints GetEclipseDirection GetNumGroupMembers
-- GLOBALS: GetShapeshiftFormID GetSpellBonusHealing GetSpellInfo GetTime
-- GLOBALS: GetTotemInfo HasPetSpells ImportPlayerSpells L LongestDebuffOf
-- GLOBALS: PLAYER_CLASS PassiveModifier PetBuffs SelfBuffAliases SelfBuffs
-- GLOBALS: SharedSimpleBuffs SharedSimpleDebuffs ShowPower SimpleBuffs
-- GLOBALS: SimpleDebuffs UnitCanAttack UnitCastingInfo UnitChannelInfo UnitClass
-- GLOBALS: UnitHealth UnitHealthMax UnitIsDeadOrGhost UnitIsPlayer UnitPower
-- GLOBALS: UnitPowerMax UnitStagger bit ceil floor format ipairs math min pairs
-- GLOBALS: print select string table tinsert GetPlayerBuff
