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
local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink
local UnitAura = _G.UnitAura
local UnitClass = _G.UnitClass
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local assert = _G.assert
local error = _G.error
local format = _G.format
local ipairs = _G.ipairs
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local setfenv = _G.setfenv
local setmetatable = _G.setmetatable
local strjoin = _G.strjoin
local tinsert = _G.tinsert
local type = _G.type
local unpack = _G.unpack
local wipe = _G.wipe

--------------------------------------------------------------------------------
-- Generic list and set tools
--------------------------------------------------------------------------------

local getkeys = addon.getkeys

local function Do(funcs)
	for j, func in ipairs(funcs) do
		func()
	end
end

local function ConcatLists(a, b)
	for i, v in ipairs(b) do
		tinsert(a, v)
	end
	return a
end

local FlattenList
do
	local function Flatten0(a, b)
		for i, v in ipairs(b) do
			if type(v) == "table" then
				Flatten0(a, v)
			else
				tinsert(a, v)
			end
		end
		return a
	end

	function FlattenList(l) return Flatten0({}, l) end
end

local function AsList(value, checkType, callLevel)
	if type(value) == "table" then
		value = FlattenList(value)
		for i, v in ipairs(value) do
			if type(v) ~= checkType then
				error("Invalid value type, expected "..checkType..", got "..type(v), (callLevel or 0)+2)
			end
		end
		return value
	elseif checkType == nil or type(value) == checkType then
		return { value }
	else
		error("Invalid value type, expected "..checkType..", got "..type(value), (callLevel or 0)+2)
	end
end

local function AsSet(value, checkType, callLevel)
	local set = {}
	local size = 0
	for i, value in ipairs(AsList(value, checkType, (callLevel or 0)+1)) do
		if not set[value] then
			set[value] = true
			size = size + 1
		end
	end
	return set, size
end

local function MergeSets(a, b)
	for k in pairs(b) do
		a[k] = true
	end
	return a
end

--------------------------------------------------------------------------------
-- Rule creation
--------------------------------------------------------------------------------

local LibSpellbook = LibStub('LibSpellbook-1.0')

local playerClass = select(2, UnitClass("player"))
local knownClasses = {}
local spellConfs = {}
addon.spells = spellConfs

local function SpellOrItemId(value, callLevel)
	callLevel = (callLevel or 0) + 2
	local spellId = tonumber(type(value) == "string" and strmatch(value, "spell:(%d+)") or value)
	if spellId then
		if not GetSpellInfo(spellId) then
			error(format("Invalid spell identifier: %s", tostring(value)), callLevel)
		elseif not LibSpellbook:IsKnown(spell) then
			return nil -- Unknown spell
		end
		return format("spell:%d", spellId), "spell "..GetSpellLink(spellId)
	end
	local itemId = tonumber(strmatch(tostring(value), "item:(%d)"))
	if itemId then
		return format("item:%d", itemId), "item "..GetItemLink(itemId)
	end
	error(format("Invalid spell or item identifier: %s", tostring(value)), callLevel)
end

local function _AddRuleFor(spell, units, events, handlers, callLevel)
	local id, info = SpellOrItemId(spell, (callLevel or 0)+1)
	if not id then
		return
	end
	addon:Debug("Adding rule for", info,
		"units:", strjoin(",", getkeys(units)),
		"events:", strjoin(",", getkeys(events)),
		"handlers:", handlers
	)
	local rule = spellConfs[id]
	if not rule then
		rule = { units = {}, events = {}, handlers = {} }
		spellConfs[id] = rule
	end
	MergeSets(rule.units, units)
	MergeSets(rule.events, events)
	ConcatLists(rule.handlers, handlers)
end

local function CheckRuleArgs(units, events, handlers, callLevel)
	callLevel = (callLevel or 0) + 1
	local numUnits, numEvents

	units, numUnits = AsSet(units, "string", callLevel)
	if numUnits == 0 then
		error("Empty unit list", callLevel+1)
	end

	events, numEvents = AsSet(events, "string", callLevel)
	if numEvents == 0 then
		error("Empty event list", callLevel+1)
	end

	handlers = AsList(handlers, "function", callLevel)
	if #handlers == 0 then
		error("Empty handler list", callLevel+1)
	end

	return units, events, handlers
end

local function AddRuleFor(spell, units, events, handlers)
	units, events, handlers = CheckRuleArgs(units, events, handlers, 1)
	return _AddRuleFor(spell, units, events, handlers, 1)
end

