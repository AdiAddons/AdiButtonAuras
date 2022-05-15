--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2022 Adirelle (adirelle@gmail.com)
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
along with AdiButtonAuras. If not, see <http://www.gnu.org/licenses/>.
--]]

AdiButtonAuras:RegisterRules(function()
	Debug('Adding common rules')

	local rules = {
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
				264667, -- Primal Rage (hunter ferocity pets)
				272678, -- Primal Rage (hunter command pet ability)
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
					146555, -- Drums of Rage
					178207, -- Drums of Fury
					264667, -- Primal Rage (hunter ferocity pets)
				})
				local isSated = BuildAuraHandler_Longest("HARMFUL", "bad", "ally", {
					 57723, -- Exhaustion (Drums of Rage/Fury debuff)
					 57724, -- Sated (Bloodlst/Heroism debuff),
					 80354, -- Temporal Displacement (Time Warp debuff)
					264689, -- Fatigued (Primal Rage debuff)
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

	local LibPlayerSpells = GetLib('LibPlayerSpells-1.0')
	local band, bor = bit.band, bit.bor
	local classFlag = LibPlayerSpells.constants[PLAYER_CLASS]
	local racialFlag = LibPlayerSpells.constants.RACIAL

	local debuffs, ccSpells = {}, {}

	for aura, flags, providers, modified, ccFlags in LibPlayerSpells:IterateSpells('CROWD_CTRL') do
		debuffs[ccFlags] = debuffs[ccFlags] or {} -- assoviative array to avoid duplicates
		debuffs[ccFlags][aura] = true

		if band(flags, classFlag) > 0 or band(flags, racialFlag) > 0 then
			ccSpells[ccFlags] = ccSpells[ccFlags] or {}
			local spells = ccSpells[ccFlags]
			if type(modified) == 'table' then
				for i = 1, #modified do
					spells[modified[i]] = providers
				end
			else
				spells[modified] = providers
			end
		end
	end

	-- associative to simple array
	for flag, auras in next, debuffs do
		local list = {}
		for aura in next, auras do
			list[#list + 1] = aura
		end
		debuffs[flag] = list
	end

	for flag, spells in next, ccSpells do
		local name = LibPlayerSpells:GetCrowdControlCategoryName(flag)
		local desc = format(L['Show the "bad" border if the targeted enemy is %s.'], name:lower())
		local handler = BuildAuraHandler_Longest('HARMFUL', 'bad', 'enemy', debuffs[flag])
		for spell, providers in next, spells do
			local key = format('CrowdControl:%s:%d', name, spell)
			rules[#rules + 1] = function()
				AddRuleFor(key, desc, spell, 'enemy', 'UNIT_AURA', handler, providers)
			end
		end
	end

	--------------------------------------------------------------------------
	-- Dispels
	--------------------------------------------------------------------------

	local TARGETING = LibPlayerSpells.masks.TARGETING
	local PERSONAL  = LibPlayerSpells.constants.PERSONAL
	local HARMFUL   = LibPlayerSpells.constants.HARMFUL
	local CURSE     = LibPlayerSpells.constants.CURSE
	local DISEASE   = LibPlayerSpells.constants.DISEASE
	local MAGIC     = LibPlayerSpells.constants.MAGIC
	local POISON    = LibPlayerSpells.constants.POISON
	local ENRAGE    = LibPlayerSpells.constants.ENRAGE
	local inclusionMask = bor(LibPlayerSpells.constants[PLAYER_CLASS], LibPlayerSpells.constants.RACIAL)

	for spell, flags, _, _, _, category, dispelFlags in LibPlayerSpells:IterateSpells('DISPEL') do
		if band(inclusionMask, flags) > 0 then
			local filter, highlight, token = 'HARMFUL', 'dispel', 'ally'
			local targeting = band(flags, TARGETING)
			if targeting == HARMFUL then
				filter, token = 'HELPFUL', 'enemy'
			elseif targeting == PERSONAL then
				token = 'player'
			end
			local desc = filter == 'HARMFUL' and L['a debuff you can dispel'] or L['a buff you can dispel']
			local dispellable = {
				Curse   = band(dispelFlags, CURSE) > 0 or nil,
				Disease = band(dispelFlags, DISEASE) > 0 or nil,
				Magic   = band(dispelFlags, MAGIC) > 0 or nil,
				Poison  = band(dispelFlags, POISON) > 0 or nil,
				Enrage  = band(dispelFlags, ENRAGE) > 0 or nil,
			}

			if next(dispellable) then
				rules[#rules + 1] = Configure {
					'Dispel:' .. spell,
					BuildDesc(desc, highlight, token) .. format(' [%s]', DescribeLPSSource(category)),
					spell,
					token,
					'UNIT_AURA',
					BuildDispelHandler(filter, highlight, token, dispellable),
				}
			end
		end
	end

	--------------------------------------------------------------------------
	-- Interrupts
	--------------------------------------------------------------------------
	-- Use LibPlayerSpells

	local interrupts = {}
	for spell, _, _, _, _, category in LibPlayerSpells:IterateSpells("INTERRUPT") do
		if category == PLAYER_CLASS or category == "RACIAL" then
			tinsert(interrupts, spell)
		end
	end
	if #interrupts > 0 then
		local source = DescribeLPSSource(PLAYER_CLASS)
		tinsert(rules, Configure {
			"Interrupt",
			format(L["%s when %s is casting/channeling a spell that you can interrupt."].." [%s]",
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
					local name, _, _, _, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
					if name and not notInterruptible then
						model.flash, model.expiration = true, endTime / 1000
					end
					name, _, _, _, endTime, _, notInterruptible = UnitChannelInfo(unit)
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
