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
local assert = _G.assert
local error = _G.error
local ipairs = _G.ipairs
local pairs = _G.pairs
local select = _G.select
local setfenv = _G.setfenv
local setmetatable = _G.setmetatable
local tinsert = _G.tinsert
local type = _G.type
local UnitClass = _G.UnitClass
local wipe = _G.wipe

local getkeys = addon.getkeys

local LibSpellbook = LibStub('LibSpellbook-1.0')
local LibAdiEvent = LibStub('LibAdiEvent-1.0')

local function Do(funcs)
	for j, func in ipairs(funcs) do
		func()
	end
end

local spellConfs = {}
local rules
local RULES_ENV

addon.spells = spellConfs

function addon:LibSpellbook_Spells_Changed(event)
	addon:Debug('LibSpellbook_Spells_Changed')
	if not rules then
		rules = setfenv(addon.CreateRules, RULES_ENV)()
	end
	wipe(spellConfs)
	Do(rules)
	addon:UpdateAllOverlays(event)
end

LibSpellbook.RegisterCallback(addon, 'LibSpellbook_Spells_Changed')
if LibSpellbook:HasSpells() then
	addon:LibSpellbook_Spells_Changed('OnLoad')
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

local function AsList(value, checkType)
	if type(value) == "table" then
		value = FlattenList(value)
		if checkType then
			for i, v in ipairs(value) do
				assert(type(v) == checkType, format("%s expected, not %s", checkType, type(v)))
			end
		end
		return value
	elseif not checkType or type(value) == checkType then
		return { value }
	else
		error(2, "Invalid value type for AsList, expected "..checkType..", got "..type(value))
	end
end

local function AsSet(value, checkType)
	local s = {}
	for i, v in ipairs(AsList(value, checkType)) do
		s[v] = true
	end
	return s
end

local function MergeSets(a, b)
	for k in pairs(b) do
		a[k] = true
	end
	return a
end

local function GetSetSize(set)
	local n = 0
	for k in pairs(set) do
		n = n + 1
	end
	return n
end

local function NOOP() end

local function _AddRuleFor(spell, units, events, handlers)
	if not LibSpellbook:IsKnown(spell) then return end
	addon:Debug("Adding rule for", GetSpellLink(spell),
		"units:", strjoin(",", getkeys(units)),
		"events:", strjoin(",", getkeys(events)),
		"handlers:", handlers
	)
	local rule = spellConfs[spell]
	if not rule then
		rule = { units = {}, events = {}, handlers = {} }
		spellConfs[spell] = rule
	end
	MergeSets(rule.units, units)
	MergeSets(rule.events, events)
	ConcatLists(rule.handlers, handlers)
end

local function AddRuleFor(spell, units, events, handlers)
	return _AddRuleFor(
		spell,
		AsSet(units or "default", "string"),
		AsSet(events, "string"),
		AsList(handlers, "function")
	)
end

