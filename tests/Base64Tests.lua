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

package.path = package.path .. ";.\\wowmock\\?.lua"
local LuaUnit = require('luaunit')
local mockagne = require('mockagne')
local wowmock = require('wowmock')

local when, verify = mockagne.when, mockagne.verify

local globals, addon

tests = {}

function tests:setup()
    addon = mockagne:getMock()
    globals = mockagne:getMock()
    wowmock("../core/Base64.lua", globals, "MyAddon", addon)
end

local function dataprovider(name, ...)
	local method = tests[name]
	tests[name] = nil
	for i = 1, select('#', ...) do
		local args = select(i, ...)
		tests[name.."_"..i] = function()
			return method(tests, unpack(args))
		end
	end
end

function tests:test_base64_encode(input, expected)
	assertEquals(addon.base64_encode(input), expected)
end

dataprovider('test_base64_encode',
	{ "AAA",      "QUFB" },
	{ "AA",       "QUE=" },
	{ "A",        "QQ==" },
	{ "FooBar !", "Rm9vQmFyICE=" }
)

function tests:test_base64_decode(expected, input)
	assertEquals(addon.base64_decode(input), expected)
end

dataprovider('test_base64_decode',
	{ "AAA",      "QUFB" },
	{ "AA",       "QUE=" },
	{ "A",        "QQ==" },
	{ "FooBar !", "Rm9vQmFyICE=" }
)

function tests:test_serialize(input, expected)
	assertEquals(addon.serialize(input), expected)
end

dataprovider('test_serialize',
	{ 0, "0" },
	{ true, "t" },
	{ false, "f" },
	{ {}, "e" },
	{ nil, "z" },
	{ 45, "n45:" },
	{ 1/3, "d6004799503160661:-54:" },
	{ "FooBar", "sFooBar:" },
	{ "Foo Bar !", "~Foo~`Bar~`!:" },
	{ "FooBar~", "~FooBar~0:", },
	{ "a:b", "~a~3b:" },
	{ { a = 5, "b" }, "T1sb:sa:5z" },
	{ { { b = 8 } }, "T1Tsb:8zz" }
)

function tests:test_serialize_error_function()
	assertEquals(pcall(addon.serialize, function() end), false)
end

function tests:test_serialize_error_coroutine()
	local function bla()
	end
	assertEquals(pcall(addon.serialize, coroutine.create(bla)), false)
end

function tests:test_serialize_references()
	local a = { 5 }
	local b = { 8, a }
	local c = {}
	a[2] = b
	a[3] = c
	a[4] = c
	assertEquals(addon.serialize(a), "T152T182r0z3e4r2z")
end

function tests:test_deserialize(expected, input)
	assertEquals(addon.deserialize(input), expected)
end

dataprovider('test_deserialize',
	{ 0, "0" },
	{ true, "t" },
	{ false, "f" },
	{ {}, "e" },
	{ nil, "z" },
	{ 45, "n45:" },
	{ 1/3, "d6004799503160661:-54:" },
	{ "FooBar", "sFooBar:" },
	{ "Foo Bar !", "~Foo~`Bar~`!:" },
	{ "FooBar~", "~FooBar~0:", },
	{ "a:b", "~a~3b:" },
	{ { a = 5, "b" }, "T1sb:sa:5z" },
	{ { { b = 8 } }, "T1Tsb:8zz" }
)

function tests:test_deserialize_error(input)
	assertEquals(pcall(addon.deserialize, input), false)
end

dataprovider('test_deserialize_error',
	{ "" },
	{ "zz" },
	{ "w" },
	{ 5 },
	{ "n48" },
	{ "s575997" },
	{ "s575:7898" },
	{ "T0102" },
	{ "~Foo~5ar:" },
	{ "~FooBar~:" }
)

function tests:test_deserialize_references()
	local a = addon.deserialize("T152T182r0z3e4r2z")
	assertEquals(a[1], 5)
	local b = a[2]
	assertEquals(b[1], 8)
	local c = a[3]
	assertEquals(b[2] == a, true)
	assertEquals(a[4] == c, true)
end

os.exit(LuaUnit:Run())