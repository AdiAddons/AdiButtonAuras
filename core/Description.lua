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
local format = _G.format
local GetSpellInfo = _G.GetSpellInfo
local gsub = _G.gsub
local tostring = _G.tostring
local type = _G.type
local unpack = _G.unpack

local L            = addon.L
local getkeys      = addon.getkeys
local ucfirst      = addon.ucfirst

local LibPlayerSpells = addon.GetLib('LibPlayerSpells-1.0')

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
	stacks  = L['show the number of stacks'],
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
	return ucfirst(gsub(format(
		L["%s when %s %s is found on %s."],
		DescribeHighlight(highlight),
		DescribeFilter(filter),
		spells or "",
		tokens or "?"
	), "%s+", " "))
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
