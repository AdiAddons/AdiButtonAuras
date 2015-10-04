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

package.path = package.path .. ";./wowmock/?.lua"
local LuaUnit = require('luaunit')
local mockagne = require('mockagne')
local wowmock = require('wowmock')

local when, any, verify = mockagne.when, mockagne.any, mockagne.verify

local G, addon, LibItemBuffs

testItems = {}

function testItems:setup()
	G = mockagne:getMock()
	addon = mockagne:getMock()
	addon.Memoize = function(f) return setmetatable({}, { __index = function(_, k) return f(k) end }) end
	addon.rules = {}
	addon.descriptions = {}
	LibItemBuffs = mockagne:getMock()
	when(addon.GetLib('LibItemBuffs-1.0')).thenAnswer(LibItemBuffs, 1)
end

function testItems:load()
	wowmock('../core/Items.lua', G, 'AdiButtonAuras', addon)
end

function testItems:testSpell()
	self:load()
	local rule = addon.rules["spell:456"]
	assertEquals(rule, false)
end

function testItems:testUnknownItem()
	when(G.GetItemSpell(456)).thenAnswer(nil)
	when(LibItemBuffs:GetItemBuffs(456)).thenAnswer()
	self:load()
	local rule = addon.rules["item:456"]
	verify(G.GetItemSpell(456))
	verify(LibItemBuffs:GetItemBuffs(456))
	assertEquals(rule, false)
end

for i, data in pairs {
	{ false, true, "ally", "HELPFUL PLAYER", "good" },
	{ false, false, "player", "HELPFUL PLAYER", "good" },
	{ true, false, "enemy", "HARMFUL PLAYER", "bad" },
} do
	local harmful, helpful, token, filter, highlight = unpack(data)
	testItems['testGetItemSpell'..i] = function(self)

		when(G.GetItemSpell(456)).thenAnswer("LeBuff")
		when(G.GetItemInfo(456)).thenAnswer("LeItem", nil, nil, nil, nil, "Miscallaneous")

		when(G.IsHarmfulItem(456)).thenAnswer(harmful)
		when(G.IsHelpfulItem(456)).thenAnswer(helpful)

		when(addon.BuildKey('item', 456, token, filter, highlight, 'LeBuff')).thenAnswer("LeKey")
		when(addon.BuildDesc(filter, highlight, token, 'LeBuff')).thenAnswer("LeDesc")

		self:load()

		local rule = addon.rules["item:456"]

		verify(G.GetItemSpell(456))
		verify(G.IsHarmfulItem(456))
		verify(G.GetItemInfo(456))
		verify(addon.BuildKey('item', 456, token, filter, highlight, 'LeBuff'))
		verify(addon.BuildDesc(filter, highlight, token, 'LeBuff'))

		assertEquals(next(rule.units), token)
		assertEquals(rule.name, "LeItem")
		assertEquals(rule.keys[1], "LeKey")
		assertEquals(addon.descriptions["LeKey"], "LeDesc")
	end
end

for i, data in pairs {
	{ false, true, "ally", "HELPFUL PLAYER", "good" },
	{ false, false, "player", "HELPFUL PLAYER", "good" },
	{ true, false, "enemy", "HARMFUL PLAYER", "bad" },
} do
	local harmful, helpful, token, filter, highlight = unpack(data)
	testItems['testLibItemBuffs'..i] = function(self)

		when(LibItemBuffs:GetDatabaseVersion()).thenAnswer(8)

		when(G.GetItemSpell(456)).thenAnswer(nil)
		when(LibItemBuffs:GetItemBuffs(456)).thenAnswer(500)
		when(G.GetItemInfo(456)).thenAnswer("LeItem")

		when(G.IsHarmfulItem(456)).thenAnswer(harmful)
		when(G.IsHelpfulItem(456)).thenAnswer(helpful)

		when(addon.BuildKey('item', 456, token, filter, highlight, 500)).thenAnswer("LeKey")
		when(addon.BuildDesc(filter, highlight, token, 500)).thenAnswer("LeDesc")

		self:load()

		LibItemBuffs.__databaseVersion = 8
		local rule = addon.rules["item:456"]

		verify(G.GetItemSpell(456))
		verify(LibItemBuffs:GetItemBuffs(456))
		verify(G.IsHarmfulItem(456))
		verify(G.GetItemInfo(456))
		verify(addon.BuildKey('item', 456, token, filter, highlight, 500))
		verify(addon.BuildDesc(filter, highlight, token, 500))

		assertEquals(next(rule.units), token)
		assertEquals(rule.name, "LeItem")
		assertEquals(rule.keys[1], "LeKey")
		assertEquals(addon.descriptions["LeKey"], "LeDesc [LIB-1-8]")
	end
end

os.exit(LuaUnit:Run())
