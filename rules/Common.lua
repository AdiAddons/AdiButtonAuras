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

AdiButtonAuras:RegisterRules(function()
	Debug('Adding common rules')

	local rules = {
	--------------------------------------------------------------------------
	-- Snares and anti-snares
	--------------------------------------------------------------------------
	-- Note that some of these are talent procs or passive effects.
	-- This is intended as they will show up on active spells anyway.

		LongestDebuffOf {
			{
				   116, -- Frostbolt (mage)
				   120, -- Cone of Cold (mage)
				  1044, -- Hand of Freedom (paladin)
				  1604, -- Dazed (common)
				  1715, -- Piercing Howl (warrior)
				  3409, -- Crippling Poison (rogue)
				  3600, -- Earthbind (shaman)
				  5116, -- Concussive Shot (hunter)
				  6136, -- Chilled (mage)
				  7321, -- Chilled (mage, bis)
				  -- 8056, -- Frost Shock (shaman) -- NOTE: gone in Legion
				  8178, -- Grounding Totem Effect (shaman)
				 12323, -- Hamstring (warrior)
				 13810, -- Ice Trap (hunter)
				 17962, -- Conflagrate (warlock)
				 26679, -- Deadly Throw (rogue)
				 31589, -- Slow (mage)
				 35346, -- Time Warp (hunter, warp Stalker)
				 44614, -- Frostfire Bolt (mage)
				 45524, -- Chains of Ice (death knight)
				 50259, -- Dazed (feral charge effect)
				 54644, -- Frost Breath (hunter, chimaera)
				 58180, -- Infected Wounds (druid)
				 61391, -- Typhoon (druid)
				 -- 61394, -- Frozen Wake (hunter, glyph) -- NOTE: gone in Legion
				116095, -- Disable (monk, 1 stack)
				127797, -- Ursol's Vortex
				-- 129923  -- Sluggish (warrior, hs glyph) -- NOTE: gone in Legion
			}
		}, -- Snares and anti-snares

	--------------------------------------------------------------------------
	-- Legendary Rings
	--------------------------------------------------------------------------

		Configure {
			"LegendaryRingsDPS",
			format(L["%s when someone used their legendary ring."], DescribeHighlight("good")),
			{
				"item:124634", -- Thorasus, the Stone Heart of Draenor
				"item:124635", -- Nithramus, the All-Seer
				"item:124636", -- Maalus, the Blood Drinker
			},
			"player",
			"UNIT_AURA",
			(function()
				local hasSavageHollows = BuildAuraHandler_FirstOf("HELPFUL", "good", "player", {
					187616, -- Nithramus
					187619, -- Thorasus
					187620, -- Maalus
				})
				return function(units, model)
					return hasSavageHollows(units, model)
				end
			end)(),
		},

		Configure {
			"LegendaryRingsTanks",
			format(L["%s when someone used their legendary ring."], DescribeHighlight("good")),
			"item:124637", -- Sanctus, Sigil of the Unbroken
			"player",
			"UNIT_AURA",
			(function()
				local hasSanctus = BuildAuraHandler_Single("HELPFUL", "good", "player", 187617) -- Sanctus
				return function(units, model)
					return hasSanctus(units, model)
				end
			end)(),
		},

		Configure {
			"LegendaryRingsHeal",
			format(L["%s when someone used their legendary ring."], DescribeHighlight("good")),
			"item:124638", -- Etheralus, the Eternal Reward
			"player",
			"UNIT_AURA",
			(function()
				local hasEtheralus = BuildAuraHandler_Single("HELPFUL", "good", "player", 187618) -- Etheralus
				return function(units, model)
					return hasEtheralus(units, model)
				end
			end)(),
		},

	--------------------------------------------------------------------------
	-- Bloodlust
	--------------------------------------------------------------------------

		Configure {
			"bloodlust",
			L["Show when @NAME or an equivalent haste buff is found on yourself."],
			{
				  2825, -- Bloodlust (Horde shaman)
				 32182, -- Heroism (Alliance shaman)
				 80353, -- Time Warp (mage)
				 90355, -- Ancient Hysteria (hunter exotic pet ability)
				160452, -- Netherwinds (hunter pet)
				"item:102351", -- Drums of Rage
				"item:120257", -- Drums of Fury
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
					160452, -- Netherwinds (hunter pet)
					178207, -- Drums of Fury
				})
				local isSated = BuildAuraHandler_Longest("HARMFUL", "bad", "ally", {
					 57723, -- Exhaustion (Drums of Rage/Fury debuff)
					 57724, -- Sated (Bloodlst/Heroism debuff),
					 80354, -- Temporal Displacement (Time Warp debuff)
					 95809, -- Insanity (Ancient Hysteria debuff)
					160455, -- Fatigued (Netherwinds debuff)
				})
				return function(units, model)
					return hasBloodlust(units, model) or isSated(units, model)
				end
			end)(),
		},

	--------------------------------------------------------------------------
	-- Battle Resurrection (Surrendered Soul)
	--------------------------------------------------------------------------

		Configure {
			"SurrenderedSoul",
			BuildDesc("HARMFUL", "bad", "ally", 212570), -- Surrendered Soul
			{
				 20484, -- Rebirth
				 20707, -- Soulstone
				 61999, -- Raise Ally
				126393, -- Eternal Guardian (Quilen)
				159931, -- Gift of Chi-Ji (Crane)
				159956, -- Dust of Life (Moth)
			},
			"ally",
			"UNI_AURA",
			function(units, model)
				local found, _, expiration = GetDebuff(units.ally, 212570) -- Surrendered Soul
				if found then
					model.highlight = "bad"
					model.expiration = expiration
				end
			end,
		},
	}

	--------------------------------------------------------------------------
	-- Crowd-control spells
	--------------------------------------------------------------------------

	local LibPlayerSpells = GetLib('LibPlayerSpells-1.0')
	local band, bor = bit.band, bit.bor
	local classMask = LibPlayerSpells.constants[PLAYER_CLASS]

	local debuffs, ccSpells = {}, {}

	for aura, flags, _, target, ccMask in LibPlayerSpells:IterateSpells("CROWD_CTRL") do
		debuffs[ccMask] = debuffs[ccMask] or {} -- associative array to avoid duplicates
		debuffs[ccMask][aura] = true
		if band(flags, classMask) > 0 then
			ccSpells[ccMask] = ccSpells[ccMask] or {} -- associative array to avoid duplicates
			local spells = ccSpells[ccMask]
			if type(target) == "table" then
				for i = 1, #target do
					spells[target[i]] = true
				end
			else
				spells[target] = true
			end
		end
	end
	-- associative to simple array
	for mask, spells in pairs(debuffs) do
		local list = {}
		for spell in pairs(spells) do
			list[#list + 1] = spell
		end
		debuffs[mask] = list
	end

	for mask, spells in pairs(ccSpells) do
		local key = "CrowdControl:"..mask
		local name = LibPlayerSpells:GetCrowdControlCategoryName(mask)
		local desc = format(L["Show the \"bad\" border if the targeted enemy is %s."], name:lower())
		local handler = BuildAuraHandler_Longest("HARMFUL", "bad", "enemy", debuffs[mask])
		for spell in pairs(spells) do
			rules[#rules + 1] = function()
				AddRuleFor(key, desc, spell, "enemy", "UNIT_AURA", handler)
			end
		end
	end

	--------------------------------------------------------------------------
	-- Dispels
	--------------------------------------------------------------------------
	-- Use LibDispellable and LibPlayerSpells
	local LibDispellable, LDVer = GetLib('LibDispellable-1.0')

	local HELPFUL = LibPlayerSpells.constants.HELPFUL
	for spell, flags, _, _, _, category in LibPlayerSpells:IterateSpells("DISPEL", PLAYER_CLASS) do
		local offensive = bit.band(flags, HELPFUL) == 0
		local spell, token = spell, offensive and "enemy" or "ally"
		tinsert(rules, Configure {
			"Dispel",
			(offensive
				and BuildDesc(L["a buff you can dispel"], "good", "enemy")
				or BuildDesc(L["a debuff you can dispel"], "bad", "ally")
			)..format(" [LD-%d,%s]", LDVer, DescribeLPSSource(category)),
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
	for spell, _, _, _, _, category in LibPlayerSpells:IterateSpells("INTERRUPT", PLAYER_CLASS) do
		tinsert(interrupts, spell)
	end
	if #interrupts > 0 then
		local source = DescribeLPSSource(PLAYER_CLASS)
		tinsert(rules, Configure {
			"Interrupt",
			format(L["%s when %s is casting/channelling a spell that you can interrupt."].." [%s]",
				DescribeHighlight("flash"),
				DescribeAllTokens("enemy"),
				source
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
						model.flash, model.expiration = true, endTime / 1000
					end
					name, _, _, _, _, endTime, _, notInterruptible = UnitChannelInfo(unit)
					if name and not notInterruptible then
						model.flash, model.expiration = true, endTime / 1000
					end
				end
			end
		})
	end

	--------------------------------------------------------------------------
	-- Racials
	--------------------------------------------------------------------------

	tinsert(rules, ImportPlayerSpells { "RACIAL" })

	return rules
end)

-- ABA
-- GLOBALS: AddRuleFor BuffAliases BuildAuraHandler_FirstOf BuildAuraHandler_Longest
-- GLOBALS: BuildAuraHandler_Single BuildDesc BuildKey Configure DebuffAliases Debug
-- GLOBALS: DescribeAllSpells DescribeAllTokens DescribeFilter DescribeHighlight
-- GLOBALS: DescribeLPSSource GetBuff GetDebuff GetLib GetPlayerBuff GetPlayerDebuff
-- GLOBALS: ImportPlayerSpells IterateBuffs IterateDebuffs IteratePlayerBuffs
-- GLOBALS: IteratePlayerDebuffs L LongestDebuffOf PassiveModifier PetBuffs PLAYER_CLASS
-- GLOBALS: SelfBuffAliases SelfBuffs SharedSimpleBuffs SharedSimpleDebuffs ShowPower
-- GLOBALS: ShowStacks SimpleBuffs SimpleDebuffs

-- WoW API
-- GLOBALS: GetNumGroupMembers GetPetTimeRemaining GetRuneCooldown GetShapeshiftFormID
-- GLOBALS: GetSpellCharges GetSpellBonusHealing GetSpellInfo GetTime GetTotemInfo
-- GLOBALS: HasPetSpells IsPlayerSpell UnitCanAttack UnitCastingInfo UnitChannelInfo
-- GLOBALS: UnitClass UnitHealth UnitHealthMax UnitIsDeadOrGhost UnitIsPlayer UnitName
-- GLOBALS: UnitPower UnitPowerMax UnitStagger

-- Lua API
-- GLOBALS: bit ceil floor format ipairs math min pairs print select string table
-- GLOBALS: tinsert type
