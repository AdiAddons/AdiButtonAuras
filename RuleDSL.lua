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
local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink
local UnitAura = _G.UnitAura
local UnitClass = _G.UnitClass
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local assert = _G.assert
local error = _G.error
local format = _G.format
local geterrorhandler = _G.geterrorhandler
local ipairs = _G.ipairs
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local setfenv = _G.setfenv
local setmetatable = _G.setmetatable
local strjoin = _G.strjoin
local strmatch = _G.strmatch
local tinsert = _G.tinsert
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type
local unpack = _G.unpack
local wipe = _G.wipe
local xpcall = _G.xpcall

------------------------------------------------------------------------------
-- Generic list and set tools
------------------------------------------------------------------------------

local function errorhandler(...) return geterrorhandler()(...) end

local getkeys = addon.getkeys

local function Do(funcs)
	for j, func in ipairs(funcs) do
		xpcall(func, errorhandler)
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
		if checkType then
			for i, v in ipairs(value) do
				if type(v) ~= checkType then
					error(format("Invalid value type, expected %s, got %s", checkType, type(v)), callLevel+1)
				end
			end
		end
		return value
	elseif checkType == nil or type(value) == checkType then
		return { value }
	else
		error(format("Invalid value type, expected %s, got %s", checkType, type(value)), callLevel+1)
	end
end

local function AsSet(value, checkType, callLevel)
	local set = {}
	local size = 0
	for i, value in ipairs(AsList(value, checkType, callLevel+1)) do
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

------------------------------------------------------------------------------
-- Rule creation
------------------------------------------------------------------------------

local LibSpellbook = addon.GetLib('LibSpellbook-1.0')

local playerClass = select(2, UnitClass("player"))
local knownClasses = {}
local spellConfs = {}
addon.spells = spellConfs
addon.knownClasses = knownClasses

local function SpellOrItemId(value, callLevel)
	local spellId = tonumber(type(value) == "string" and strmatch(value, "spell:(%d+)") or value)
	if spellId then
		if not GetSpellInfo(spellId) then
			error(format("Invalid spell identifier: %s", tostring(value)), callLevel+1)
		elseif not LibSpellbook:IsKnown(spellId) then
			return nil -- Unknown spell
		end
		return format("spell:%d", spellId), "spell "..GetSpellLink(spellId)
	end
	local itemId = tonumber(strmatch(tostring(value), "item:(%d+)"))
	if itemId then
		local _, link = GetItemInfo(itemId)
		return format("item:%d", itemId), "item "..tostring(link)
	end
	error(format("Invalid spell or item identifier: %s", tostring(value)), callLevel+1)
end