local function Configure(spells, units, events, handlers, callLevel)
	callLevel = (callLevel or 0) + 1
	spells = AsList(spells, "number", callLevel)
	if #spells == 0 then
		error("Empty spell list", callLevel+2)
	end
	units, events, handlers = CheckRuleArgs(units, events, handlers, callLevel)
	if #spells == 1 then
		return function()
			_AddRuleFor(spells[1], units, events, handlers, callLevel+1)
		end
	else
		return function()
			for i, spell in pairs(spells) do
				_AddRuleFor(spell, units, events, handlers, callLevel+1)
			end
		end
	end
end

local function IfSpell(spells, ...)
	local spells = AsList(spells, "number", 1)
	local funcs = AsList({ ... }, "function", 1)
	if #spells == 1 then
		local spell = spells[1]
		local link = GetSpellLink(spell)
		return function()
			if LibSpellbook:IsKnown(spell) then
				addon:Debug('Merging rules depending on', link)
				return Do(funcs)
			end
		end
	else
		return function()
			for i, spell in ipairs(spells) do
				if LibSpellbook:IsKnown(spell) then
					addon:Debug('Merging rules depending on', (GetSpellLink(spell)))
					return Do(funcs)
				end
			end
		end
	end
end

local function IfClass(class, ...)
	knownClasses[class] = true
	if playerClass == class then
		local funcs = AsList({ ... }, "function", 1)
		return function()
			addon:Debug('Merging spells for', class)
			return Do(funcs)
		end
	else
		return function()
			return addon:Debug('Ignoring spells for', class)
		end
	end
end

--------------------------------------------------------------------------------
-- Handler builders
--------------------------------------------------------------------------------

local function BuildAuraHandler_Single(filter, highlight, token, spell, callLevel)
	local spellName = GetSpellInfo(spell)
	if not spellName then
		error("Unknown spell "..spell, (callLevel or 0)+2)
	end
	return function(units, model)
		if not units[token] then return end
		local name, _, _, count, _, _, expiration = UnitAura(units[token], spellName, nil, filter)
		if name then
			model.highlight, model.count, model.expiration = highlight, count, expiration
			return true
		end
	end
end

local function BuildAuraHandler_Longest(filter, highlight, token, buffs, callLevel)
	local numBuffs
	buffs, numBuffs = AsSet(buffs, "number", (callLevel or 0)+1)
	if numBuffs == 1 then
		return BuildAuraHandler_Single(filter, highlight, token, next(buffs), (callLevel or 0)+1)
	end
	return function(units, model)
		local unit, longest = units[token], -1
		if not unit then return end
		for i = 1, math.huge do
			local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				if buffs[spellId] and expiration > longest then
					longest = expiration
					model.highlight, model.count, model.expiration = highlight, count, expiration
				end
			else
				break
			end
		end
		return longest > -1
	end
end

local function BuildAuraHandler_FirstOf(filter, highlight, token, buffs, callLevel)
	local numBuffs
	buffs, numBuffs = AsSet(buffs, "number", (callLevel or 0)+1)
	if numBuffs == 1 then
		return BuildAuraHandler_Single(filter, highlight, token, next(buffs), (callLevel or 0)+1)
	end
	return function(units, model)
		local unit = units[token]
		if not unit then return end
		for i = 1, math.huge do
			local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				if buffs[spellId] then
					model.highlight, model.count, model.expiration = highlight, count, expiration
					return true
				end
			else
				return
			end
		end
	end
end

--------------------------------------------------------------------------------
-- High-callLevel helpers
--------------------------------------------------------------------------------

