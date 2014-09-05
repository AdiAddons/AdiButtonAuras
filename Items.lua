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

local addonName, addon = ...

local _G = _G
local GetItemInfo = _G.GetItemInfo
local GetItemSpell = _G.GetItemSpell
local IsHarmfulItem = _G.IsHarmfulItem
local IsHelpfulItem = _G.IsHelpfulItem
local select = _G.select
local setmetatable = _G.setmetatable
local UnitAura = _G.UnitAura

local LibItemBuffs = addon.GetLib('LibItemBuffs-1.0')

local BuildKey = addon.BuildKey
local BuildDesc = addon.BuildDesc

local items, itemDescs = {}, {}
addon.items = items
addon.itemDescs = itemDescs

local function GetItemTargetFilterAndHighlight(itemId)
	if IsHarmfulItem(itemId) then
		return "enemy", "HARMFUL PLAYER", "bad"
	else
		return IsHelpfulItem(itemId) and "ally" or "player", "HELPFUL PLAYER", "good"
	end
end

local function BuildBuffIdHandler(key, token, filter, highlight, buffId)
	return function(units, model)
		if not addon.db.profile.rules[key] then return end
		local unit = units[token]
		if not unit then return end
		for i = 1, math.huge do
			local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
			if not name then
				return
			end
			if spellId == buffId then
				model.highlight, model.count, model.expiration = highlight, count, expiration
				return true
			end
		end
	end
end

local function BuildBuffNameHandler(key, token, filter, highlight, buffName)
	return function(units, model)
		if not units[token] or not addon.db.profile.rules[key] then return end
		local name, _, _, count, _, _, expiration = UnitAura(units[token], buffName, nil, filter)
		if name then
			model.highlight, model.count, model.expiration = highlight, count, expiration
			return true
		end
	end
end

local function BuildItemRule(itemId, buffName, ...)
	if not buffName and not ... then return end

	local token, filter, highlight = GetItemTargetFilterAndHighlight(itemId)

	local rule = {
		units = { [token] = true },
		events = { UNIT_AURA = true },
		handlers = {},
		keys = {}
	}

	if ... then
		for i = 1, select('#', ...) do
			local buffId = select(i, ...)
			local key = BuildKey('item', itemId, token, filter, highlight, buffId)
			local desc = BuildDesc(filter, highlight, token, buffId)
			itemDescs[key] = desc
			tinsert(rule.keys, key)
			tinsert(rule.handlers, BuildBuffIdHandler(key, token, filter, highlight, buffId))
		end
	elseif buffName then
		local key = BuildKey('item', itemId, token, filter, highlight, buffName)
		local desc = BuildDesc(filter, highlight, token, buffName)
		itemDescs[key] = desc
		tinsert(rule.keys, key)
		tinsert(rule.handlers, BuildBuffIdHandler(key, token, filter, highlight, buffName))
	end

	return rule
end

setmetatable(items, { __index = function(t, itemId)
	local rule = itemId and BuildItemRule(itemId, GetItemSpell(itemId), LibItemBuffs:GetItemBuffs(itemId)) or false
	t[itemId] = rule
	return rule
end})
