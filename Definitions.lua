--[[
LuaAuras - Enhance action buttons using Lua handlers.
Copyright 2013 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

local addonName, addon = ...

local _G = _G
local pairs = _G.pairs
local UnitCanAttack = _G.UnitCanAttack
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo

local LibDispellable = LibStub('LibDispellable-1.0')

function addon.CreateRules()

	addon:Debug('Creating Rules')
	return {

		-- Interrupts: use a custom configuration
		Configure(
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
		), -- Interrupts

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

		-- Weakened Blows is applied by any tank as a part of his rotation, don't bother showing it
		-- Physical Vulnerability is applied passively or automatically, don't bother showing it

		-- Mortal Wounds
		LongestDebuffOf(
			{ -- Spells to alter
				 82654, -- Widow Venom (hunter)
			},
			{ -- Debuffs to look for
				  8679, -- Wound Poison (rogue)
				 30213, -- Legion Strike (warlock pet)
				 54680, -- Monstrous Bite (hunter exotic pet ability)
				 82654, -- Widow Venom (hunter)
				115804, -- Mortal Wounds (main effect)
			}
		), -- Mortal Wounds

		-- Weakened Armor
		LongestDebuffOf(
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
		), -- Weakened Armor

		-- +5% spell damage taken
		LongestDebuffOf(
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
		), -- +5% spell damage taken

		-- Increasing Casting Time
		LongestDebuffOf(
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
		), -- Increasing Casting Time

		-- Hunter spells
		IfClass { "HUNTER",
			SimpleBuffs {
				 53271, -- Master's Call
			},
			SimpleDebuffs {
				  1499, -- Freezing Trap
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
				 19263, -- Deterrence
				 34477, -- Misdirection
				 51753, -- Camouflage
				 82726, -- Fervor
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
				false,
				82692, -- Focus Fire
				19623, -- Frenzy
				"pet",
			},
		}, -- Hunter spells

	}

end
