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

local _, private = ...

local SAMPLE_RULE = [===[
-- Sample rule using Configure
-- See https://github.com/AdiAddons/AdiButtonAuras/blob/master/doc/RulesRef.md#user-rules for more details.
-- This rule is only meant as an example and is already included in AdiButtonAuras. Please do not activate it as is.

return Configure {

    -- Unique Id
    "Execute",

    -- Description
    "Hint when the targeted enemy is below 20% health.",

    -- Spells to modify
    {
          5308, -- Execute (Fury)
        163201, -- Execute (Arms)
    },

    -- Unit(s) to watch
    "enemy",

    -- Event(s) to watch
    { "UNIT_HEALTH", "UNIT_MAXHEALTH" },

    -- Callback
    function(units, model)
        if UnitHealth(units.enemy) / UnitHealthMax(units.enemy) < 0.20 then
            model.hint = true
        end
    end

}
]===]

local _G = _G

function private.GetUserRulesOptions(addon, addonName)

	local date = _G.date
	local format = _G.format
	local GetBuildInfo = _G.GetBuildInfo
	local GetRealmName = _G.GetRealmName
	local GetUnitName = _G.GetUnitName
	local next = _G.next
	local pairs = _G.pairs
	local time = _G.time
	local wipe = _G.wipe
	local GetAddOnMetadata = _G.GetAddOnMetadata
	local tostring = _G.tostring
	local type = _G.type
	local unpack = _G.unpack

	local L = addon.L

	local ADDON_VERSION = tostring(GetAddOnMetadata(addonName, "Version"))
	local PLAYER_NAME = GetUnitName("player", false).. '-'..GetRealmName()
	local PATCH_NUMBER = GetBuildInfo()
	--@debug@
	ADDON_VERSION = 'dev'
	--@end-debug@

	local handler = {
		current = next(addon.db.global.userRules)
	}

	function handler:Select(key)
		self.current = key
	end

	function handler:GetSelected()
		return self.current
	end

	function handler:HasNotSelection()
		return self.current == nil
	end

	function handler:Create()
		local key = #addon.db.global.userRules + 1
		local rule = addon.db.global.userRules[key]
		rule.title = format(L['User rule #%d'], key)
		rule.code = SAMPLE_RULE
		rule.revision = 0
		rule.created = self:GetHistoryPoint()
		self:Select(key)
	end

	function handler:Delete()
		addon.db.global.userRules[self.current] = nil
		self:Select(next(addon.db.global.userRules))
	end

	function handler:Rule()
		return addon.db.global.userRules[self.current]
	end

	function handler:Get(property)
		local rule = self:Rule()
		if not rule then return end
		return rule[property]
	end

	function handler:Set(property, value)
		local rule = self:Rule()
		if not rule or rule[property] == value then return end
		if property ~= "enabled" then
			rule.revision = rule.revision + 1
			rule.updated = self:GetHistoryPoint()
		end
		rule[property] = value
		if addon:CompileUserRules() then
			return addon:LibSpellbook_Spells_Changed('UserRuleChanged')
		end
	end

	function handler:GetHistoryPoint()
		return { PLAYER_NAME, time(), PATCH_NUMBER, ADDON_VERSION }
	end

	function handler:FormatHistoryPoint(property)
		local point = self:Get(property)
		if type(point) ~= "table" then return "???" end
		local name, timestamp, patch, addonVersion = unpack(point)
		return format(L["%s, %s, patch %s, v.%s"], name, date("%Y-%m-%d %H:%M", timestamp), patch, addonVersion)
	end

	local t = {}
	function handler:GetRuleList()
		wipe(t)
		for key, rule in pairs(addon.db.global.userRules) do
			local title = rule.title
			if rule.error then
				title = title..' |cffff0000('..L['error']..')|r'
			elseif not rule.enabled then
				title = title..' |cff7f7f7f('..L['disabled']..')|r'
			elseif not addon.isClass(rule.scope) then
				title = title..' |cff7f7f7f('..L['inactive']..')|r'
			end
			t[key] = title
		end
		return t
	end

	function handler:HasNoRules()
		return not next(addon.db.global.userRules)
	end

	return {
		name = L['User Rules'],
		desc = L['Allow to add user-defined rules using Lua snippets.'],
		type = 'group',
		order = 30,
		handler = handler,
		args = {
			selectedRule = {
				name = L['Selected rule'],
				type = 'select',
				order = 10,
				get = 'GetSelected',
				set = function(_, key) return handler:Select(key) end,
				values = 'GetRuleList',
				hidden = 'HasNoRules',
			},
			newRule = {
				name = L['New rule'],
				type = 'execute',
				order = 20,
				func = 'Create',
			},
			rule = {
				name = L['Edit rule'],
				type = 'group',
				inline = true,
				order = 30,
				hidden = 'HasNotSelection',
				get = function(info) return handler:Get(info[#info]) end,
				set = function(info, ...) return handler:Set(info[#info], ...) end,
				args = {
					title = {
						name = L['Title'],
						desc = L['The rule title, to be used in spell panel.'],
						type = 'input',
						width = 'full',
						order = 10,
					},
					created = {
						name = function()
							return format(L["Created by %s"], handler:FormatHistoryPoint('created'))
						end,
						type = 'description',
						order = 11,
						fontSize = 'medium',
						hidden = function() return type(handler:Get('created')) ~= 'table' end,
					},
					updated = {
						name = function()
							return format(
								L["Updated by %s, revision #%d"],
								handler:FormatHistoryPoint('updated'),
								handler:Get('revision')
							)
						end,
						type = 'description',
						order = 12,
						fontSize = 'medium',
						hidden = function() return type(handler:Get('updated')) ~= 'table' end,
					},
					enabled = {
						name = L['Enabled'],
						desc = L['Uncheck to disable this rule globally.'],
						type = 'toggle',
						order = 20,
					},
					scope = {
						name = L['Class restriction'],
						desc = L['For which class should this rule be active ?'],
						type = 'select',
						order = 25,
						values = {
							ALL = L['None'],
							DEATHKNIGHT = L['DEATHKNIGHT'],
							DEMONHUNTER = L['DEMONHUNTER'],
							DRUID = L['DRUID'],
							HUNTER = L['HUNTER'],
							MAGE = L['MAGE'],
							MONK = L['MONK'],
							PALADIN = L['PALADIN'],
							PRIEST = L['PRIEST'],
							ROGUE = L['ROGUE'],
							SHAMAN = L['SHAMAN'],
							WARLOCK = L['WARLOCK'],
							WARRIOR = L['WARRIOR'],
						},
					},
					delete = {
						name = L['Delete'],
						type = 'execute',
						confirm = true,
						confirmText = L['Permanently delete this rule ?'],
						order = 26,
						func = 'Delete',
					},
					_validation = {
						name = function()
							local msg = handler:Get('error')
							return msg and ('|cffff0000Error '..msg:gsub('^[^:]+:(%d+:)', 'line %1')..'|r') or 'OK'
						end,
						type = 'description',
						hidden = function()
							return not handler:Get('error')
						end,
						width = 'full',
						order = 29,
						fontSize = 'large',
					},
					code = {
						name = L['Code'],
						desc = L['The code snippet defining the rule.'],
						type = 'input',
						width = 'full',
						multiline = 15,
						order = 30,
					},
				},
			},
		},
	}

end
