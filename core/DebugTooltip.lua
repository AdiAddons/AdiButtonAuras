--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2023 Adirelle (adirelle@gmail.com)
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

local addonName, addon = ...

local _G = _G
local C_UnitAuras = _G.C_UnitAuras
local Enum = _G.Enum
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
local GetActionInfo = _G.GetActionInfo
local GetActionText = _G.GetActionText
local GetItemInfo = _G.GetItemInfo
local GetItemSpell = _G.GetItemSpell
local GetMacroInfo = _G.GetMacroInfo
local GetMacroItem = _G.GetMacroItem
local GetMacroSpell = _G.GetMacroSpell
local GetPetActionInfo = _G.GetPetActionInfo
local GetSpellInfo = _G.GetSpellInfo
local select = _G.select
local TooltipDataProcessor = _G.TooltipDataProcessor
local UnitAura = _G.UnitAura
local UnitBuff = _G.UnitBuff
local UnitDebuff = _G.UnitDebuff

local function IsDisabled()
	return not (addon.db and addon.db.profile.debuggingTooltip)
end

local function AddSpellInfo(tooltip, source, id, addEmptyLine)
	if not id or IsDisabled() or tooltip:IsForbidden() then return end

	local name, _, _, _, _, _, spellId = GetSpellInfo(id)
	if not name then return end

	if addEmptyLine then
		tooltip:AddLine(" ")
	end

	tooltip:AddDoubleLine("Spell id ("..source.."):", BreakUpLargeNumbers(spellId))
	local resolvedName, _, _, _, _, _, resolvedId = GetSpellInfo(name)
	if resolvedName and resolvedId ~= spellId then
		tooltip:AddDoubleLine("Actual spell name:", resolvedName)
		tooltip:AddDoubleLine("Actual spell id:", BreakUpLargeNumbers(resolvedId))
	end
	tooltip:Show()
end

local function AddItemInfo(tooltip, id, addEmptyLine)
	if not id or IsDisabled() then return end
	local name, link = GetItemInfo(id)
	if not name then return end
	if addEmptyLine then
		tooltip:AddLine(" ")
	end
	tooltip:AddDoubleLine("Item id:", BreakUpLargeNumbers(link:match('item:(%d+)')))
	tooltip:Show()
	return AddSpellInfo(tooltip, "item", GetItemSpell(link))
end

local function AddMacroInfo(tooltip, source, index)
	if not index or not GetMacroInfo(index) then return end
	local spellId = GetMacroSpell(index)
	AddSpellInfo(tooltip, source, spellId, true)
	local item, link = GetMacroItem(index)
	return AddItemInfo(tooltip, link or item)
end

local function AddActionInfo(tooltip, slot)
	if not slot or IsDisabled() then return end
	local actionType, id, subType = GetActionInfo(slot)
	if actionType == "spell" then
		return AddSpellInfo(tooltip, "action", id, true)
	elseif actionType == "macro" then
		-- this might return wrong info if macro names are not unique
		return AddMacroInfo(tooltip, "macro", GetActionText(slot))
	elseif actionType == "item" then
		return AddItemInfo(tooltip, id, true)
	end
end

local function AddPetActionInfo(tooltip, slot)
	if not slot or IsDisabled() then return end

	local _, _, _, _, _, _, id = GetPetActionInfo(slot)
	return AddSpellInfo(tooltip, "spell", id, true)
end

local spellIdGetters = {
	GetUnitAura = function(...)
		return select(10, UnitAura(unpack(...)))
	end,
	GetUnitBuff = function(...)
		return select(10, UnitBuff(unpack(...)))
	end,
	GetUnitDebuff = function(...)
		return select(10, UnitDebuff(unpack(...)))
	end,
	GetUnitBuffByAuraInstanceID = function(...)
		local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unpack(...))
		return data and data.spellId
	end,
	GetUnitDebuffByAuraInstanceID = function(...)
		local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unpack(...))
		return data and data.spellId
	end,
}

local sources = {
	GetAction = 'action',
	GetArtifactPowerByID = 'artifact',
	GetAzeritePower = 'azerite',
	GetConduit = 'conduit',
	GetPvpTalent = 'pvp talent',
	GetSpellBookItem = 'spellbook',
	GetTraitEntry = 'talent',
}

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
	AddItemInfo(tooltip, data.id, true)
end)

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, function(tooltip, data)
	AddActionInfo(tooltip, unpack(tooltip.processingInfo.getterArgs))
end)

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.PetAction, function(tooltip, data)
	AddPetActionInfo(tooltip, unpack(tooltip.processingInfo.getterArgs))
end)

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(tooltip, data)
	local getterName = tooltip.processingInfo and tooltip.processingInfo.getterName
	local source = getterName and sources[getterName] or 'spell'

	AddSpellInfo(tooltip, source, data.id, true)
end)

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, function(tooltip, data)
	local info = tooltip.processingInfo
	local id = spellIdGetters[info.getterName](info.getterArgs)

	AddSpellInfo(tooltip, 'aura', id, true)
end)
