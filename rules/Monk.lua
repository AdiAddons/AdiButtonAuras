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

-- Globals: AddRuleFor Configure IfSpell IfClass SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower SharedSimpleBuffs
-- Globals: BuildAuraHandler_Longest ImportPlayerSpells bit BuildAuraHandler_Single
-- Globals: math

AdiButtonAuras:RegisterRules(function(addon)
	addon.Debug('Rules', 'Adding monk rules')

	return {
		ImportPlayerSpells {
			-- Import all spells for ...
			"MONK",
			-- ... but ...
			115151, -- Renewing Mist
			116670, -- Uplift
			116680, -- Thunder Focus Tea
			119582, -- Purifying Brew
			123273, -- Surging Mist
			134563, -- Healing Elixirs (buff)
		},
		ShowPower {
			-- Show current Chi on generators and 3-chi spenders
			{
				100780, -- Jab (glyphed)
				101546, -- Spinning Crane Kick
				115072, -- Expel Harm
				115080, -- Touch of Death
				115175, -- Soothing Mist
				115693, -- Jab
				116670, -- Uplift
				116847, -- Rushing Jade Wind
				117952, -- Crackling Jade Lightning
				124682, -- Enveloping Mist
			},
			"CHI",
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
	}

end)