local function _AddRuleFor(spell, units, events, handlers, callLevel)
	local id, info = SpellOrItemId(spell, callLevel)
	if not id then
		return
	end
	addon.Debug('Rules', "Adding rule for", info,
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
	local numUnits, numEvents

	units, numUnits = AsSet(units, "string", callLevel+1)
	if numUnits == 0 then
		error("Empty unit list", callLevel+1)
	end

	events, numEvents = AsSet(events, "string", callLevel+1)
	if numEvents == 0 then
		error("Empty event list", callLevel+1)
	end

	handlers = AsList(handlers, "function", callLevel+1)
	if #handlers == 0 then
		error("Empty handler list", callLevel+1)
	end

	return units, events, handlers
end

local function AddRuleFor(spell, units, events, handlers)
	units, events, handlers = CheckRuleArgs(units, events, handlers, 2)
	return _AddRuleFor(spell, units, events, handlers, 2)
end

local function Configure(spells, units, events, handlers, callLevel)
	callLevel = callLevel or 1
	spells = AsList(spells)
	if #spells == 0 then
		error("Empty spell list", callLevel+1)
	end
	units, events, handlers = CheckRuleArgs(units, events, handlers, callLevel+1)
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
	local spells = AsList(spells, "number", 2)
	local funcs = AsList({ ... }, "function", 2)
	if #spells == 1 then
		local spell = spells[1]
		local link = GetSpellLink(spell)
		return function()
			if LibSpellbook:IsKnown(spell) then
				addon.Debug('Rules', 'Merging rules depending on', link)
				return Do(funcs)
			end
		end
	else
		return function()
			for i, spell in ipairs(spells) do
				if LibSpellbook:IsKnown(spell) then
					addon.Debug('Rules', 'Merging rules depending on', (GetSpellLink(spell)))
					return Do(funcs)
				end
			end
		end
	end
end

local function IfClass(class, ...)
	knownClasses[class] = true
	if playerClass == class then
		local funcs = AsList({ ... }, "function", 2)
		return function()
			addon.Debug('Rules', 'Merging spells for', class)
			return Do(funcs)
		end
	else
		return function()
			return addon.Debug('Rules', 'Ignoring spells for', class)
		end
	end
end

------------------------------------------------------------------------------
-- Handler builders
------------------------------------------------------------------------------

local function BuildAuraHandler_Single(filter, highlight, token, spell, callLevel)
	local spellName = GetSpellInfo(spell)
	if not spellName then
		error("Unknown spell "..spell, (callLevel or 1)+1)
	end
	return function(units, model)
		if not units[token] then return end
		local name, _, _, count, _, _, expiration = UnitAura(units[token], spellName, nil, filter)
		if name then
			if highlight == "flash" or model.highlight ~= "flash" then
				model.highlight = highlight
			end
			model.count, model.expiration = count, expiration
			return true
		end
	end
end

local function BuildAuraHandler_Longest(filter, highlight, token, buffs, callLevel)
	callLevel = callLevel or 1
	local numBuffs
	buffs, numBuffs = AsSet(buffs, "number", callLevel+1)
	if numBuffs == 1 then
		return BuildAuraHandler_Single(filter, highlight, token, next(buffs), callLevel+1)
	end
	return function(units, model)
		local unit, longest = units[token], -1
		if not unit then return end
		for i = 1, math.huge do
			local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				if buffs[spellId] and expiration > longest then
					longest = expiration
					if highlight == "flash" or model.highlight ~= "flash" then
						model.highlight = highlight
					end
					model.count, model.expiration = count, expiration
				end
			else
				break
			end
		end
		return longest > -1
	end
end

local function BuildAuraHandler_FirstOf(filter, highlight, token, buffs, callLevel)
	callLevel = callLevel or 1
	local numBuffs
	buffs, numBuffs = AsSet(buffs, "number", callLevel+1)
	if numBuffs == 1 then
		return BuildAuraHandler_Single(filter, highlight, token, next(buffs), callLevel+1)
	end
	return function(units, model)
		local unit = units[token]
		if not unit then return end
		for i = 1, math.huge do
			local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				if buffs[spellId] then
					if highlight == "flash" or model.highlight ~= "flash" then
						model.highlight = highlight
					end
					model.count, model.expiration = count, expiration
					return true
				end
			else
				return
			end
		end
	end
end

------------------------------------------------------------------------------
-- High-callLevel helpers
------------------------------------------------------------------------------

local function Auras(filter, highlight, unit, spells)
	local funcs = {}
	for i, spell in ipairs(AsList(spells, "number", 2)) do
		tinsert(funcs, Configure(spell, unit, "UNIT_AURA", BuildAuraHandler_Single(filter, highlight, unit, spell, 2), 2))
	end
	return (#funcs > 1) and funcs or funcs[1]
end

local function PassiveModifier(passive, spell, buff, unit, highlight)
	unit = unit or "player"
	highlight = highlight or "good"
	local handler = BuildAuraHandler_Single("HEPLFUL PLAYER", highlight, unit, buff, 3)
	local conf = Configure(spell, unit, "UNIT_AURA", handler, 3)
	return passive and IfSpell(passive, conf) or conf
end

local function AuraAliases(filter, highlight, unit, spells, buffs)
	buffs = AsList(buffs or spells, "number", 3)
	return Configure(spells, unit, "UNIT_AURA", BuildAuraHandler_FirstOf(filter, highlight, unit, buffs, 3), 3)
end

local function ItemSelfBuffs(...)
	local funcs = {}
	for i = 1, select("#", ...), 2 do
		local item, buffs = select(i, ...)
		if type(item) ~= "string" then
			error(format("%dth item should be a string, not %s", (i+1)/2, type(item)), 3)
		elseif not strmatch(item, "^item:%d+$") then
			error(format("%q is an invalid item", item), 3)
		end
		buffs = AsList(buffs, "number", 3)
		local handler = BuildAuraHandler_FirstOf("PLAYER HELPFUL", "good", "player", buffs, 3)
		local rule = Configure(item, "player", "UNIT_AURA", handler, 3)
		tinsert(funcs, rule)
	end
	return (#funcs > 1) and funcs or funcs[1]
end

local function ShowPower(spells, powerType, handler, highlight)
	if type(powerType) ~= "string" then
		error("Invalid power type value, expected string, got "..type(powerType), 3)
	end
	local powerIndex = _G["SPELL_POWER_"..powerType]
	if not powerIndex then
		error("Unknown power "..powerType, 3)
	end
	local actualHandler
	if type(handler) == "function" then
		-- User-supplied handler
		actualHandler = function(_, model)
			return handler(UnitPower("player", powerIndex), UnitPowerMax("player", powerIndex), model, highlight)
		end
	elseif type(handler) == "number" then
		-- A number
		local sign = handler < 0 and -1 or 1
		if not highlight then
			highlight = "flash"
		end
		if handler >= -1.0 and handler <= 1.0 then
			-- Consider the handler as a percentage
			actualHandler = function(_, model)
				local current, maxPower = UnitPower("player", powerIndex), UnitPowerMax("player", powerIndex)
				if maxPower ~= 0 and sign * current / maxPower >= handler then
					model.highlight = highlight
				end
			end
		else
			-- Consider the handler as a an absolute value
			actualHandler = function(_, model)
				local current, maxPower = UnitPower("player", powerIndex)
				if UnitPowerMax("player", powerIndex) ~= 0 and sign * current >= handler then
					model.highlight = highlight
				end
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
		error("Invalid handler type, expected function, number or nil, got "..type(handler), 3)
	end
	return Configure(spells, "player", { "UNIT_POWER", "UNIT_POWER_MAX" }, actualHandler, 3)
end

local function FilterOut(spells, exclude)
	local result = {}
	for _, spell in ipairs(spells) do
		if not exclude[spell] then
			tinsert(result, spell)
		end
	end
	return result
end

local ImportPlayerSpells
do
	local LibPlayerSpells = addon.GetLib('LibPlayerSpells-1.0')
	local band = bit.band
	local UNIQUE_AURA = LibPlayerSpells.constants.UNIQUE_AURA
	local TARGETING = LibPlayerSpells.masks.TARGETING
	local HARMFUL = LibPlayerSpells.constants.HARMFUL
	local PERSONAL = LibPlayerSpells.constants.PERSONAL
	local PET = LibPlayerSpells.constants.PET
	local IMPORTANT = LibPlayerSpells.constants.IMPORTANT

	function ImportPlayerSpells(filter, ...)
		local exceptions = AsSet({...}, "number", 3)
		local rules = {}
		for buff, flags, provider, modified in LibPlayerSpells:IterateSpells(filter, "AURA", "RAIDBUFF") do
			if not exceptions[buff] and not exceptions[provider] then
				local spells = FilterOut(AsList(modified, "number"), exceptions)
				if #spells > 0 then
					local filter, highlight, token = "HELPFUL", "good", "ally"
					local targeting = band(flags, TARGETING)
					if targeting == HARMFUL then
						filter, highlight, token = "HARMFUL", "bad", "enemy"
					elseif targeting == PERSONAL then
						token = "player"
					elseif targeting == PET then
						token = "pet"
					end
					if band(flags, UNIQUE_AURA) == 0 then
						filter = filter.." PLAYER"
					end
					if band(flags, IMPORTANT) ~= 0 then
						highlight = "flash"
					end
					local handler = BuildAuraHandler_Single(filter, highlight, token, buff, 3)
					local rule = Configure(spells, token, "UNIT_AURA", handler, 3)
					if provider ~= modified then
						rule = IfSpell(provider, rule)
					end
					tinsert(rules, rule)
				end
			end
		end
		return (#rules > 1) and rules or rules[1]
	end
end

------------------------------------------------------------------------------
-- Environment setup
------------------------------------------------------------------------------

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
	ItemSelfBuffs = WrapTableArgFunc(ItemSelfBuffs),
	ImportPlayerSpells = WrapTableArgFunc(ImportPlayerSpells),

	-- High-level functions

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
		return Configure(spells, "enemy", "UNIT_AURA", BuildAuraHandler_Longest("HARMFUL", "bad", "enemy", buffs or spells, 2), 2)
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

------------------------------------------------------------------------------
-- Rule loading and updating
------------------------------------------------------------------------------

local rules
local ruleBuilders = {}

function addon:BuildRules(event)
	if not rules then
		addon.Debug('Rules', 'Building rules', event)
		if #ruleBuilders == 0 then
			error("No rules registered !", 2)
		end
		wipe(knownClasses)
		local t = {}
		for i, builder in ipairs(ruleBuilders) do
			local ok, funcs = xpcall(builder, errorhandler)
			if ok and funcs then
				tinsert(t, funcs)
			end
		end
		rules = AsList(t, "function")
		addon.Debug('Rules', #rules, 'rules found')
	end
	return rules
end

function addon:LibSpellbook_Spells_Changed(event)
	addon:Debug(event)
	wipe(spellConfs)
	Do(self:BuildRules())
	self:SendMessage(addonName..'_RulesUpdated')
end

function addon.api:RegisterRules(builder)
	setfenv(builder, RULES_ENV)
	tinsert(ruleBuilders, function() return builder(addon) end)
	if rules then
		addon.Debug('Rules', 'Rebuilding rules')
		rules = nil
		return addon:LibSpellbook_Spells_Changed('RegisterRules')
	end
end
