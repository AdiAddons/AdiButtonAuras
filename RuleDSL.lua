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

local getkeys = addon.getkeys
local ucfirst = addon.ucfirst

local LibPlayerSpells = addon.GetLib('LibPlayerSpells-1.0')

-- Local debug with dedicated prefix
local function Debug(...) return addon.Debug('|cffffff00Rules:|r', ...) end

------------------------------------------------------------------------------
-- Generic list and set tools
------------------------------------------------------------------------------

local function errorhandler(msg)
	Debug('|cffff0000'..tostring(msg)..'|r')
	return geterrorhandler()(msg)
end


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

local BuildKey
do
	local function BuildKey0(value, ...)
		if type(value) == "table" then
			return BuildKey(unpack(value)), BuildKey0(...)
		elseif value then
			return tostring(value), BuildKey0(...)
		end
	end

	function BuildKey(...)
		return strjoin(':', BuildKey0(...))
	end
end
addon.BuildKey = BuildKey

------------------------------------------------------------------------------
-- Rule creation
------------------------------------------------------------------------------

local LibSpellbook = addon.GetLib('LibSpellbook-1.0')

local playerClass = select(2, UnitClass("player"))
local spellConfs = {}
local ruleDescs = {}
addon.spells = spellConfs
addon.ruleDescs = ruleDescs

local function SpellOrItemId(value, callLevel)
	local spellId = tonumber(type(value) == "string" and strmatch(value, "spell:(%d+)") or value)
	if spellId then
		local name = GetSpellInfo(spellId)
		if not name then
			error(format("Invalid spell identifier: %s", tostring(value)), callLevel+1)
		end
		return format("spell:%d", spellId), "spell "..(GetSpellLink(spellId) or spellId), name, "spell", spellId
	end
	local itemId = tonumber(strmatch(tostring(value), "item:(%d+)"))
	if itemId then
		local name, link = GetItemInfo(itemId)
		return format("item:%d", itemId), link and ("item "..tostring(link)) or value, name or value, "item"
	end
	error(format("Invalid spell or item identifier: %s", tostring(value)), callLevel+1)
end

local function CheckAvailability(info, spellId, providers)
	if not LibSpellbook:IsKnown(spellId) then
		Debug('Unknown spell:', info)
		return false
	end
	if not providers then return true end
	for _, provider in ipairs(providers) do
		if LibSpellbook:IsKnown(provider) then
			return true
		end
	end
	Debug(info..', no providers found: ', unpack(providers))
	return false
end

local function _AddRuleFor(key, desc, spell, units, events, handlers, providers, callLevel)
	local id, info, name, _type, subId = SpellOrItemId(spell, callLevel)
	if not id or (_type == "spell" and not CheckAvailability(info, subId, providers)) then
		return
	end
	if key then
		key = id..':'..key
		desc = gsub(desc or "", "@NAME", name)
		ruleDescs[key] = ucfirst(desc)
	end
	Debug("Adding rule for", info,
		"key:", key,
		"desc:", desc,
		"units:", strjoin(",", getkeys(units)),
		"events:", strjoin(",", getkeys(events)),
		"handlers:", handlers,
		"providers:", providers and strjoin(",", unpack(providers)) or "-"
	)
	local rule = spellConfs[id]
	if not rule then
		rule = { units = {}, events = {}, handlers = {}, keys = {} }
		spellConfs[id] = rule
	end
	if key then
		tinsert(rule.keys, key)
		if not addon.db.profile.rules[key] then
			return
		end
	end
	MergeSets(rule.units, units)
	MergeSets(rule.events, events)
	ConcatLists(rule.handlers, handlers)
end

local function CheckRuleArgs(units, events, handlers, providers, callLevel)
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

	providers = providers and AsList(providers, "number", callLevel+1) or nil

	return units, events, handlers, providers
end

local function AddRuleFor(key, desc, spell, units, events, handlers, providers)
	units, events, handlers, providers = CheckRuleArgs(units, events, handlers, providers, 2)
	return _AddRuleFor(key, desc, spell, units, events, handlers, providers, 2)
end

local function Configure(key, desc, spells, units, events, handlers, providers, callLevel)
	callLevel = callLevel or 1
	spells = AsList(spells)
	if #spells == 0 then
		error("Empty spell list", callLevel+1)
	end
	units, events, handlers, providers = CheckRuleArgs(units, events, handlers, providers, callLevel+1)
	local rules = {}
	for i, spell in ipairs(spells) do
		local spell = spell
		tinsert(rules, function()
			_AddRuleFor(key, desc, spell, units, events, handlers, providers, callLevel+1)
		end)
	end
	return #rules == 1 and rules[1] or rules
