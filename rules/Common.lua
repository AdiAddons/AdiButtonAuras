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
				  8056, -- Frost Shock (shaman)
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
				 61394, -- Frozen Wake (hunter, glyph)
				116095, -- Disable (monk, 1 stack)
				127797, -- Ursol's Vortex
				129923  -- Sluggish (warrior, hs glyph)
			}
		}, -- Snares and anti-snares

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
					 57723, -- Exhaustion (Drums of Rage debuff)
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

	local DRData, DRVer = GetLib("DRData-1.0")
	local LibSpellbook, LSBVer = GetLib('LibSpellbook-1.0')
	local source = format(" [DR-%d,LSB-%d]", DRVer, LSBVer)

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
		local desc = BuildDesc(L["a debuff"], "bad", "enemy", format(L["of type '%s'"], DRData:GetCategoryName(category):lower()))..source
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

	local classMask = LibPlayerSpells.constants[PLAYER_CLASS]

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
			for i, id, _, expiration in IterateBuffs(unit) do
				local buffProvided = band(buffsMasks[id] or 0, buffMask)
				if buffProvided ~= 0 then
					found = bor(found, buffProvided)
					if not minExpiration or expiration < minExpiration then
						minExpiration = expiration
					end
				end
			end
			return found == buffMask, minExpiration
		end

		tinsert(rules, Configure {
			"Raidbuff:"..buffMask,
			L["Track @NAME or equivalent raid buffs on all group members. Indicate the duration of the shortest buff and the number of missing buffs."].." [LPS]",
			buffSpells[buffMask],
			"group",
			"UNIT_AURA",
			function(units, model)
				local missing, minExpiration = 0
				for unit in pairs(units.group) do
					if UnitIsPlayer(unit) and not UnitIsDeadOrGhost(unit) then
						local found, expiration = CheckUnitBuffs(unit)
						if not found then
							missing = missing + 1
						elseif not minExpiration or expiration < minExpiration then
							minExpiration = expiration
						end
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
	local LibDispellable, LDVer = GetLib('LibDispellable-1.0')

	local HELPFUL = LibPlayerSpells.constants.HELPFUL
	for spell, flags, _, _, _, category in LibPlayerSpells:IterateSpells("DISPEL", PLAYER_CLASS) do
		local offensive = band(flags, HELPFUL) == 0
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
-- GLOBALS: print select string table tinsert
-- GLOBALS: GetPlayerBuff IterateBuffs GetLib ShowStacks
