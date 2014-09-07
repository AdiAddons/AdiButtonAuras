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

local _, private = ...

function private.GetUserRulesOptions(addon, addonName)

	local _G = _G
	local date = _G.date
	local format = _G.format
	local GetBuildInfo = _G.GetBuildInfo
	local GetRealmName = _G.GetRealmName
	local GetUnitName = _G.GetUnitName
	local next = _G.next
	local pairs = _G.pairs
	local time = _G.time
	local wipe = _G.wipe

	local L = addon.L

	local ADDON_VERSION = tostring(GetAddOnMetadata(addonName, "Version"))
	local PLAYER_NAME = GetUnitName("player", false).. '-'..GetRealmName()
	local PATCH_NUMBER = GetBuildInfo()
	--@debug@
	ADDON_VERSION = 'dev'
	--@end-debug@

	local userRuleHandler = {
		current = next(addon.db.global.userRules),
		select = function(self, key)
			self.current = key
		end,
		create = function(self)
			local key = #addon.db.global.userRules + 1
			local rule = addon.db.global.userRules[key]
			rule.title = format(L['User rule #%d'], key)
			rule.code = ""
			rule.revision = 0
			rule.created = self:GetHistoryPoint()
			self:select(key)
		end,
		delete = function(self)
			addon.db.global.userRules[self.current] = nil
			self:select(nil)
		end,
		rule = function(self)
			return addon.db.global.userRules[self.current]
		end,
		get = function(self, property)
			local rule = self:rule()
			if not rule then return end
			return rule[property]
		end,
		set = function(self, property, value)
			local rule = self:rule()
			if not rule or rule[property] == value then return end
			if property ~= "enabled" then
				rule.revision = rule.revision + 1
				rule.updated = self:GetHistoryPoint()
			end
			rule[property] = value
			return addon:LibSpellbook_Spells_Changed('UserRuleChanged')
		end,
		_get = function(self, info)
			return self:get(info[#info])
		end,
		_set = function(self, info, ...)
			return self:set(info[#info], ...)
		end,
		GetHistoryPoint = function()
			return { PLAYER_NAME, time(), PATCH_NUMBER, ADDON_VERSION }
		end,
		FormatHistoryPoint = function(self, property)
			local point = self:get(property)
			if type(point) ~= "table" then return "???" end
			local name, timestamp, patch, addonVersion = unpack(point)
			return format(L["%s, %s, patch %s, v.%s"], name, date("%Y-%m-%d %H:%M", timestamp), patch, addonVersion)
		end,
	}

	local tmpRuleList = {}

	return {
		name = L['User Rules'],
		desc = L['Allow to add user-defined rules using Lua snippets.'],
		type = 'group',
		order = 30,
		args = {
			selectedRule = {
				name = L['Selected rule'],
				type = 'select',
				order = 10,
				get = function() return userRuleHandler.current end,
				set = function(_, key) return userRuleHandler:select(key) end,
				values = function()
					wipe(tmpRuleList)
					for key, rule in pairs(addon.db.global.userRules) do
						local title = rule.title
						if rule.error then
							title = title..' |cffff0000('..L['error']..')|r'
						elseif not rule.enabled then
							title = title..' |cff7f7f7f('..L['disabled']..')|r'
						end
						tmpRuleList[key] = title
					end
					return tmpRuleList
				end,
			},
			newRule = {
				name = L['New rule'],
				type = 'execute',
				order = 20,
				func = function() return userRuleHandler:create() end,
			},
			rule = {
				name = L['Edit rule'],
				type = 'group',
				inline = true,
				order = 30,
				hidden = function() return not userRuleHandler.current end,
				handler = userRuleHandler,
				get = '_get',
				set = '_set',
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
							return format(L["Created by %s"], userRuleHandler:FormatHistoryPoint('created'))
						end,
						type = 'description',
						order = 11,
						fontSize = 'medium',
						hidden = function() return type(userRuleHandler:get('created')) ~= 'table' end,
					},
					updated = {
						name = function()
							return format(
								L["Updated by %s, revision #%d"],
								userRuleHandler:FormatHistoryPoint('updated'),
								userRuleHandler:get('revision')
							)
						end,
						type = 'description',
						order = 12,
						fontSize = 'medium',
						hidden = function() return type(userRuleHandler:get('updated')) ~= 'table' end,
					},
					enabled = {
						name = L['Enabled'],
						desc = L['Uncheck to disable this rule globally.'],
						type = 'toggle',
						order = 20,
					},
					_validation = {
						name = function()
							local msg = userRuleHandler:get('error')
							return msg and ('|cffff0000Error '..msg:gsub('^[^:]+:(%d+:)', 'line %1')..'|r') or 'OK'
						end,
						type = 'description',
						hidden = function()
							return not userRuleHandler:get('error')
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
					delete = {
						name = L['Delete'],
						type = 'execute',
						confirm = true,
						confirmText = L['Do you really want to definitively delete this rule ?'],
						order = -1,
						func = 'delete',
					},
				},
			},
		},
	}

end
