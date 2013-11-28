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

-- Globals: AddRuleFor Configure IfSpell IfClass SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower SharedSimpleBuffs
-- Globals: BuildAuraHandler_Longest ImportPlayerSpells bit BuildAuraHandler_Single
-- Globals: math

function addon.CreateRules()
	addon:Debug('Creating Rules')

	local _G = _G
	local GetComboPoints = _G.GetComboPoints
	local GetEclipseDirection = _G.GetEclipseDirection
	local GetSpellInfo = _G.GetSpellInfo
	local InCombatLockdown = _G.InCombatLockdown
	local SPELL_POWER_ECLIPSE = _G.SPELL_POWER_ECLIPSE
	local UnitAura = _G.UnitAura
	local UnitBuff = _G.UnitBuff
	local UnitCanAttack = _G.UnitCanAttack
	local UnitCastingInfo = _G.UnitCastingInfo
	local UnitChannelInfo = _G.UnitChannelInfo
	local UnitDebuff = _G.UnitDebuff
	local UnitHealthMax = _G.UnitHealthMax
	local UnitPower = _G.UnitPower
	local ceil = _G.ceil
	local ipairs = _G.ipairs
	local pairs = _G.pairs
	local select = _G.select
	local tinsert = _G.tinsert

	local _, playerClass = UnitClass("player")

	local rules = {

	--------------------------------------------------------------------------
	-- Start of rules
	--------------------------------------------------------------------------

	--------------------------------------------------------------------------
	-- Shared debuffs
	--------------------------------------------------------------------------
	-- Only show them on spells that requires the player to specifically cast them

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

	--------------------------------------------------------------------------
	-- Snares and anti-snares
	--------------------------------------------------------------------------
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

	--------------------------------------------------------------------------
	-- Bloodlust & al
	--------------------------------------------------------------------------

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

	--------------------------------------------------------------------------
	-- Druid
	--------------------------------------------------------------------------

		IfClass { "DRUID",
			ImportPlayerSpells {
				-- Import all spells for ...
				"DRUID",
				-- ... but ...
				 50464, -- Nourish
				145518, -- Genesis
				 16870, -- Clearcasting
				114108, -- Soul of the Forest (restoration)
				 16974, -- Predatory Swiftness (passive)
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
			Configure {
				{
					  1079, -- Rip
					 22568, -- Ferocious Bite
					 22570, -- Maim
					 52610, -- Savage Roar
					127538, -- Savage Roar (glyphed)
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
			ShowPower {
				5217, -- Tiger's Fury
				"ENERGY",
				35,
				"darken"
			},
		},

	--------------------------------------------------------------------------
	-- Hunter
	--------------------------------------------------------------------------

		IfClass { "HUNTER",
			ImportPlayerSpells { "HUNTER" }
		},

	--------------------------------------------------------------------------
	-- Monk
	--------------------------------------------------------------------------

		IfClass { "MONK",
			ImportPlayerSpells {
				-- Import all spells for ...
				"MONK",
				-- ... but ...
				115151, -- Renewing Mist
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
			(function()
				local units = { "player" }
				for i = 1, 4 do tinsert(units, "party"..i) end
				for i = 1, 40 do tinsert(units, "raid"..i) end
				--numGroupMembers = GetNumGroupMembers( [groupType] )
				local buff = GetSpellInfo(115151) -- Renewing Mist
				local count, shortest
				local function ScanUnit(unit)
					local name, _, _, _, _, _, expiration = UnitAura(unit, buff, nil, "HELPFUL PLAYER")
					if name then
						count = count + 1
						if not shortest or expiration < shortest then
							shortest = expiration
						end
					end
				end
				return Configure {
					115151, -- Renewing Mist
					units,
					{ "UNIT_AURA", "GROUP_ROSTER_UPDATE" },
					function(_, model)
						count, shortest = 0, nil
						if IsInRaid() then
							for i = 1, GetNumGroupMembers() do
								ScanUnit("raid"..i)
							end
						else
							ScanUnit("player")
							for i = 1, GetNumGroupMembers() do
								ScanUnit("party"..i)
							end
						end
						if count > 0 then
							model.highlight, model.count, model.expiration = "good", count, shortest
						end
					end
				}
			end)()
		},

	--------------------------------------------------------------------------
	-- Priest
	--------------------------------------------------------------------------

		IfClass { "PRIEST",
			ImportPlayerSpells {
				-- Import all spells for ...
				"PRIEST",
				-- ... but ...
				17, -- Power Word: Shield
			},
			ShowPower {
				{
					 2944, -- Devouring Plague
					64044, -- Psychic Horror
				},
				"SHADOW_ORBS",
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
		},

	--------------------------------------------------------------------------
	-- Warlock
	--------------------------------------------------------------------------

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
		},
	}


	--------------------------------------------------------------------------
	-- Crowd-control spells
	--------------------------------------------------------------------------
	-- Use DRData, grouped by DR categories

	local DRData = LibStub("DRData-1.0")
	local LibSpellbook = LibStub('LibSpellbook-1.0')

	-- Build a list of spell ids per DR categories.
	local drspells = {}
	for id, category in pairs(DRData:GetSpells()) do
		if not drspells[category] then
			drspells[category] = {}
		end
		tinsert(drspells[category], id)
	end

	-- Create a rule for each spell of each category
	for category, spells in pairs(drspells) do
		local handler = BuildAuraHandler_Longest("HARMFUL", "bad", "enemy", spells)
		for i, spell in ipairs(spells) do
			local spell = spell
			tinsert(rules, function()
				local ids = LibSpellbook:GetAllIds(spell)
				if ids then
					for id in pairs(ids) do
						AddRuleFor(id, "enemy", "UNIT_AURA", handler)
					end
				end
			end)
		end
	end

	--------------------------------------------------------------------------
	-- Raid buffs
	--------------------------------------------------------------------------
	-- Use LibPlayerSpells

	local LibPlayerSpells = LibStub('LibPlayerSpells-1.0')
	local band, bor = bit.band, bit.bor

	local classMask = LibPlayerSpells.constants[playerClass]

	local buffsMasks, buffSpells = {}, {}
	for buff, flags, _, target, buffMask in LibPlayerSpells:IterateSpells("RAIDBUFF") do
		buffsMasks[buff] = buffMask
		if band(flags, classMask) ~= 0 then
			if buffSpells[buffMask] then
				tinsert(buffSpells[buffMask], target)
			else
				buffSpells[buffMask] = { target }
			end
		end
	end

	-- Create a rule per bitmask
	for buffMask, spells in pairs(buffSpells) do
		local buffMask = buffMask
		tinsert(rules, Configure {
			buffSpells[buffMask],
			"ally",
			"UNIT_AURA",
			function(units, model)
				local unit = units["ally"]
				if not unit then return end
				local found, minExpiration = 0
				for i = 1, math.huge do
					local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, "HELPFUL")
					if name then
						local buffProvided = band(buffsMasks[spellId] or 0, buffMask)
						if buffProvided ~= 0 then
							found = bor(found, buffProvided)
							if not minExpiration or expiration < minExpiration then
								minExpiration = expiration
							end
							if found == buffMask then
								model.highlight, model.expiration = "good", minExpiration
								return
							end
						end
					else
						return
					end
				end
			end
		})
	end

	--------------------------------------------------------------------------
	-- Dispels
	--------------------------------------------------------------------------
	-- Use LibDispellable and LibPlayerSpells
	local LibDispellable = LibStub('LibDispellable-1.0')

	local HELPFUL = LibPlayerSpells.constants.HELPFUL
	for spell, flags in LibPlayerSpells:IterateSpells("DISPEL", playerClass) do
		local offensive = band(flags, HELPFUL) == 0
		local spell, token = spell, offensive and "enemy" or "ally"
		tinsert(rules, Configure {
			spell,
			token,
			"UNIT_AURA",
			function(units, model)
				local unit = units[token]
				if not unit then return end
				for i, dispel, _, _, _, count, _, _, expiration in LibDispellable:IterateDispellableAuras(unit, offensive) do
					if dispel == spell then
						model.highlight, model.count, model.expiration = "bad", count, expiration
						return
					end
				end
			end
		})
	end

	--------------------------------------------------------------------------
	-- Interrupts
	--------------------------------------------------------------------------
	-- Use LibPlayerSpells

	local interrupts = {}
	for spell in LibPlayerSpells:IterateSpells("INTERRUPT", playerClass) do
		tinsert(interrupts, spell)
	end
	tinsert(rules, Configure {
		interrupts,
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
	})

	--------------------------------------------------------------------------
	-- End of rules
	--------------------------------------------------------------------------

	return rules
end
