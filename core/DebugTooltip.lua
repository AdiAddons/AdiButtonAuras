--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2018 Adirelle (adirelle@gmail.com)
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
local GameTooltip = _G.GameTooltip
local GetActionInfo = _G.GetActionInfo
local GetAzeritePowerInfo = _G.C_AzeriteEmpoweredItem.GetPowerInfo
local GetItemInfo = _G.GetItemInfo
local GetItemSpell = _G.GetItemSpell
local GetMacroInfo = _G.GetMacroInfo
local GetMacroItem = _G.GetMacroItem
local GetMacroSpell = _G.GetMacroSpell
local getmetatable = _G.getmetatable
local GetPetActionInfo = _G.GetPetActionInfo
local GetPowerInfo = _G.C_ArtifactUI.GetPowerInfo
local GetPvpTalentInfoByID = _G.GetPvpTalentInfoByID
local GetSpellBookItemName = _G.GetSpellBookItemName
local GetSpellInfo = _G.GetSpellInfo
local GetTalentInfoByID = _G.GetTalentInfoByID
local hooksecurefunc = _G.hooksecurefunc
local select = _G.select
local UnitAura = _G.UnitAura
local UnitBuff = _G.UnitBuff
local UnitDebuff = _G.UnitDebuff

local function IsDisabled()
	return not (addon.db and addon.db.profile.debuggingTooltip)
end

local function AddSpellInfo(tooltip, source, id, addEmptyLine)
	if not id or IsDisabled() then return end
	local name, _, _, _, _, _, spellId = GetSpellInfo(id)
	if not name then return end

	if addEmptyLine then
		tooltip:AddLine(" ")
	end

	tooltip:AddDoubleLine("Spell id ("..source.."):", spellId)
	local resolvedName, _, _, _, _, _, resolvedId = GetSpellInfo(name)
	if resolvedName and resolvedId ~= spellId then
		tooltip:AddDoubleLine("Actual spell name:", resolvedName)
		tooltip:AddDoubleLine("Actual spell id:", resolvedId)
	end
	tooltip:Show()
end

local function AddArtifactInfo(tooltip, traitId)
	if not traitId or IsDisabled() then return end
	tooltip:AddLine(" ")
	tooltip:AddDoubleLine("Trait id:", traitId)
	local spellId = GetPowerInfo(traitId).spellID
	if not spellId then return end
	tooltip:AddDoubleLine("Spell id:", spellId)
	tooltip:Show()
end

local function AddItemInfo(tooltip, id, addEmptyLine)
	if not id or IsDisabled() then return end
	local name, link = GetItemInfo(id)
	if not name then return end
	if addEmptyLine then
		tooltip:AddLine(" ")
	end
	tooltip:AddDoubleLine("Item id:", link:match('item:(%d+)'))
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
		return AddMacroInfo(tooltip, "action", id)
	elseif actionType == "item" then
		return AddItemInfo(tooltip, id, true)
	end
end

local function AddPetActionInfo(tooltip, slot)
	if not slot or IsDisabled() then return end

	local _, _, _, _, _, _, id = GetPetActionInfo(slot)
	return AddSpellInfo(tooltip, "spell", id, true)
end

local function AddAuraInfo(func, tooltip, ...)
	return AddSpellInfo(tooltip, "aura", select(10, func(...)), true)
end

local function AddSpellbookInfo(tooltip, slot, bookType)
	local _, _, id = GetSpellBookItemName(slot, bookType)
	return AddSpellInfo(tooltip, "spellbook", id, true)
end

local function AddTalentInfo(tooltip, talentId)
	local _, _, _, _, _, spellId = GetTalentInfoByID(talentId)
	return AddSpellInfo(tooltip, "talent", spellId, true)
end

local function AddPvpTalentInfo(tooltip, talentId)
	if not talentId or IsDisabled() then return end
	local _, _, _, _, _, spellId = GetPvpTalentInfoByID(talentId)

	tooltip:AddLine(' ')
	tooltip:AddDoubleLine('Honor talent id:', talentId)
	return AddSpellInfo(tooltip, 'honor talent', spellId)
end

local function AddAzeriteInfo(tooltip, _, _, powerId)
	if not powerId or IsDisabled() then return end
	tooltip:AddLine(' ')
	tooltip:AddDoubleLine("Azerite power id:", powerId)
	local info = GetAzeritePowerInfo(powerId)
	return AddSpellInfo(tooltip, "azerite", info.spellID)
end

local function AddItemRefInfo(link)
	local id = link:match('spell:(%d+):')
	return AddSpellInfo(_G.ItemRefTooltip, "spell", id, true)
end

local proto = getmetatable(GameTooltip).__index
hooksecurefunc(proto, "SetUnitAura", function(...) return AddAuraInfo(UnitAura, ...) end)
hooksecurefunc(proto, "SetUnitBuff", function(...) return AddAuraInfo(UnitBuff, ...) end)
hooksecurefunc(proto, "SetUnitDebuff", function(...) return AddAuraInfo(UnitDebuff, ...) end)
hooksecurefunc(proto, "SetSpellByID", function(tooltip, ...) return AddSpellInfo(tooltip, "SpellByID", ...) end)
hooksecurefunc(proto, "SetSpellBookItem", AddSpellbookInfo)
hooksecurefunc(proto, "SetAction", AddActionInfo)
hooksecurefunc(proto, "SetPetAction", AddPetActionInfo)
hooksecurefunc(proto, "SetArtifactPowerByID", AddArtifactInfo)
hooksecurefunc(proto, "SetTalent", AddTalentInfo)
hooksecurefunc(proto, 'SetPvpTalent', AddPvpTalentInfo)
hooksecurefunc(proto, "SetAzeritePower", AddAzeriteInfo)
hooksecurefunc("SetItemRef", AddItemRefInfo)