local function Auras(filter, highlight, unit, spells)
	local funcs = {}
	for i, spell in ipairs(AsList(spells, "number", 2)) do
		tinsert(funcs, Configure(spell, unit, "UNIT_AURA", BuildAuraHandler_Single(filter, highlight, unit, spell), 2))
	end
	return (#funcs > 1) and funcs or funcs[1]
end

local function PassiveModifier(passive, spell, buff, unit, highlight)
	unit = unit or "player"
	local conf = Configure(spell, unit, "UNIT_AURA", BuildAuraHandler_Single("HEPLFUL PLAYER", highlight or "good", unit, buff), 1)
	return passive and IfSpell(passive, conf) or conf
end

local function AuraAliases(filter, highlight, unit, spells, buffs)
	buffs = AsList(buffs or spells, "number", 2)
	return Configure(spells, unit, "UNIT_AURA", BuildAuraHandler_FirstOf(filter, highlight, unit, buffs))
end

local function ShowPower(spells, powerType, handler, highlight)
	if type(powerType) ~= "string" then
		error("Invalid power type value, expected string, got "..type(powerType), 2)
	end
	local powerIndex = _G["SPELL_POWER_"..powerType]
	if not powerIndex then
		error("Unknown power "..powerType, 2)
	end
	local actualHandler
	if type(handler) == "function" then
		-- User-supplied handler
		actualHandler = function(_, model)
			return handler(UnitPower("player", powerIndex), UnitPowerMax("player", powerIndex), model, highlight)
		end
	elseif type(handler) == "number" then
		-- A value, handle it as a percentage of total power
		local threshold = handler / 100
		if not highlight then
			highlight = "flash"
		end
		actualHandler = function(_, model)
			local current, maxPower = UnitPower("player", powerIndex), UnitPowerMax("player", powerIndex)
			if current > 0 and maxPower > 0 and current / maxPower >= threshold then
				model.highlight = highlight
			end
		end
	elseif not handler then
		-- Provide a simple handler, that shows the current power value and highlights when it reaches the maximum
		actualHandler = function(_, model)
			local current, maxPower = UnitPower("player", powerIndex), UnitPowerMax("player", powerIndex)
			if current > 0 and maxPower > 0 then
				model.count = current
				if highlight and current == maxPower then
					model.highlight = highlight
				end
			end
		end
	else
		error("Invalid handler type, expected function, number or nil, got "..type(handler), 2)
	end
	return Configure(spells, "player", { "UNIT_POWER", "UNIT_POWER_MAX" }, actualHandler, 1)
end

--------------------------------------------------------------------------------
-- Environment setup
--------------------------------------------------------------------------------

-- Wrap an existing function to accept all its arguments in a table
local function WrapTableArgFunc(func)
	return function(args)
		return func(unpack(args))
	end
end

local RULES_ENV = setmetatable({

	-- Intended to be used un Lua
	AddRuleFor = AddRuleFor,
	BuildAuraHandler_Single = BuildAuraHandler_Single,
	BuildAuraHandler_Longest = BuildAuraHandler_Longest,
	BuildAuraHandler_FirstOf = BuildAuraHandler_FirstOf,

	-- Basic functions
	Configure = WrapTableArgFunc(Configure),
	IfSpell = WrapTableArgFunc(IfSpell),
	IfClass = WrapTableArgFunc(IfClass),
	ShowPower = WrapTableArgFunc(ShowPower),
	PassiveModifier = WrapTableArgFunc(PassiveModifier),

	-- High-callLevel functions

	SimpleDebuffs = function(spells)
		return Auras("HARMFUL PLAYER", "bad", "enemy", spells)
	end,

	SharedSimpleDebuffs = function(spells)
		return Auras("HARMFUL", "bad", "enmey", spells)
	end,

	SimpleBuffs = function(spells)
		return Auras("HELPFUL PLAYER", "good", "ally", spells)
	end,

	SharedSimpleBuffs = function(spells)
		return Auras("HELPFUL", "good", "ally", spells)
	end,

	LongestDebuffOf = function(spells, buffs)
		return Configure(spells, "enemy", "UNIT_AURA", BuildAuraHandler_Longest("HARMFUL", "bad", "enemy", buffs or spells), 1)
	end,

	SelfBuffs = function(spells)
		return Auras("HELPFUL PLAYER", "good", "player", spells)
	end,

	PetBuffs = function(spells)
		return Auras("HELPFUL PLAYER", "good", "pet", spells)
	end,

	BuffAliases = function(args)
		return AuraAliases("HELPFUL PLAYER", "good", "ally", unpack(args))
	end,

	DebuffAliases = function(args)
		return AuraAliases("HARMFUL PLAYER", "bad", "enemy", unpack(args))
	end,

	SelfBuffAliases = function(args)
		return AuraAliases("HELPFUL PLAYER", "good", "player", unpack(args))
	end,

}, { __index = _G })

--------------------------------------------------------------------------------
-- Rule loading and updating
--------------------------------------------------------------------------------

local rules

function addon:LibSpellbook_Spells_Changed(event)
	addon:Debug(event)
	if not rules then
		rules = setfenv(addon.CreateRules, RULES_ENV)()
		if not knownClasses[playerClass] then
			print(addonName.." has not specific rules for your class and will only handle common spells.")
		end
	end
	wipe(spellConfs)
	Do(rules)
	self:SendMessage(addonName..'_RulesUpdated')
end