local function Configure(spells, units, events, handlers)
	spells = AsList(spells, "number")
	assert(#spells > 0, "No spells given to Configure")
	units = AsSet(units or "default", "string")
	assert(GetSetSize(units) > 0, "No units given to Configure")
	events = AsSet(events, "string")
	assert(GetSetSize(events) > 0, "No events given to Configure")
	handlers = AsList(handlers, "function")
	assert(#handlers > 0, "No handlers given to Configure")
	if #spells == 1 then
		return function()
			_AddRuleFor(spells[1], units, events, handlers)
		end
	else
		return function()
			for i, spell in ipairs(spells) do
				_AddRuleFor(spell, units, events, handlers)
			end
		end
	end
end

local function IfSpell(spells, ...)
	local spells = AsList(spells, "number")
	local funcs = AsList({ ... }, "function")
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

local playerClass = select(2, UnitClass("player"))
local function IfClass(class, ...)
	if playerClass == class then
		local funcs = AsList({ ... }, "function")
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

local function BuildAuraHandler_Single(filter, highlight, spell)
	local spellName = assert(GetSpellInfo(spell), "Unknown spell "..spell)
	return function(unit, model)
		local name, _, _, count, _, _, expiration = UnitAura(unit, spellName, nil, filter)
		if name then
			model.highlight, model.count, model.expiration = highlight, count, expiration
		end
	end
end

local function BuildAuraHandler_Single_Unit(filter, highlight, unit, spell)
	local spellName = assert(GetSpellInfo(spell), "Unknown spell "..spell)
	return function(_, model)
		local name, _, _, count, _, _, expiration = UnitAura(unit, spellName, nil, filter)
		if name then
			model.highlight, model.count, model.expiration = highlight, count, expiration
		end
	end
end

local function BuildAuraHandler_Longest(filter, highlight, buffs)
	buffs = AsSet(buffs, "number")
	if GetSetSize(buffs) == 1 then
		local buff = next(buffs)
		return BuildAuraHandler_Single(filter, highlight, buff)
	end
	return function(unit, model)
		local longest = -1
		for i = 1, math.huge do
			local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				if buffs[spellId] and expiration > longest then
					longest = expiration
					model.highlight, model.count, model.expiration = highlight, count, expiration
				end
			else
				return
			end
		end
	end
end

local function BuildAuraHandler_FirstOf(filter, highlight, buffs)
	buffs = AsSet(buffs, "number")
	if GetSetSize(buffs) == 1 then
		local buff = next(buffs)
		return BuildAuraHandler_Single(filter, highlight, buff)
	end
	return function(unit, model)
		for i = 1, math.huge do
			local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				if buffs[spellId] then
					model.highlight, model.count, model.expiration = highlight, count, expiration
					return
				end
			else
				return
			end
		end
	end
end

local function BuildAuraHandler_FirstOf_Unit(filter, highlight, unit, buffs)
	buffs = AsSet(buffs, "number")
	if GetSetSize(buffs) == 1 then
		local buff = next(buffs)
		return BuildAuraHandler_Single_Unit(filter, highlight, unit, buff)
	end
	return function(_, model)
		for i = 1, math.huge do
			local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				if buffs[spellId] then
					model.highlight, model.count, model.expiration = highlight, count, expiration
					return
				end
			else
				return
			end
		end
	end
end

local function Auras(filter, highlight, spells)
	local funcs = {}
	for i, spell in ipairs(AsList(spells, "number")) do
		tinsert(funcs, Configure(spell, "default", "UNIT_AURA", BuildAuraHandler_Single(filter, highlight, spell)))
	end
	return (#funcs > 1) and funcs or funcs[1]
end

local function Auras_Unit(filter, highlight, unit, spells)
	local funcs = {}
	for i, spell in ipairs(AsList(spells, "number")) do
		tinsert(funcs, Configure(spell, unit, "UNIT_AURA", BuildAuraHandler_Single_Unit(filter, highlight, unit, spell)))
	end
	return (#funcs > 1) and funcs or funcs[1]
end

local function PassiveModifier(passive, spell, buff, unit, highlight)
	unit = unit or "player"
	local conf = Configure(spell, unit, "UNIT_AURA", BuildAuraHandler_Single_Unit("HEPLFUL PLAYER", highlight or "good", unit, buff))
	return passive and IfSpell(passive, conf) or conf
end

local function AuraAliases(filter, highlight, spells, buffs)
	buffs = AsList(buffs or spells, "number")
	return Configure(spells, "default", "UNIT_AURA",  BuildAuraHandler_FirstOf(filter, highlight, buffs))
end

local function AuraAliases_Unit(filter, highlight, unit, spells, buffs)
	buffs = AsList(buffs or spells, "number")
	return Configure(spells, unit, "UNIT_AURA", BuildAuraHandler_FirstOf_Unit(filter, highlight, unit, buffs))
end

local function WrapTableArgFunc(func)
	return function(args)
		return func(unpack(args))
	end
end

RULES_ENV = setmetatable({
	AddRuleFor = WrapTableArgFunc(AddRuleFor),

	Configure = WrapTableArgFunc(Configure),

	IfSpell = WrapTableArgFunc(IfSpell),

	IfClass = WrapTableArgFunc(IfClass),

	PassiveModifier = function(args)
		return PassiveModifier(unpack(args))
	end,

	SimpleDebuffs = function(spells)
		return Auras("HARMFUL PLAYER", "bad", spells)
	end,

	SharedSimpleDebuffs = function(spells)
		return Auras("HARMFUL", "bad", spells)
	end,

	SimpleBuffs = function(spells)
		return Auras("HELPFUL PLAYER", "good", spells)
	end,

	LongestDebuffOf = function(spells, buffs)
		return Configure(spells, "default", "UNIT_AURA", BuildAuraHandler_Longest("HARMFUL", "bad", buffs or spells))
	end,

	SelfBuffs = function(spells)
		return Auras_Unit("HELPFUL PLAYER", "good", "player", spells)
	end,

	PetBuffs = function(spells)
		return Auras_Unit("HELPFUL PLAYER", "good", "pet", spells)
	end,

	BuffAliases = function(args)
		return AuraAliases("HELPFUL PLAYER", "good", unpack(args))
	end,

	DebuffAliases = function(args)
		return AuraAliases("HARMFUL PLAYER", "bad", unpack(args))
	end,

	SelfBuffAliases = function(args)
		return AuraAliases_Unit("HELPFUL PLAYER", "good", "player", unpack(args))
	end,

}, { __index = _G })
