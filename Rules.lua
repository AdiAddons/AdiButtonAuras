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
			function(units, model)
				local unit = units.enemy
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
			for spell, dispelType in LibDispellable:IterateDispelSpells() do
				local spell, offensive = spell, (dispelType ~= 'defensive')
				local unit = offensive and 'enemy' or 'ally'
				AddRuleFor(
					spell,
					unit,
					"UNIT_AURA",
					function(units, model)
						for i, dispel, _, _, _, count, _, _, expiration in LibDispellable:IterateDispellableAuras(units[unit], offensive) do
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

		-- Bloodlust & al
		Configure {
			{
				 2825, -- Bloodlust (Horde shaman)
				32182, -- Heroism (Alliance shaman)
				80353, -- Time Warp (mage)
				90355, -- Ancient Hysteria (hunter exotic pet ability)
				"item:102351", -- Drums of Rage
			},
			"ally",
			"UNIT_AURA",
			(function()
				local hasBloodlust = BuildAuraHandler_Longest("HELPFUL", "good", "ally",{
					  2825, -- Bloodlust (Horde shaman)
					 32182, -- Heroism (Alliance shaman)
					 80353, -- Time Warp (mage)
					 90355, -- Ancient Hysteria (hunter exotic pet ability)
					146555, -- Drums of Rage
				})
				local isSated = BuildAuraHandler_Longest("HARMFUL", "bad", "ally", {
					 57724, -- Sated (Bloodlst/Heroism debuff),
					 80354, -- Temporal Displacement (Time Warp debuff)
					 95809  -- Insanity (Ancient Hysteria debuff)
				})
				return function(units, model)
					return hasBloodlust(units, model) or isSated(units, model)
				end
			end)(),
		},

		-- Druid spells
		IfClass { "DRUID",
			SimpleBuffs {
				   774, -- Rejuvenation
				  8936, -- Regrowth
				 29166, -- Innervate
				 33763, -- Lifebloom
				 48438, -- Wild Growth
				102342, -- Ironbark
			},
			SimpleDebuffs {
				  1079, -- Rip
				  1822, -- Rake
				  8921, -- Moonfire
				 33745, -- Lacerate
				 77758, -- Thrash (guardian druid)
				 93402, -- Sunfire
				106830, -- Thrash (feral druid)
			},
			SelfBuffs {
				  1850, -- Dash
				  5217, -- Tiger's Fury
				  5229, -- Enrage
				 16689, -- Nature's Grasp
				 22812, -- Barkskin
				 22842, -- Frenzied Regeneration
				 48505, -- Starfall
				 52610, -- Savage Roar
				 61336, -- Survival Instincts
				 62606, -- Savage Defense
				106922, -- Might of Ursoc
				106952, -- Berserk
				108288, -- Heart of the Wild
				110309, -- Symbiosis
				112071, -- Celestial Alignment
				114107, -- Soul of the Forest
				124974, -- Nature's Vigil
			},
			BuffAliases {
				50464, -- Nourish
				96206, -- Glyph of Rejuvenation
			},
			BuffAliases {
				145518, -- Genesis
				   774, -- Rejuvenation
			},
			PassiveModifier {
				113043, -- Omen of Clarity
				{
					8936, -- Regrowth
					5176, -- Wrath
					5185, -- Healing Touch

				},
				16870, -- Clearcasting
				"player",
				"flash"
			},
			PassiveModifier {
				114107, -- Soul of the Forest
				 18562, -- Swiftmend
				114108, -- Soul of the Forest (restoration)
				"player",
				"flash"
			},
			SelfBuffAliases {
				{ 77761, 77764, 106898 }, -- Stampeding Roar
			},
			Configure {
				{
					  1079, -- Rip
					 22568, -- Ferocious Bite
					 22570, -- Maim
					 52610, -- Savage Roar
				},
				{ "enemy", "player" },
				"UNIT_COMBO_POINTS",
				function(units, model)
					if not units.enemy then return end
					local points = GetComboPoints("player", units.enemy)
					if points and points > 0 then
						model.count = points or 0
						if points == 5 then
							model.highlight = "flash"
						end
						return true
					end
				end,
			},
			IfSpell { 77495, -- Mastery: Harmony
				Configure {
					50464, -- Nourish
					"player",
					{ "UNIT_AURA", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED" },
					(function()
						local harmonyBuff = GetSpellInfo(100977) -- Harmony
						return function(units, model)
							if InCombatLockdown() and not UnitAura("player", harmonyBuff, nil, "HELPFUL PLAYER") then
								model.highlight = "flash"
								return true
							end
						end
					end)()
				},
			},
			IfSpell { 79577, -- Eclipse (passive)
				Configure {
					5176, -- Wrath
					"player",
					{ "UNIT_POWER_FREQUENT", "ECLIPSE_DIRECTION_CHANGE" },
					function(units, model)
						if GetEclipseDirection() ~= "sun" then
							model.highlight = "lighten"
							model.count = -UnitPower("player", SPELL_POWER_ECLIPSE)
						else
							model.highlight = "darken"
						end
					end,
				},
				Configure {
					2912, -- Starfire
					"player",
					{ "UNIT_POWER_FREQUENT", "ECLIPSE_DIRECTION_CHANGE" },
					function(units, model)
						if GetEclipseDirection() ~= "moon" then
							model.highlight = "lighten"
							model.count = UnitPower("player", SPELL_POWER_ECLIPSE)
						else
							model.highlight = "darken"
						end
					end,
				}
			},
			PassiveModifier {
				16864, -- Omen of Clarity
				{
					5221, -- Shred
				},
				16870, -- Clearcasting
				"player",
				"flash"
			},
			PassiveModifier {
				16974, -- Predatory Swiftness (passive)
				{
					 5185, -- Healing Touch
					 2637, -- Hibernate
					20484, -- Rebirth
				},
				69369, -- Predatory Swiftness (buff)
				"player",
				"flash"
			},
		}, -- Druid spells

		-- Hunter spells
		IfClass { "HUNTER",
			SimpleBuffs {
				 53271, -- Master's Call
			},
			SimpleDebuffs {
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
				107428, -- Rising Sun Kick
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
					100780, -- Jab (glyphed)
					115175, -- Soothing Mist
					101546, -- Spinning Crane Kick
					115072, -- Expel Harm
					117952, -- Crackling Jade Lightning
				},
				129914, -- Power Strikes (buff)
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
			}
		}, -- Monk spells

		-- Priest spells
		IfClass { "PRIEST",
			SelfBuffs {
				   586, -- Fade
				 10060, -- Power Infusion
				 15286, -- Vampiric Embrace
				 47585, -- Dispersion
				 73413, -- Inner Will
				 89485, -- Inner Focus
				109964, -- Spirit Shell
				112833, -- Spectral Guise
			},
			SimpleBuffs {
				   139, -- Renew
				 33076, -- Prayer of Mending
			},
			SharedSimpleBuffs {
				  1706, -- Levitate
				  6346, -- Fear Ward
				 47788, -- Guardian Spirit -- can be stacked but this is not advised
				  6346, -- Pain Suppression --  can be stacked but this is not advised
			},
			SimpleDebuffs {
				   589, -- Shadow Word: Pain
				  2944, -- Devouring Plague
				 34914, -- Vampiric Touch
				 14914, -- Holy Fire
				129250, -- Power Word: Solace
			},
			ShowPower {
				{
					 2944, -- Devouring Plague
					64044, -- Psychic Horror
				},
				"SHADOW_ORBS",
			},
			PassiveModifier {
				63733, -- Serendipity
				{
					2060, -- Greater Heal
					 596, -- Prayer of Healing
				},
				63735, -- Serendipity (buff)
			},
			PassiveModifier {
				81662, -- Evangelism
				81700, -- Archangel
				81662, -- Evangelism
			},
			PassiveModifier {
				109186, -- From Darkness, Comes Light
				  2061, -- Flash Heal
				114255, -- Surge of Light
			},
			Configure {
			    17, -- Power Word: Shield
				"ally",
				"UNIT_AURA",
				(function()
					local hasPWShield = BuildAuraHandler_Single("HELPFUL", "good", "ally", 17)
					local hasWeakenedSoul = BuildAuraHandler_Single("HARMFUL", "bad", "ally", 6788)
					return function(units, model)
						return hasPWShield(units, model) or hasWeakenedSoul(units, model)
					end
				end)(),
			},
		}, -- Priest spells

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