end

------------------------------------------------------------------------------
-- Rule description
------------------------------------------------------------------------------

local L = addon.L
local filterDescs = {
	["HELPFUL"] = L['the buff'],
	["HARMFUL"] = L['the debuff'],
	["HELPFUL PLAYER"] = L['your buff'],
	["HARMFUL PLAYER"] = L['your debuff'],
}
local tokenDescs = {
	player = L['yourself'],
	pet    = L['your pet'],
	ally   = L['the targeted ally'],
	enemy  = L['the targeted enemy'],
	group  = L['the group members'],
}
local highlightDescs = {
	flash   = L['flash'],
	good    = L['show the "good" border'],
	bad     = L['show the "bad" border'],
	lighten = L['lighten'],
	darken  = L['darken'],
	hint    = L['suggest'], -- Not really an highlight but who cares ?
}

local function DescribeHighlight(highlight)
	return highlight and highlightDescs[highlight] or L["show duration and/or stack count"]
end

local function DescribeFilter(filter)
	return filter and (filterDescs[filter] or tostring(filter)) or ""
end

local function DescribeAllTokens(token, ...)
	if token ~= nil then
		return tokenDescs[token] or token, DescribeAllTokens(...)
	end
end

local function DescribeAllSpells(id, ...)
	if id ~= nil then
		local name = type(id) == "number" and GetSpellInfo(id) or tostring(id)
		return name, DescribeAllSpells(...)
	end
end

local function BuildDesc(filter, highlight, token, spell)
	local tokens = type(token) == "table" and DescribeAllTokens(unpack(token)) or DescribeAllTokens(token)
	local spells = type(spell) == "table" and DescribeAllSpells(unpack(spell)) or DescribeAllSpells(spell)
	return gsub(format(
		L["%s when %s %s is found on %s."],
		DescribeHighlight(highlight),
		DescribeFilter(filter),
		spells or "",
		tokens or "?"
	), "%s+", " ")
end

local function DescribeLPSSource(category)
	if category then
		local _, interface, rev = LibPlayerSpells:GetVersionInfo(category)
		return format("LPS-%s-%d.%d.%d-%d", category, interface/10000, (interface/100)%100, interface%100, rev)
	end
end

addon.DescribeHighlight = DescribeHighlight
addon.DescribeFilter = DescribeFilter
addon.DescribeAllTokens = DescribeAllTokens
addon.DescribeAllSpells = DescribeAllSpells
addon.BuildDesc = BuildDesc
addon.DescribeLPSSource = DescribeLPSSource

------------------------------------------------------------------------------
-- Handler builders
------------------------------------------------------------------------------

