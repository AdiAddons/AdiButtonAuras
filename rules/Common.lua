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

-- Globals: AddRuleFor Configure SimpleAuras UnitBuffs
-- Globals: PassiveModifier SimpleDebuffs SharedSimpleDebuffs SimpleBuffs
-- Globals: LongestDebuffOf SelfBuffs PetBuffs BuffAliases DebuffAliases
-- Globals: SelfBuffAliases SharedBuffs ShowPower SharedSimpleBuffs
-- Globals: BuildAuraHandler_Longest ImportPlayerSpells bit BuildAuraHandler_Single
-- Globals: math

AdiButtonAuras:RegisterRules(function(addon)
	addon.Debug('Rules', 'Adding common rules')

	local _G = _G
	local ipairs = _G.ipairs
	local pairs = _G.pairs
	local tinsert = _G.tinsert
	local UnitAura = _G.UnitAura
	local UnitCanAttack = _G.UnitCanAttack
	local UnitCastingInfo = _G.UnitCastingInfo
	local UnitChannelInfo = _G.UnitChannelInfo
	local UnitClass = _G.UnitClass

	local L = addon.L
	local GetLib = addon.GetLib
	local BuildDesc = addon.BuildDesc
	local BuildKey = addon.BuildKey

	local _, playerClass = UnitClass("player")

	local rules = {
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
			"bloodlust",
			L["Show when @NAME or an equivalent haste buff is found on yourself."],
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
	}

	--------------------------------------------------------------------------
	-- Crowd-control spells
	--------------------------------------------------------------------------
	-- Use DRData, grouped by DR categories

	local DRData = GetLib("DRData-1.0")
	local LibSpellbook = GetLib('LibSpellbook-1.0')

	-- Build a list of spell ids per DR categories.
	local drspells = {}
	for id, category in pairs(DRData:GetSpells()) do
		if not drspells[category] then
			drspells[category] = {}
		end
		tinsert(drspells[category], id)
	end

	-- Create a rule for each spell of each category
	local drproviders = DRData.GetProviders and DRData:GetProviders() or {}
	for category, spells in pairs(drspells) do
		local key = BuildKey("CrowdControl", category)
		local desc = BuildDesc(L["a debuff"], "bad", "enemy", format(L["of type '%s'"], DRData:GetCategoryName(category):lower()))
		local handler = BuildAuraHandler_Longest("HARMFUL", "bad", "enemy", spells)
		for i, spell in ipairs(spells) do
			local spell = spell
			tinsert(rules, function()
				local ids = LibSpellbook:GetAllIds(spell)
				if ids then
					for id in pairs(ids) do
						AddRuleFor(key, desc, id, "enemy", "UNIT_AURA", handler, drproviders[id])
					end
				end
			end)
		end
	end

	--------------------------------------------------------------------------
	-- Raid buffs
	--------------------------------------------------------------------------
	-- Use LibPlayerSpells

	local LibPlayerSpells = GetLib('LibPlayerSpells-1.0')
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

		local function CheckUnitBuffs(unit)
			local found, minExpiration = 0
			for i = 1, math.huge do
				local name, _, _, _, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, "HELPFUL")
				if name then
					local buffProvided = band(buffsMasks[spellId] or 0, buffMask)
					addon.Debug('Raidbuff', unit, i, name, expiration, buffsMasks[spellId], buffProvided)
					if buffProvided ~= 0 then
						found = bor(found, buffProvided)
						if not minExpiration or expiration < minExpiration then
							minExpiration = expiration
						end
					end
				else
					break
				end
			end
			return found == buffMask, minExpiration
		end

		tinsert(rules, Configure {
			"Raidbuff:"..buffMask,
			L["Track @NAME or equivalent raid buffs on all group members. Indicate the duration of the shortest buff and the number of missing buffs."],
			buffSpells[buffMask],
			"group",
			"UNIT_AURA",
			function(units, model)
				local missing, minExpiration = 0
				for unit in pairs(units.group) do
					if not UnitIsDeadOrGhost(unit) then
						local found, expiration = CheckUnitBuffs(unit)
						addon.Debug('Raidbuff', buffMask, unit, found, expiration)
						if not found then
							missing = missing + 1
						elseif not minExpiration or expiration < minExpiration then
							minExpiration = expiration
						end
					else
						addon.Debug('Raidbuff', unit, "dead or ghost")
					end
				end
				if minExpiration then
					model.highlight, model.expiration = "good", minExpiration
				end
				if missing > 0 then
					model.count = missing
				end
			end
		})
	end

	--------------------------------------------------------------------------
	-- Dispels
	--------------------------------------------------------------------------
	-- Use LibDispellable and LibPlayerSpells
	local LibDispellable = GetLib('LibDispellable-1.0')

	local HELPFUL = LibPlayerSpells.constants.HELPFUL
	for spell, flags in LibPlayerSpells:IterateSpells("DISPEL", playerClass) do
		local offensive = band(flags, HELPFUL) == 0
		local spell, token = spell, offensive and "enemy" or "ally"
		tinsert(rules, Configure {
			"Dispel",
			(offensive
				and BuildDesc(L["a buff you can dispel"], "good", "enemy")
				or BuildDesc(L["a debuff you can dispel"], "bad", "ally")
			),
			spell,
			token,
			"UNIT_AURA",
			function(units, model)
				local unit = units[token]
				if not unit then return end
				for i, dispel, _, _, _, count, _, _, expiration in LibDispellable:IterateDispellableAuras(unit, offensive) do
					if dispel == spell then
						model.highlight, model.count, model.expiration = offensive and "good" or "bad", count, expiration
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
		"Interrupt",
		format(L["%s when %s is casting/channeling a spell that you can interrupt."],
			addon.DescribeHighlight("flash"),
			addon.DescribeAllTokens("enemy")
		),
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
			if unit and UnitCanAttack("player", unit) then
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

	return rules
end)
