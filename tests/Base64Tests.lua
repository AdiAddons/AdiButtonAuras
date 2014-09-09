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

os.exit(LuaUnit:Run())