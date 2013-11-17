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

local LibItemBuffs = LibStub('LibItemBuffs-1.0')

local items = {}
addon.items = items

local function BuildItemRule(itemId, ...)
	local numBuffs = select('#', ...)
	local _, link = GetItemInfo(itemId)
	addon:Debug('Buffs for', link, '=>', ...)
	if numBuffs == 0 or not ... then return false end
	local buffs = {}
	for i = 1, numBuffs do
		local spellId = select(i, ...)
		buffs[spellId] = true
	end
	local token, filter, highlight
	if IsHarmfulItem(itemId) then
		token, filter, highlight = "enemy", "PLAYER HARMFUL", "bad"
	else
		filter, highlight = "PLAYER HELPFUL", "good"
		token = IsHelpfulItem(itemId) and "ally" or "player"
	end
	return {
		units = { [token] = true },
		events = { UNIT_AURA = true },
		handlers = {
			function(units, model)
				local unit = units[token]
				if not unit then return end
				for i = 1, math.huge do
					local name, _, _, count, _, _, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
					if name then
						if buffs[spellId] then
							model.highlight, model.expiration = highlight, expiration
							return true
						end
					else
						break
					end
				end
			end
		}
	}
end

setmetatable(items, { __index = function(t, itemId)
	local rule = itemId and BuildItemRule(itemId, LibItemBuffs:GetItemBuffs(itemId))
	t[itemId] = rule
	return rule
end})
