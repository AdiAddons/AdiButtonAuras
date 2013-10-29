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

local LibSpellbook = LibStub('LibSpellbook-1.0')
local LibAdiEvent = LibStub('LibAdiEvent-1.0')

local function Do(funcs)
	for j, func in ipairs(funcs) do
					func()
	end
end

local spellConfig = {}
local rules
local RULES_ENV

addon.spells = spellConfig

function addon:LibSpellbook_Spells_Changed()
	addon:Debug('LibSpellbook_Spells_Changed')
	if not rules then
		rules = setfenv(addon.CreateRules, RULES_ENV)()
	end
	wipe(spellConfig)
	Do(rules)
end

LibSpellbook.RegisterCallback(addon, 'LibSpellbook_Spells_Changed')
if LibSpellbook:HasSpells() then
	addon:LibSpellbook_Spells_Changed()
end

local function AsList(value, checkType)
	if type(value) == "table" then
		if checkType then
			for i, v in ipairs(value) do
				assert(type(v) == checkType)
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

local function ConcatLists(a, b)
	for i, v in ipairs(b) do
		tinsert(a, v)
	end
	return a
end

local function NOOP() end

local function Configure(spells, units, events, handlers)
	spells = AsList(spells, "number")
	units = AsSet(units or "default", "string")
	events = AsSet(events, "string")
	handlers = AsList(handlers, "function")
	return function()
		for i, spell in ipairs(spells) do
			if LibSpellbook:IsKnown(spell) then
				addon:Debug("Adding rule for", (GetSpellInfo(spell)))
				local rule = spellConfig[spell]
				if not rule then
					rule = { units = {}, events = {}, handlers = {} }
					spellConfig[spell] = rule
				end
				MergeSets(rule.units, units)
				MergeSets(rule.events, events)
				ConcatLists(rule.handlers, handlers)
			end
		end
	end
end

local function IfSpell(args)
	local spells = AsList(tremove(args, 1), "number")
	return function()
		for i, spell in ipairs(spells) do
			if LibSpellbook:IsKnown(spell) then
				addon:Debug('Merging spells depending on', (GetSpellInfo(spell)))
				return Do(args)
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
		return function()
			addon:Debug('Merging spells for', class)
			return Do(args)
		end
	else
		return function()
			return addon:Debug('Ignoring spells for', class)
		end
	end
end

local function SimpleAura(filter, spell)
	local spellName = assert(GetSpellInfo(spell), "Unknown spell "..spell)
	return Configure(
		spell,
		"default",
		"UNIT_AURA",
		function(unit)
			return UnitAura(unit, spellName, filter)
		end
	)
end

local function SimpleDebuff(...)
	return SimpleAura("HARMFULL PLAYER", ...)
end

local function SimpleBuff(...)
	return SimpleAura("HELPFUL PLAYER", ...)
end

local function SelfBuff(spell)
	local spellName = assert(GetSpellInfo(spell), "Unknown spell "..spell)
	return Configure(
		spell,
		"player",
		"UNIT_AURA",
		function()
			return UnitAura("player", spellName, "HEPLFUL PLAYER")
		end
	)
end

RULES_ENV = setmetatable({
	Configure = Configure,
	IfSpell = IfSpell,
	IfClass = IfClass,
	SimpleBuff = SimpleBuff,
	SimpleDebuff = SimpleDebuff,
}, { __index = _G })

function addon.CreateRules()
	addon:Debug('Creating Rules')
	return {
		IfClass{"HUNTER",
			SimpleDebuff(1978), -- Serpent String
			SelfBuff(3045), -- Rapid Fire
		},
	}
end

addon:Debug('Spells loaded')
