--[[
LuaAuras - Enhance action buttons using Lua handlers.
Copyright 2013 Adirelle (adirelle@gmail.com)
All rights reserved.
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

local function NOOP() end

local function _AddRuleFor(spell, units, events, handlers)
	if not LibSpellbook:IsKnown(spell) then return end
	addon:Debug("Adding rule for", (GetSpellInfo(spell)))
	addon:Debug('- units:', getkeys(units))
	addon:Debug('- events:', getkeys(events))
	addon:Debug('- handlers:', handlers)
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
	units = AsSet(units or "default", "string")
	events = AsSet(events, "string")
	handlers = AsList(handlers, "function")
	return function()
		for i, spell in ipairs(spells) do
			_AddRuleFor(spell, units, events, handlers)
		end
	end
end

local function IfSpell(args)
	local spells = AsList(tremove(args, 1), "number")
	local funcs = AsList(args, "function")
	return function()
		for i, spell in ipairs(spells) do
			if LibSpellbook:IsKnown(spell) then
				addon:Debug('Merging spells depending on', (GetSpellInfo(spell)))
				return Do(funcs)
			end
		end
	end
end

local playerClass = select(2, UnitClass("player"))
local function IfClass(args)
	local _debug = false
	--@debug@--
	_debug = true
	--@end-debug@--
	local class = tremove(args, 1)
	if _debug or playerClass == class then
		local funcs = AsList(args, "function")
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

local function SimpleAuras(filter, highlight, spells)
	local funcs = {}
	for i, spell in ipairs(AsList(spells, "number")) do
		local spellName = assert(GetSpellInfo(spell), "Unknown spell "..spell)
		tinsert(funcs, Configure(
			spell,
			"default",
			"UNIT_AURA",
			function(unit, model)
				local name, _, _, count, _, _, expiration = UnitAura(unit, spellName, nil, filter)
				if name then
					model.highlight, model.count, model.expiration = highlight, count, expiration
				end
			end
		))
	end
	return funcs
end

local function SimpleDebuffs(spells)
	return SimpleAuras("HARMFUL PLAYER", "bad", spells)
end

local function SharedSimpleDebuffs(spells)
	return SimpleAuras("HARMFUL", "bad", spells)
end

local function SimpleBuffs(spells)
	return SimpleAuras("HELPFUL PLAYER", "good", spells)
end

local function LongestDebuffOf(spells, buffs)
	buffs = AsSet(buffs or spells, "number")
	return Configure(
		spells,
		"default",
		"UNIT_AURA",
		function(unit, model)
			local longest = -1
			for i = 1, math.huge do
				local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, "HARMFUL")
				if name then
					if buffs[spellId] and expiration > longest then
						longest = expiration
						model.highlight, model.count, model.expiration = "bad", count, expiration
					end
				else
					return
				end
			end
		end
	)
end

local function UnitBuffs(unit, filter, spells)
	local funcs = {}
	for i, spell in ipairs(AsList(spells, "number")) do
		local spell, unit, filter = spell, unit, filter
		local spellName = assert(GetSpellInfo(spell), "Unknown spell "..spell)
		tinsert(funcs, Configure(
			spell,
			unit,
			"UNIT_AURA",
			function(_, model)
				local name, _, _, count, _, _, expiration = UnitAura(unit, spellName, nil, filter)
				if name then
					model.highlight, model.count, model.expiration = "good", count, expiration
				end
			end
		))
	end
	return funcs
end

local function SelfBuffs(spells)
	return UnitBuffs("player", "HELPFUL PLAYER", spells)
end

local function PetBuffs(spells)
	return UnitBuffs("pet", "HELPFUL PLAYER", spells)
end

local function PassiveModifier(args)
	local passive, spell, buff, unit = unpack(args)
	local buffName = assert(GetSpellInfo(buff), "Unknown spell "..buff)
	unit = unit or "player"
	local conf = Configure(
		spell,
		unit,
		"UNIT_AURA",
		function(_, model)
			local name, _, _, count, _, _, expiration = UnitAura(unit, buffName, nil, "HEPLFUL PLAYER")
			if name then
				model.highlight, model.count, model.expiration = "good", count, expiration
			end
		end
	)
	if passive then
		return IfSpell{passive, conf}
	else
		return conf
	end
end

RULES_ENV = setmetatable({
	AddRuleFor = AddRuleFor,
	Configure = Configure,
	IfSpell = IfSpell,
	IfClass = IfClass,
	SimpleAuras = SimpleAuras,
	SimpleBuffs = SimpleBuffs,
	SimpleDebuffs = SimpleDebuffs,
	SharedSimpleDebuffs = SharedSimpleDebuffs,
	UnitBuffs = UnitBuffs,
	SelfBuffs = SelfBuffs,
	PetBuffs = PetBuffs,
	PassiveModifier = PassiveModifier,
	LongestDebuffOf = LongestDebuffOf,
}, { __index = _G })
