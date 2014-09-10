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

-- Working table
local t = {}

------------------------------------------------------------------------------
-- Base 64 encoding & decoding
------------------------------------------------------------------------------

local band, lshift, rshift = bit.band, bit.lshift, bit.rshift

-- Convert base 64 value to ASCII & conversely
local encode, decode = {}, {}
for value = 0, 63 do
	local char = strsub('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/', value+1, value+1)
	encode[value] = char
	decode[strbyte(char)] = value
end

function addon.base64_encode(str)
	local j = 1
	for i = 1, strlen(str), 3 do
		local a, b, c = strbyte(str, i, i+2)
		t[j] = encode[rshift(a, 2)]
		t[j+1] = encode[band(lshift(a, 4) + rshift(b or 0, 4), 0x3F)]
		t[j+2] = b and encode[band(lshift(b, 2) + rshift(c or 0, 6), 0x3F)] or "="
		t[j+3] = c and encode[band(c, 0x3F)] or "="
		j = j + 4
	end
	return table.concat(t, "", 1, j-1)
end

function addon.base64_decode(str)
	local j = 1
	for i = 1, strlen(str), 4 do
		local a, b, c, d = strbyte(str, i, i+3)
		a, b, c, d = decode[a], decode[b], decode[c], decode[d]
		t[j] = strchar(lshift(a, 2) + rshift(b, 4))
		t[j+1] = c and strchar(band(lshift(b, 4) + rshift(c, 2), 0xFF)) or ""
		t[j+2] = d and strchar(band(lshift(c, 6) + d, 0xFF)) or ""
		j = j + 3
	end
	return table.concat(t, "", 1, j-1)
end

------------------------------------------------------------------------------
-- Serialization
------------------------------------------------------------------------------

--[=[
Serialization format: one-letter code, followed by additional data when needed.

Codes:
	z: nil
	t: true
	f: false
	0..9: integers 0..9
	n: tostring-safe number, value follows, terminated by ':'
	d: floating-point number, integer mantissa and exponent follow, terminated each by ':'
	S: empty string
	s: string, terminated by ':'
	~: escaped string, terminated by ':'
	e: empty table
	T: table, serialized (key, value) pairs follow, terminated by a nil value ("z")

Escaped string: non-printable characters, space, tilde, colon and pipe are encoded, using the tilde as a escape character.
--]=]

-- String escaping table
local escape = {
	['~'] = '~0',
	["\127"] = '~1',
	['|'] = '~2',
	[':'] = '~3'
}
for ascii = 0, 32 do
	escape[strchar(ascii)] = '~'..strchar(64+ascii)
end

-- Values serialized using one character
local serializeConstants = {
	[false] = "f",
	[true] = "t",
	[""] = "S"
}
for integer = 0, 9 do
	serializeConstants[integer] = tostring(integer)
end

-- Required for table recursion
local _serialize

local serializerByType = {
	["number"] = function(position, num)
		local str = tostring(num)
		if tonumber(str) == num then
			t[position] = format("%s:", str)
			return "n", position + 1
		end
		local m, e = frexp(num)
		t[position] = format("%.0f:%d:", m*2^53, e-53)
		return "d", position + 1
	end,
	["string"] = function(position, str)
		local safeStr, numSubs = gsub(str, "[%c :|~\127]", escape)
		t[position] = safeStr .. ':'
		return numSubs > 0 and "~" or "s", position + 1
	end,
	["table"] = function(position, table_)
		if not next(table_) then
			return "e", position
		end
		for key, value in pairs(table_) do
			position = _serialize(
				_serialize(position, key),
				value
			)
		end
		t[position] = "z"
		return "T", position + 1
	end,
	["nil"] = function(position)
		return "z", position
	end,
}

-- Serialize a value into t, increase position
function _serialize(position, value)
	local constant = serializeConstants[value]
	if constant then
		t[position] = constant
		return position + 1
	end
	local type_ = type(value)
	local serializer = serializerByType[type_]
	assert(serializer, format("serialize: unsupported type: %s", type_))
	t[position], position = serializer(position+1, value)
	return position
end

-- Initialize position, serialize the value and return the concatenated result
function addon.serialize(value)
	local length = _serialize(1, value)
	return tconcat(t, "", 1, length-1)
end

------------------------------------------------------------------------------
-- Deserialization
------------------------------------------------------------------------------

-- Short constants unserializing
local deserializeConstants = {}
for value, serialized in pairs(serializeConstants) do
	deserializeConstants[serialized] = value
end

-- String unescaping
local unescape = {}
for raw, escaped in pairs(escape) do
	unescape[escaped] = raw
end

-- Required for table recursion
local _deserialize, deserializerByCode

deserializerByCode = {
	z = function(data, position)
		return nil, position
	end,
	e = function(data, position)
		return {}, position
	end,
	s = function(data, position, what)
		assert(position < strlen(data), "deserialize: unterminated serialized data")
		local colonPosition = strfind(data, ':', position, true)
		assert(colonPosition, format("deserialize: unterminated %s starting at position %d", what or "string", position))
		return strsub(data, position, colonPosition-1), colonPosition + 1
	end,
	['~'] = function(data, position)
		local str
		str, position = deserializerByCode.s(data, position)
		return gsub(str, '~.', unescape), position
	end,
	n = function(data, position, what)
		local str
		str, position = deserializerByCode.s(data, position, what or "number")
		local value = tonumber(str)
		assert(value, format("deserialize: invalid %s starting at position %d", what or "number", position))
		return value, position
	end,
	d = function(data, position)
		local m, e
		m, position = deserializerByCode.n(data, position, "mantissa")
		e, position = deserializerByCode.n(data, position, "exponent")
		return m*(2^e), position
	end,
	T = function(data, position)
		local t, key = {}
		key, position = _deserialize(data, position)
		while key ~= nil do
			t[key], position = _deserialize(data, position)
			key, position = _deserialize(data, position)
		end
		return t, position
	end,
}

function _deserialize(data, position)
	assert(position <= strlen(data), "deserialize: unterminated serialized data")
	local code = strsub(data, position, position)
	local constant = deserializeConstants[code]
	if constant ~= nil then
		return constant, position + 1
	end
	local deserializer = deserializerByCode[code]
	assert(deserializer, format("deserialize: invalid code at position %d: '%s'", position, code))
	return deserializer(data, position + 1)
end

function addon.deserialize(str)
	assert(type(str) == "string", format("deserialize: attempt to deserialize a %s", type(str)))
	assert(str ~= "", "deserialize: attempt to deserialize an empty string")
	local value, position = _deserialize(str, 1)
	assert(position == 1+strlen(str), format("deserialize: garbage at position %d", position))
	return value
end
