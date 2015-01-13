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
local bit = _G.bit
local error = _G.error
local floor = _G.floor
local format = _G.format
local GetItemInfo = _G.GetItemInfo
local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink
local gsub = _G.gsub
local ipairs = _G.ipairs
local math = _G.math
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local setfenv = _G.setfenv
local strjoin = _G.strjoin
local strmatch = _G.strmatch
local tinsert = _G.tinsert
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type
local UnitClass = _G.UnitClass
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local unpack = _G.unpack
local wipe = _G.wipe
local xpcall = _G.xpcall
local geterrorhandler = _G.geterrorhandler

local getkeys      = addon.getkeys
local ucfirst      = addon.ucfirst
local Do           = addon.Do
local ConcatLists  = addon.ConcatLists
local FlattenList  = addon.FlattenList
local AsList       = addon.AsList
local AsSet        = addon.AsSet
local MergeSets    = addon.MergeSets
local BuildKey     = addon.BuildKey

local DescribeHighlight = addon.DescribeHighlight
local DescribeFilter    = addon.DescribeFilter
local DescribeAllTokens = addon.DescribeAllTokens
local DescribeAllSpells = addon.DescribeAllSpells
local BuildDesc         = addon.BuildDesc
local DescribeLPSSource = addon.DescribeLPSSource

local L = addon.L

local LibPlayerSpells = addon.GetLib('LibPlayerSpells-1.0')
local LibSpellbook = addon.GetLib('LibSpellbook-1.0')

local PLAYER_CLASS = select(2, UnitClass("player"))

-- Local debug with dedicated prefix
local function Debug(...) return addon.Debug('|cffffff00Rules:|r', ...) end

local rules = addon.rules
local descriptions = addon.descriptions

------------------------------------------------------------------------------
-- Rule creation
------------------------------------------------------------------------------

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
		descriptions[key] = ucfirst(desc)
	end
	Debug("Adding rule for", info,
		"key:", key,
		"desc:", desc,
		"units:", strjoin(",", getkeys(units)),
		"events:", strjoin(",", getkeys(events)),
		"handlers:", handlers,
		"providers:", providers and strjoin(",", unpack(providers)) or "-"
	)
	local rule = rules[id]
	if not rule then
		rule = { name = name, units = {}, events = {}, handlers = {}, keys = {} }
		rules[id] = rule
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
	local builders = {}
	for i, spell in ipairs(spells) do
		local spell = spell
		tinsert(builders, function()
			_AddRuleFor(key, desc, spell, units, events, handlers, providers, callLevel+1)
		end)
	end
	return #builders == 1 and builders[1] or builders
end

------------------------------------------------------------------------------
-- Handler builders
------------------------------------------------------------------------------

local function BuildAuraHandler_Single(filter, highlight, token, buff, callLevel)
	local GetAura = addon.GetAuraGetter(filter)
	return function(units, model)
		local found, count, expiration = GetAura(units[token], buff)
		if found then
			model.highlight, model.count, model.expiration = highlight, count, expiration
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
	local IterateAuras = addon.GetAuraIterator(filter)
	return function(units, model)
		local longest = -1
		for i, id, count, expiration in IterateAuras(units[token]) do
			if buffs[id] and expiration > longest then
				longest = expiration
				if highlight == "flash" or model.highlight ~= "flash" then
					model.highlight = highlight
				end
				model.count, model.expiration = count, expiration
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
	local IterateAuras = addon.GetAuraIterator(filter)
	return function(units, model)
		for i, id, count, expiration in IterateAuras(units[token]) do
			if buffs[id] then
				if highlight == "flash" or model.highlight ~= "flash" then
					model.highlight = highlight
				end
				model.count, model.expiration = count, expiration
				return true
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
	local desc = BuildDesc(filter, highlight, unit, '@NAME')
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
				addon.DescribeHighlight(highlight),
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
				addon.DescribeHighlight(highlight),
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
			desc = format(L["Show %s and %s when it reaches its maximum."], powerLoc, addon.DescribeHighlight(highlight))
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
		local builders = {}
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
				tinsert(builders, Configure(key, desc, spells, token, "UNIT_AURA", handler, provider, 3))
			end
		end
		return (#builders > 1) and builders or builders[1]
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

-- Base "globals"
local baseEnv = {
	-- Common functions and constatns
	L            = addon.L,
	Debug        = Debug,
	PLAYER_CLASS = PLAYER_CLASS,

	-- Intended to be used un Lua
	AddRuleFor               = AddRuleFor,
	BuildAuraHandler_Single  = BuildAuraHandler_Single,
	BuildAuraHandler_Longest = BuildAuraHandler_Longest,
	BuildAuraHandler_FirstOf = BuildAuraHandler_FirstOf,

	-- Description helpers
	BuildDesc         = addon.BuildDesc,
	BuildKey          = addon.BuildKey,
	DescribeHighlight = addon.DescribeHighlight,
	DescribeFilter    = addon.DescribeFilter,
	DescribeAllTokens = addon.DescribeAllTokens,
	DescribeAllSpells = addon.DescribeAllSpells,
	DescribeLPSSource = addon.DescribeLPSSource,

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
for name, func in pairs(addon.AuraTools) do
	baseEnv[name] = func
end

local RULES_ENV = addon.BuildSafeEnv(
	baseEnv,
	-- Allowed Libraries
	{
		"LibDispellable-1.0", "LibPlayerSpells-1.0", "DRData-1.0", "LibSpellbook-1.0", "LibItemBuffs-1.0"
	},
	-- Allowed globals
	{
		"bit", "ceil", "floor", "format", "GetComboPoints", "GetEclipseDirection", "GetNumGroupMembers",
		"GetShapeshiftFormID", "GetSpellBonusHealing", "GetSpellInfo", "GetTime", "GetTotemInfo",
		"HasPetSpells", "ipairs", "math", "min", "pairs", "select", "string", "table", "tinsert",
		"UnitIsPlayer", "UnitCanAttack", "UnitCastingInfo", "UnitChannelInfo", "UnitClass","UnitHealth",
		"print", "UnitHealthMax", "UnitPower", "UnitPowerMax", "UnitStagger", "UnitIsDeadOrGhost",
		"IsPlayerSpell", "GetSpellCharges"
	}
)

function addon.Restricted(func)
	return setfenv(func, RULES_ENV)
end
