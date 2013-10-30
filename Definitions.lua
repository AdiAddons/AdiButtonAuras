--[[
LuaAuras - Enhance action buttons using Lua handlers.
Copyright 2013 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

local addonName, addon = ...

function addon.CreateRules()
	addon:Debug('Creating Rules')
	return {
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
				 82654, -- Widow Venom
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
			TalentProc {
				34487, -- Master Marksman
				19434, -- Aimed Shot
				82925  -- Ready, Set, Aim...
			},
			TalentProc {
				53224, -- Steady Focus
				56641, -- Steady Shot
				53220  -- Steady Focus (buff)
			},
		},
	}
end
