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
local GetItemInfo = _G.GetItemInfo
local GetItemSpell = _G.GetItemSpell
local IsHarmfulItem = _G.IsHarmfulItem
local IsHelpfulItem = _G.IsHelpfulItem
local select = _G.select
local setmetatable = _G.setmetatable
local UnitAura = _G.UnitAura

local LibItemBuffs = LibStub('LibItemBuffs-1.0')

local items = {}
addon.items = items

local function GetItemTargetFilterAndHighlight(itemId)
	if IsHarmfulItem(itemId) then
		return "enemy", "PLAYER HARMFUL", "bad"
	else
		return IsHelpfulItem(itemId) and "ally" or "player", "PLAYER HELPFUL", "good"
	end
end

local function BuildItemRuleForBuffName(itemId, buffName)
	if not buffName then return end
	local _, link = GetItemInfo(itemId)
	addon:Debug('Buff for', link, '=>', buffName)
	local token, filter, highlight = GetItemTargetFilterAndHighlight(itemId)
	return {
		units = { [token] = true },
		events = { UNIT_AURA = true },
		handlers = {
			function(units, model)
				if not units[token] then return end
				local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(units[token], buffName, nil, filter)
				if name then
					model.highlight, model.expiration = highlight, expiration
					return true
				end
			end
		}
	}
end

local function BuildItemRuleForBuffIdS(itemId, ...)
	local numBuffs = select('#', ...)
	if numBuffs == 0 or not ... then return false end
	local _, link = GetItemInfo(itemId)
	addon:Debug('Buffs for', link, '=>', ...)
	local buffs = {}
	for i = 1, numBuffs do
		local spellId = select(i, ...)
		buffs[spellId] = true
	end
	local token, filter, highlight = GetItemTargetFilterAndHighlight(itemId)
	return {
		units = { [token] = true },
		events = { UNIT_AURA = true },
		handlers = {
			function(units, model)
				local unit = units[token]
				if not unit then return end
				for i = 1, math.huge do
					local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
					if name then
						if buffs[spellId] then
							model.highlight, model.expiration = highlight, expiration
							return true
						end
					else
						break
					end
				end
			end
		}
	}
end

setmetatable(items, { __index = function(t, itemId)
	local rule = false
	if itemId then
		rule = BuildItemRuleForBuffIdS(itemId, LibItemBuffs:GetItemBuffs(itemId))
			or BuildItemRuleForBuffName(itemId, GetItemSpell(itemId))
			or false
	end
	t[itemId] = rule
	return rule
end})
