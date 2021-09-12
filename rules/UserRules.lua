--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2021 Adirelle (adirelle@gmail.com)
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
local geterrorhandler = _G.geterrorhandler
local getprinthandler = _G.getprinthandler
local loadstring = _G.loadstring
local pairs = _G.pairs
local pcall = _G.pcall
local setmetatable = _G.setmetatable
local setprinthandler = _G.setprinthandler
local tinsert = _G.tinsert
local tostring = _G.tostring
local type = _G.type
local xpcall = _G.xpcall

local Restricted = addon.Restricted
local isClass = addon.isClass

local function Debug(...) return addon.Debug('User rules', ...) end

local compiledSnippets = {}

local function CompileCodeSnippet(code)
	local funcOrError = compiledSnippets[code]
	if type(funcOrError) == "function" then
		return funcOrError
	elseif funcOrError then
		return nil, funcOrError
	end
	local func, errorMessage = loadstring(code)
	compiledSnippets[code] = func and Restricted(func) or errorMessage
	return compiledSnippets[code], errorMessage, true
end

local function CompileUserRule(rule)
	if not rule.enabled or not isClass(rule.scope) then
		return
	end

	local snippet, errorMessage, new = CompileCodeSnippet(rule.code)
	if not snippet then
		return nil, errorMessage, new
	end

	local success, rulesOrMessage = pcall(snippet)
	if success then
		return rulesOrMessage
	end
	return nil, rulesOrMessage, new
end

local previous, builders = {}, {}

function addon:CompileUserRules()
	local changed = false
	Debug('Compiling user rules')

	local rules = addon.db.global.userRules

	for key in pairs(previous) do
		if not rules[key] then
			previous[key] = nil
			changed = true
		end
	end

	local count = 0
	for key, rule in pairs(rules) do
		local builder, errorMessage, new = CompileUserRule(rule)
		rule.error = errorMessage
		if errorMessage and new then
			geterrorhandler()(format('[%s "%s"]: %s', addonName, rule.title, errorMessage))
		end
		if previous[key] ~= builder then
			Debug('Rule', rule.title, 'changed to', builder)
			previous[key] = builder
			changed = true
		end
		if builder then
			count = count + 1
			builders[count] = builder
		end
	end

	for i = count+1, #builders do
		builders[i] = nil
	end

	Debug('Compilation changed:', changed)
	return changed
end

AdiButtonAuras:RegisterRules(function()
	Debug('Calling user rules initializer')
	addon:CompileUserRules()
	return builders
end)
