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
local geterrorhandler = _G.geterrorhandler
local loadstring = _G.loadstring
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local tinsert = _G.tinsert
local tostring = _G.tostring
local xpcall = _G.xpcall
local getprinthandler = _G.getprinthandler
local pcall = _G.pcall
local setprinthandler = _G.setprinthandler

local Restricted = addon.Restricted
local isClass = addon.isClass

local function Debug(...) return addon.Debug('User rules', ...) end

local compiledSnippets = setmetatable({}, { __mode = 'v' })

local function CompileUserRule(code, title)
	if not compiledSnippets[code] then
		local func, err = loadstring(code, title)
		if not func then
			return nil, err
		end
		compiledSnippets[code] = Restricted(func)
	end
	return compiledSnippets[code]
end

local initialLoading = true
local function BuildUserRules()
	Debug('Compiling rules')
	local rules = {}
	local ph = getprinthandler()
	for key, rule in pairs(addon.db.global.userRules) do
		local err = nil
		if rule.enabled and isClass(rule.scope) then
			local builder, msg = CompileUserRule(rule.code)
			if builder then
				setprinthandler(function(...) ph(format('[%s "%s"]:', addonName, rule.title), ...) end)
				local ok, result = pcall(builder)
				setprinthandler(ph)
				if ok and result then
					tinsert(rules, result)
				else
					err = result
				end
			else
				err = msg
			end
		end
		rule.error = err
		if err and initialLoading then
			geterrorhandler()(format(addon.L["%s: error in user-defined rule: %s"], addonName, err))
		end
	end
	initialLoading = false
	for _, builder in ipairs(rules) do
		xpcall(builder)
	end
end

AdiButtonAuras:RegisterRules(function() return BuildUserRules end)

-- GLOBALS: AddRuleFor BuffAliases BuildAuraHandler_FirstOf BuildAuraHandler_Longest
-- GLOBALS: BuildAuraHandler_Single BuildDesc BuildKey Configure DebuffAliases Debug
-- GLOBALS: DescribeAllSpells DescribeAllTokens DescribeFilter DescribeHighlight
-- GLOBALS: DescribeLPSSource GetComboPoints GetEclipseDirection GetNumGroupMembers
-- GLOBALS: GetShapeshiftFormID GetSpellBonusHealing GetSpellInfo GetTime
-- GLOBALS: GetTotemInfo HasPetSpells ImportPlayerSpells L LongestDebuffOf
-- GLOBALS: PLAYER_CLASS PassiveModifier PetBuffs SelfBuffAliases SelfBuffs
-- GLOBALS: SharedSimpleBuffs SharedSimpleDebuffs ShowPower SimpleBuffs
-- GLOBALS: SimpleDebuffs UnitCanAttack UnitCastingInfo UnitChannelInfo UnitClass
-- GLOBALS: UnitHealth UnitHealthMax UnitIsDeadOrGhost UnitIsPlayer UnitPower
-- GLOBALS: UnitPowerMax UnitStagger bit ceil floor format ipairs math min pairs
-- GLOBALS: print select string table tinsert GetPlayerBuff
