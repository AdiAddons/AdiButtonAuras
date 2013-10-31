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

local addonName, addon = ...

local _G = _G
local pairs = _G.pairs
local GetSpellInfo = _G.GetSpellInfo
local UnitAura = _G.UnitAura
local UnitCanAttack = _G.UnitCanAttack
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo

local LibDispellable = LibStub('LibDispellable-1.0')

-- Globals: AddRuleFor Configure IfSpells IfClass SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower

function addon.CreateRules()

	addon:Debug('Creating Rules')
	return {

		-- Interrupts: use a custom configuration
		Configure {
			{ -- Spells
				-- Deathknight
				 47476, -- Strangulate
				 47528, -- Mind Freeze
				 91802, -- Shambling Rush (Ghoul)
				-- Druid
				 78675, -- Solar Beam
				 80964, -- Skull Bash (bear)
				 80965, -- Skull Bash (cat)
				-- Hunter
				 26090, -- Pummel (Gorilla)
				 34490, -- Silencing Shot
				 50318, -- Serenity Dust (Moth)
				 50479, -- Nether Shock (Nether Ray)
				147362, -- Counter Shot
				-- Mage
				  2139, -- Counterspell
				-- Monk
				116705, -- Spear Hand Strike
				-- Paladin
				 96231, -- Rebuke
				-- Priest
				 15487, -- Silence
				-- Rogue
				  1766, -- Kick
				-- Shaman
				 57994, -- Wind Shear
				-- Warlock
				 19647, -- Spell Lock (Felhunter)
				103967, -- Carrion Swarm (demon form)
				119911, -- Optical Blast (Observer special ability)
				-- Warrior
				  6552, -- Pummel
			},
			-- Unit
			"enemy",
			{ -- Events
				"UNIT_SPELLCAST_CHANNEL_START",
				"UNIT_SPELLCAST_CHANNEL_STOP",
				"UNIT_SPELLCAST_CHANNEL_UPDATE",
				"UNIT_SPELLCAST_DELAYED",
				"UNIT_SPELLCAST_INTERRUPTIBLE",
				"UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
				"UNIT_SPELLCAST_START",
				"UNIT_SPELLCAST_STOP",
			},
			-- Handler
			function(unit, model)
				if UnitCanAttack("player", unit) then
					local name, _, _, _, _, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
					if name and not notInterruptible then
						model.highlight, model.expiration = "flash", endTime / 1000
					end
					name, _, _, _, _, endTime, _, notInterruptible = UnitChannelInfo(unit)
					if name and not notInterruptible then
						model.highlight, model.expiration = "flash", endTime / 1000
					end
				end
			end
		}, -- Interrupts

		-- Dispels, using LibDispellable
		function()
			for spell, dispelType in pairs(LibDispellable.spells) do
				local spell, offensive = spell, (dispelType ~= 'defensive')
				AddRuleFor {
					spell,
					offensive and 'enemy' or 'ally',
					"UNIT_AURA",
					function(unit, model)
						for i, dispel, _, _, _, count, _, _, expiration in LibDispellable:IterateDispellableAuras(unit, offensive) do
							if dispel == spell then
								model.highlight, model.count, model.expiration = "bad", count, expiration
								return
							end
						end
					end
				}
			end
		end, -- Dispels

		-- Some shared debuffs, only show them on spells that requires the player to specifically cast them

		-- Physical Vulnerability is applied passively or automatically, don't bother showing it

		-- Mortal Wounds
		LongestDebuffOf {
			{ -- Spells to alter
				 82654, -- Widow Venom (hunter)
			},
			{ -- Debuffs to look for
				  8679, -- Wound Poison (rogue)
				 30213, -- Legion Strike (warlock pet)
				 54680, -- Monstrous Bite (hunter exotic pet ability)
				 82654, -- Widow Venom (hunter)
				115804, -- Mortal Wounds (main effect)
			},
		}, -- Mortal Wounds

		-- Weakened Armor
		LongestDebuffOf {
			{ -- Spells to alter
				   770, -- Faerie Fire (druid)
				  7386, -- Sunder Armor (warrior)
				  8647, -- Expose Armor (rogue)
				 20243, -- Devastate (warrior)
				102355, -- Faerie Swarm (druid)
			},
			{ -- Debuffs to look for
				113746, -- Weakened Armor (main effect)
			}
		}, -- Weakened Armor

		-- +5% spell damage taken
		LongestDebuffOf {
			{ -- Spells to alter
				  1490, -- Curse of the Elements (warlock)
				116202, -- Aura of the Elements (warlock)
			},
			{ -- Debuffs to look for
				  1490, -- Curse of the Elements (warlock)
				 24844, -- Lightning Breath (hunter pet ability)
				 34889, -- Fire Breath (hunter pet ability)
				 58410, -- Master Poisoner (rogue)
				116202, -- Aura of the Elements (warlock)
			}
		}, -- +5% spell damage taken

		-- Increasing Casting Time
		LongestDebuffOf {
			{ -- Spells to alter
				 73975, -- Necrotic Strike (death knight)
				109466, -- Curse of Enfeeblement (warlock)
				116198, -- Aura of Enfeeblement (warlock)
			},
			{ -- Debuffs to look for
				 50274, -- Spore Cloud (hunter pet ability)
				 58604, -- Lava Breath (hunter pet ability)
				 73975, -- Necrotic Strike (death knight)
				 90314, -- Tailspin (hunter pet ability)
				109466, -- Curse of Enfeeblement (warlock)
				116198, -- Aura of Enfeeblement (warlock)
				126402, -- Trample (hunter pet ability)
			}
		}, -- Increasing Casting Time

		-- Weakened Blows
		LongestDebuffOf {
			{ -- Spells to alter
				106830, -- Thrash (feral druid)
				 77758, -- Thrash (guardian druid)
				121253, -- Keg Smash (monk)
				  6343, -- Thunder Clap (warrior)
				-- 81132, -- Scarlet Fever (deathknight), this is a passive that modifies Blood Boil
				  8042, -- Earth Shock (shaman)
				 53595, -- Hammer of the Righteous (paladin)
			},
			{ -- Debuffs to look for
				115798, -- Weakened Blows (main effect)
				 50256, -- Demoralizing Roar (hunter pet ability)
				 24423, -- Demoralizing Screech (hunter pet ability)
			}
		}, -- Weakened Blows

		-- Hunter spells
		IfClass { "HUNTER",
			SimpleBuffs {
				 53271, -- Master's Call
			},
			SimpleDebuffs {
				  1513, -- Scare Beast
				  1978, -- Serpent String
				  3674, -- Black Arrow
				  5116, -- Concussive Shot
				 19386, -- Wyvern Sting
				 20736, -- Distracting Shot
				131894, -- A Murder of Crows
			},
			PetBuffs {
				   136, -- Mend Pet
				 19574, -- Bestial Wrath
			},
			SelfBuffs {
				  3045, -- Rapid Fire
				 34477, -- Misdirection
				 51753, -- Camouflage
				 82726, -- Fervor
			},
			DebuffAliases { -- Freezing Trap
				{ 1499, 60192 },
				3355
			},
			SelfBuffAliases { -- Deterrence
				{ 19263, 148467 },
				{ 19263, 148467 }
			},
			SharedSimpleDebuffs {
				  1130, -- Hunter's Mark
			},
			PassiveModifier {
				34487, -- Master Marksman
				19434, -- Aimed Shot
				82925  -- Ready, Set, Aim...
			},
			PassiveModifier {
				53224, -- Steady Focus
				56641, -- Steady Shot
				53220  -- Steady Focus (buff)
			},
			PassiveModifier {
				nil,
				82692, -- Focus Fire
				19623, -- Frenzy
				"pet",
			},
		}, -- Hunter spells

		-- Monk spells
		IfClass { "MONK",
			SelfBuffs {
				100784, -- Guard
				115203, -- Fortifying Brew
				115213, -- Avert Harm
				115288, -- Energizing Brew
				115308, -- Elusive Brew
				116740, -- Tigereye Brew
				116844, -- Ring of Peace
				122278, -- Dampen Harm
				122470, -- Touch of Karma
				122783, -- Diffuse Magic
				137562, -- Nimble Brew
			},
			SimpleDebuffs {
				116095, -- Disable
			},
			PassiveModifier {
				nil,
				100787, -- Tiger Palm
				125359, -- Tiger Power
			},
			DebuffAliases {
				115181, -- Breath of Fire
				123725, -- Breath of Fire (debuff)
			},
			DebuffAliases {
				{
					115180, -- Dizzying Haze
					121253, -- Keg Smash
				},
				115180, -- Dizzying Haze
			},
			PassiveModifier {
				117967, -- Brewmaster Training
				115295, -- Guard
				118636, -- Power Guard
				"player",
				"none", -- Already flashing
			},
			PassiveModifier {
				117967, -- Brewmaster Training
				100784, -- Blackout Kick
				115307, -- Shuffle
			},
			PassiveModifier {
				123980, -- Brewing: Tigereye Brew
				116740, -- Tigereye Brew
				125195, -- Tigereye Brew (stacking buff)
			},
			PassiveModifier {
				128938, -- Brewing: Elusive Brew
				115308, -- Elusive Brew
				128939, -- Elusive Brew (stacking buff)
			},
			PassiveModifier {
				121817, -- Power Strikes (talent)
				{
					115693, -- Jab
					115175, -- Soothing Mist
					101546, -- Spinning Crane Kick
					115072, -- Expel Harm
					117952, -- Crackling Jade Lightning
				},
				129914, -- Power Strikes (buff)
			},
		}, -- Monk spells

	}

end
