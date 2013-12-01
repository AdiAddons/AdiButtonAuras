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

if select(2, UnitClass("player")) ~= "MONK" then return end

-- Globals: AddRuleFor Configure IfSpell SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower SharedSimpleBuffs
-- Globals: BuildAuraHandler_Longest ImportPlayerSpells bit BuildAuraHandler_Single
-- Globals: math

AdiButtonAuras:RegisterRules(function(addon)
	addon.Debug('Rules', 'Adding monk rules')

	local L = addon.L

	return {
		ImportPlayerSpells {
			-- Import all spells for ...
			"MONK",
			-- ... but ...
			115151, -- Renewing Mist
			115294, -- Mana Tea
			116670, -- Uplift
			116680, -- Thunder Focus Tea
			119582, -- Purifying Brew
			123273, -- Surging Mist
			123761, -- Mana Tea (glyphed)
			134563, -- Healing Elixirs (buff)
		},
		ShowPower {
			-- Show current Chi on spenders and flash when reaching maximum
			{
				100784, -- Blackout Kick
				107428, -- Rising Sun Kick
				113656, -- Fists of Fury
				115181, -- Breath of Fire
				116670, -- Uplift
				124682, -- Enveloping Mist
			},
			"CHI",
			nil,
			"flash"
		},
		DebuffAliases {
			121253, -- Keg Smash
			115180, -- Dizzying Haze
		},
		PassiveModifier {
			116645, -- Teachings of the Monastery
			123273, -- Surging Mist
			118674, -- Vital Mists
			"player",
			"none"
		},
		IfSpell { 122280, -- Healing Elixirs (passive)
			Configure {
				"HealingElixirs",
				addon.BuildDesc("HELPFUL PLAYER", "good", "player", 122280),
				{
					115203, -- Fortifying Brew
					115288, -- Energizing Brew
					115294, -- Mana Tea
					115308, -- Elusive Brew
					115399, -- Chi Brew
					116680, -- Thunder Focus Tea
					116740, -- Tigereye Brew
					119582, -- Purifying Brew
					137562, -- Nimble Brew
				},
				"player",
				"UNIT_AURA",
				(function()
					local healingElixirs = GetSpellInfo(134563) -- Healing Elixirs (buff)
					return function(units, model)
						if UnitBuff("player", healingElixirs) then
							model.highlight = "good"
						end
					end
				end)(),
			}
		},
		Configure {
			"PurifyingBrew",
			format(L["Show %s."], L["stagger level"]),
			119582, -- Purifying Brew
			"player",
			{ "UNIT_AURA", "UNIT_HEALTH_MAX" },
			(function()
				local light, moderate, heavy = GetSpellInfo(124275), GetSpellInfo(124274), GetSpellInfo(124273)
				return function(units, model)
					local amount = select(15, UnitDebuff("player", light))
					if not amount then
						amount = select(15, UnitDebuff("player", moderate))
						if amount then
							model.highlight = "bad"
						else
							amount = select(15, UnitDebuff("player", heavy))
							if amount then
								model.highlight = "flash"
							end
						end
					end
					if amount then
						model.count = ceil(amount / UnitHealthMax("player") * 100)
					end
				end
			end)(),
		},
		Configure {
			"ManaTea",
			format(addon.L["%s on @NAME when it would not be wasted."], addon.DescribeHighlight("good")),
			{
				115294, -- Mana Tea
				123761, -- Mana Tea (glyphed)
			},
			"player",
			{ "UNIT_AURA", "UNIT_POWER", "UNIT_POWER_MAX" },
			(function()
				local buff = GetSpellInfo(115867) -- Mana Tea (stacking buff)
				return function(_, model)
					local name, _, _, count, _, _, expiration = UnitAura("player", buff, nil, "HELPFUL PLAYER")
					if name then
						model.expiration = expiration
						local mana, manaMax = UnitPower("player", SPELL_POWER_MANA), UnitPowerMax("player", SPELL_POWER_MANA)
						addon.Debug('ManaTea', count, mana, manaMax, floor(100 * (manaMax-mana) / manaMax))
						if count >= 19 and mana < manaMax then
							model.highlight = "flash"
						elseif 0.04 * min(2, count) <= (manaMax-mana) / manaMax then
							model.highlight = "good"
						end
					end
				end
			end)()
		},
	}

end)