local function BuildAuraHandler_Single(filter, highlight, token, buff, callLevel)
	return function(units, model)
		local unit = units[token]
		if not unit then return end
		for i = 1, math.huge do
			local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				if spellId == buff then
					model.highlight, model.count, model.expiration = highlight, count, expiration
					return true
				end
			else
				break
			end
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
	local key = BuildKey('Auras', filter, highlight, unit)
	local desc = BuildDesc(filter, highlight, token, '@NAME')
	for i, spell in ipairs(AsList(spells, "number", 2)) do
		tinsert(funcs, Configure(key, desc, spell, unit,  "UNIT_AURA",  BuildAuraHandler_Single(filter, highlight, unit, spell, 2), 2))
	end
	return (#funcs > 1) and funcs or funcs[1]
end

local function PassiveModifier(passive, spell, buff, unit, highlight)
	unit = unit or "player"
	highlight = highlight or "good"
	local handler = BuildAuraHandler_Single("HELPFUL PLAYER", highlight, unit, buff, 3)
	local key = BuildKey("PassiveModifier", passive, spell, buff, unit, highlight)
	local desc = BuildDesc("HELPFUL PLAYER", highlight, unit, buff)
	return Configure(key, desc, spell, unit, "UNIT_AURA", handler, passive, 3)
end

local function AuraAliases(filter, highlight, unit, spells, buffs)
	buffs = AsList(buffs or spells, "number", 3)
	local key = BuildKey("AuraAliases", filter, highlight, unit, spells, buffs)
	local desc = BuildDesc(filter, highlight, unit, buffs)
	return Configure(key, desc, spells, unit, "UNIT_AURA", BuildAuraHandler_FirstOf(filter, highlight, unit, buffs, 3), nil, 3)
end

local function ShowPower(spells, powerType, handler, highlight, desc)
	if type(powerType) ~= "string" then
		error("Invalid power type value, expected string, got "..type(powerType), 3)
	end
	local powerIndex = _G["SPELL_POWER_"..powerType]
	if not powerIndex then
		error("Unknown power "..powerType, 3)
	end
	local key = BuildKey("ShowPower", powerType, highlight)
	local powerLoc = _G[powerType]
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
			desc = format(L["Show %s and %s when %s."],
				powerLoc,
				highlightDescs[highlight],
				format(
					sign < 0 and L["it is below %s"] or L["it is above %s"],
					floor(100 * sign * handler)..'%'
				)
			)
		else
			-- Consider the handler as a an absolute value
			actualHandler = function(_, model)
				local current, maxPower = UnitPower("player", powerIndex)
				if UnitPowerMax("player", powerIndex) ~= 0 and sign * current >= handler then
					model.highlight = highlight
				end
			end
			desc = format(L["Show %s and %s when %s."],
				powerLoc,
				highlightDescs[highlight],
				format(
					sign < 0 and L["it is below %s"] or L["it is above %s"],
					sign * handler
				)
			)
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
		if highlight then
			desc = format(L["Show %s and %s when it reaches its maximum."], powerLoc, highlightDescs[highlight])
		else
			desc = format(L["Show %s."], powerLoc)
		end
	else
		error("Invalid handler type, expected function, number or nil, got "..type(handler), 3)
	end
	return Configure(key, desc, spells, "player", { "UNIT_POWER", "UNIT_POWER_MAX" }, actualHandler, nil, 3)
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
	local band = bit.band
	local UNIQUE_AURA = LibPlayerSpells.constants.UNIQUE_AURA
	local INVERT_AURA = LibPlayerSpells.constants.INVERT_AURA
	local TARGETING = LibPlayerSpells.masks.TARGETING
	local HARMFUL = LibPlayerSpells.constants.HARMFUL
	local PERSONAL = LibPlayerSpells.constants.PERSONAL
	local PET = LibPlayerSpells.constants.PET
	local IMPORTANT = LibPlayerSpells.constants.IMPORTANT

	function ImportPlayerSpells(filter, ...)
		local exceptions = AsSet({...}, "number", 3)
		local rules = {}
		for buff, flags, provider, modified, _, category in LibPlayerSpells:IterateSpells(filter, "AURA", "RAIDBUFF") do
			local providers = provider ~= buff and FilterOut(AsList(provider, "number"), exceptions)
			local spells = FilterOut(AsList(modified, "number"), exceptions)
			if not exceptions[buff] and #spells > 0 and (not providers or #providers > 0) then
				local filter, highlight, token = "HELPFUL", "good", "ally"
				local targeting = band(flags, TARGETING)
				if targeting == HARMFUL then
					filter, highlight, token = "HARMFUL", "bad", "enemy"
				elseif targeting == PERSONAL then
					token = "player"
				elseif targeting == PET then
					token = "pet"
				end
				if band(flags, INVERT_AURA) ~= 0 then
					filter = (filter == "HARMFUL") and "HELPFUL" or "HARMFUL"
				end
				if band(flags, UNIQUE_AURA) == 0 then
					filter = filter.." PLAYER"
				end
				if band(flags, IMPORTANT) ~= 0 then
					highlight = "flash"
				end
				local key = BuildKey('LibPlayerSpell', provider, modified, filter, highlight, token, buff)
				local desc = BuildDesc(filter, highlight, token, buff).." ["..DescribeLPSSource(category).."]"
				local handler = BuildAuraHandler_Longest(filter, highlight, token, buff, 3)
				tinsert(rules, Configure(key, desc, spells, token, "UNIT_AURA", handler, provider, 3))
			end
		end
		return (#rules > 1) and rules or rules[1]
	end
end

------------------------------------------------------------------------------
-- Environment setup
------------------------------------------------------------------------------

function addon.isClass(class)
	return class == select(2, UnitClass("player"))
	--@debug@
		or true
	--@end-debug@
end

-- Wrap an existing function to accept all its arguments in a table
local function WrapTableArgFunc(func)
	return function(args)
		return func(unpack(args))
	end
end

local allowedLibraries = {
	["LibDispellable-1.0"] = true,
	["LibPlayerSpells-1.0"] = true,
	["DRData-1.0"] = true,
	["LibSpellbook-1.0"] = true,
}

local rules_G = {
	-- Common functions
	L      = L,
	Debug  = Debug,
	GetLib = function(major)
		if not allowedLibraries[major] then
			error(format("Library '%s' is not allowed", major), 2)
		end
		return addon.GetLib(major)
	end,

	-- Constants
	PLAYER_CLASS = select(2, UnitClass("player")),

	-- Intended to be used un Lua
	AddRuleFor               = AddRuleFor,
	BuildAuraHandler_Single  = BuildAuraHandler_Single,
	BuildAuraHandler_Longest = BuildAuraHandler_Longest,
	BuildAuraHandler_FirstOf = BuildAuraHandler_FirstOf,

	-- Description helpers
	BuildDesc         = BuildDesc,
	BuildKey          = BuildKey,
	DescribeHighlight = DescribeHighlight,
	DescribeFilter    = DescribeFilter,
	DescribeAllTokens = DescribeAllTokens,
	DescribeAllSpells = DescribeAllSpells,
	DescribeLPSSource = DescribeLPSSource,

	-- Basic functions
	Configure = WrapTableArgFunc(Configure),
	ShowPower = WrapTableArgFunc(ShowPower),
	PassiveModifier = WrapTableArgFunc(PassiveModifier),
	ImportPlayerSpells = WrapTableArgFunc(ImportPlayerSpells),

	-- High-level functions
	SimpleDebuffs = function(spells)
		return Auras("HARMFUL PLAYER", "bad", "enemy", spells)
	end,

	SharedSimpleDebuffs = function(spells)
		return Auras("HARMFUL", "bad", "enemy", spells)
	end,

	SimpleBuffs = function(spells)
		return Auras("HELPFUL PLAYER", "good", "ally", spells)
	end,

	SharedSimpleBuffs = function(spells)
		return Auras("HELPFUL", "good", "ally", spells)
	end,

	LongestDebuffOf = function(spells, buffs)
		local key = BuildKey('LongestDebuffOf', spells, buffs)
		local desc =  BuildDesc("HARMFUL", "bad", "enemy", buffs)
		return Configure(key, desc, spells, "enemy", "UNIT_AURA", BuildAuraHandler_Longest("HARMFUL", "bad", "enemy", buffs or spells, 2), nil, 2)
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
}

for i, name in pairs{
	"bit", "ceil", "floor", "format", "GetComboPoints", "GetEclipseDirection", "GetNumGroupMembers",
	"GetShapeshiftFormID", "GetSpellBonusHealing", "GetSpellInfo", "GetTime", "GetTotemInfo", "ipairs",
	"math", "min", "pairs", "pairs", "select", "SPELL_POWER_MANA", "string", "table", "tinsert",
	"UnitAura", "UnitAura", "UnitBuff", "UnitBuff", "UnitCanAttack", "UnitCastingInfo",
	"UnitChannelInfo", "UnitClass", "UnitDebuff", "UnitDebuff", "UnitHealth", "UnitHealth",
	"UnitHealthMax", "UnitPower", "UnitPower", "UnitPowerMax", "UnitPowerMax", "UnitStagger",
	"STAGGER_YELLOW_TRANSITION", "UnitIsDeadOrGhost", "UnitIsPlayer"
} do
	rules_G[name] = _G[name]
end

-- Custom error message
setmetatable(rules_G, {
	__index = function(_, name)
		error(format("'%s' is forbidden in rule snippets.", name), 2)
	end
})

local RULES_ENV = setmetatable({}, {
	__metatable = false,
	__index = rules_G,
	__newindex = function(_, name)
		error(format("Changing global '%s' of role snipped is forbidden.", name), 2)
	end,
})

------------------------------------------------------------------------------
-- Rule loading and updating
------------------------------------------------------------------------------

local rules
local ruleBuilders = {}

function addon:BuildRules(event)
	if not rules then
		Debug('Building rules', event)
		if #ruleBuilders == 0 then
			error("No rules registered !", 2)
		end
		local t = {}
		for i, builder in ipairs(ruleBuilders) do
			local ok, funcs = xpcall(builder, errorhandler)
			if ok and funcs then
				tinsert(t, funcs)
			end
		end
		rules = AsList(t, "function")
		Debug(#rules, 'rules found')
	end
	return rules
end

local RULES_UPDATED = addonName..'_Rules_Updated'
addon.RULES_UPDATED = RULES_UPDATED

function addon:LibSpellbook_Spells_Changed(event)
	addon:Debug(event)
	wipe(spellConfs)
	wipe(ruleDescs)
	Do(self:BuildRules())
	self:SendMessage(RULES_UPDATED)
end

function addon.api:RegisterRules(builder)
	setfenv(builder, RULES_ENV)
	tinsert(ruleBuilders, builder)
	if rules then
		Debug('Rebuilding rules')
		rules = nil
		return addon:LibSpellbook_Spells_Changed('RegisterRules')
	end
end
