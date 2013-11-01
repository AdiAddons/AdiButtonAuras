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
local LibSpellbook = LibStub('LibSpellbook-1.0')
local DRData = LibStub("DRData-1.0")

-- Globals: AddRuleFor Configure IfSpell IfClass SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower SharedSimpleBuffs
-- Globals: BuildAuraHandler_Longest

function addon.CreateRules()
	addon:Debug('Creating Rules')

	-- Build a list of spell ids per DR categories.
	local drspells = {}
	for id, category in pairs(DRData:GetSpells()) do
		if not drspells[category] then
			drspells[category] = {}
		end
		tinsert(drspells[category], id)
	end

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
				132409, -- Spell Lock (sacrified Felhunter)
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
				AddRuleFor(
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
				)
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
				104225, -- Curse of the Elements (warlock, Fire and Brimstone)
				116202, -- Aura of the Elements (warlock)
			},
			{ -- Debuffs to look for
				  1490, -- Curse of the Elements (warlock)
				 24844, -- Lightning Breath (hunter pet ability)
				 34889, -- Fire Breath (hunter pet ability)
				 58410, -- Master Poisoner (rogue)
				104225, -- Curse of the Elements (warlock, Fire and Brimstone)
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

		-- Crowd-control spells, grouped by DR categories
		function()
			for category, spells in pairs(drspells) do
				local handler = nil
				for i, spell in ipairs(spells) do
					local ids = LibSpellbook:GetAllIds(spell)
					if ids then
						if not handler then
							handler = BuildAuraHandler_Longest("HARMFUL", "bad", "enemy", spells)
						end
						for id in pairs(ids) do
							AddRuleFor(id, "enemy", "UNIT_AURA", handler)
						end
					end
				end
			end
		end,

		-- Snares and anti-snares
		-- Note that some of these are talent procs or passive effects.
		-- This is intended as they will show up on active spells anyway.
		LongestDebuffOf {
			{
				  1604, -- Dazed (common),
				 45524, -- Chains of Ice (death knight)
				 50259, -- Dazed (feral charge effect)
				 58180, -- Infected Wounds (druid)
				 61391, -- Typhoon (druid)
				  5116, -- Concussive Shot (hunter)
				 13810, -- Ice Trap (hunter)
				 35101, -- Concussive Barrage (hunter, passive)
				 35346, -- Time Warp (hunter, warp Stalker)
				 50433, -- Ankle Crack (hunter, crocolisk)
				 54644, -- Frost Breath (hunter, chimaera)
				 61394, -- Frozen Wake (hunter, glyph)
				 31589, -- Slow (mage)
				 44614, -- Frostfire Bolt (mage)
				   116, -- Frostbolt (mage)
				   120, -- Cone of Cold (mage)
				  6136, -- Chilled (mage)
				  7321, -- Chilled (mage, bis)
				 11113, -- Blast Wave (mage)
				116095, -- Disable (monk, 1 stack)
				  1044, -- Hand of Freedom (paladin)
				  3409, -- Crippling Poison (rogue)
				 26679, -- Deadly Throw (rogue)
				  3600, -- Earthbind (shaman)
				  8034, -- Frostbrand Attack (shaman)
				  8056, -- Frost Shock (shaman)
				  8178, -- Grounding Totem Effect (shaman)
				 18223, -- Curse of Exhaustion (warlock)
				 17962, -- Conflagrate (warlock)
				  1715, -- Piercing Howl (warrior)
				 12323  -- Hamstring (warrior)
			}
		}, -- Snares and anti-snares

		-- Hunter spells
		IfClass { "HUNTER",
			SimpleBuffs {
				 53271, -- Master's Call
			},
			SimpleDebuffs {
				  1513, -- Scare Beast
				  1978, -- Serpent String
				  3674, -- Black Arrow
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
			SelfBuffAliases {
				-- Deterrence
				{ 19263, 148467 },
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

		-- Warlock spells
		IfClass { "WARLOCK",
			ShowPower {
				{
					17877,  -- Shadowburn
					114635, -- Ember Tap
					108683, -- Fire and Brimstone
					116858, -- Chaos Bolt
				},
				"BURNING_EMBERS",
			},
			ShowPower {
				74434, -- Soulburn
				"SOUL_SHARDS",
			},
			SelfBuffs {
				  6229, -- Twilight Ward
				  7812, -- Sacrifice (voidwalker buff)
				 48018, -- Demonic Circle: Summon
				 80240, -- Havoc
				 91713, -- Nether Ward (talent)
				104025, -- Immolation Aura (demon form)
				104773, -- Unending Resolve
				108416, -- Sacrificial Pact (talent)
				108503, -- Grimoire of Sacrifice (talent)
				108508, -- Mannoroth's Fury (talent)
				108559, -- Demonic Rebirth
				110913, -- Dark Bargain (talent)
				111397, -- Blood Horror (talent)
				113858, -- Dark Soul: Instability
				113860, -- Dark Soul: Misery
				113861, -- Dark Soul: Knowledge
				114635, -- Ember Tap
				116198, -- Aura of Enfeeblement (demon form)
				119839, -- Fury Ward (Dark Apotheosis)
				120451, -- Flames of Xoroth
				132413, -- Shadow Bulwark (Grimoire of Sacrifice)
			},
			SharedSimpleBuffs {
				  5697, -- Unending Breath
				 20707, -- Soulstone
			},
			PetBuffs {
				   755, -- Health Funnel
				  1098, -- Enslave Demon
			},
			SimpleDebuffs {
				   172, -- Corruption
				   603, -- Metamorphosis: Doom
				   980, -- Agony
				 27243, -- Seed of Corruption
				 30108, -- Unstable Affliction
				 48181, -- Haunt
			},
			DebuffAliases {
				{
					   348, -- Immolate
					108686, -- Immolate (Fire and Brimstone)
				},
				348, -- Immolate
			},
			DebuffAliases {
				{
					 17962, -- Conflagrate
					108685, -- Conflagrate (Fire and Brimstone)
				},
				17962, -- Conflagrate
			},
			PassiveModifier {
				117896, -- Backdraft
				{
					 29722, -- Incinerate
					114654, -- Incinerate (Fire and Brimstone)
				},
				117828, -- Backdraft (buff)
			},
			--[[ Check if it already used or not
			PassiveModifier {
				108563, -- Backlash
				 29722, -- Incinerate
				108563, -- Backlash
				"player",
			},
			]]
			PassiveModifier {
				122351, -- Molten Core
				  6353, -- Soul Fire
				122351, -- Molten Core
			},
			DebuffAliases {
				105174, -- Hand of Gul'dan
				 47960, -- Shadowflame
			},
			IfSpell { 123686, -- Pyroclasm
				Configure {
					116858, -- Chaos Bolt
					"player",
					"UNIT_AURA",
					(function()
						local backdraft = GetSpellInfo(117828)
						return function(_, model)
							local name, _, _, count = UnitAura("player", backdraft, nil, "PLAYER HELPFUL")
							if name and count >= 3 then
								model.highlight = "good"
							end
						end
					end)()
				}
			},
		}, -- Warlock spells
	}

end
