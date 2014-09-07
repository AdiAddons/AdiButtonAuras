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

function private.GetUserRulesOptions(addon)

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

	local fullPlayerName = GetUnitName("player", false).. ' - '..GetRealmName()
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
			rule.patch = GetBuildInfo()
			rule.revision = 0
			rule.createdBy = fullPlayerName
			rule.createdAt = time()
			rule.lastModifiedBy = fullPlayerName
			rule.lastModifiedAt = time()
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
				rule.lastModifiedAt = time()
				rule.lastModifiedBy= fullPlayerName
				rule.patch = GetBuildInfo()
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
					_created = {
						name = function()
							return format(
								L["Created by %s at %s for patch %s"],
								userRuleHandler:get('createdBy'),
								date("%x %X", userRuleHandler:get('createdAt')),
								userRuleHandler:get('patch')
							)
						end,
						type = 'description',
						order = 11,
					},
					_updated = {
						name = function()
							return format(
								L["Last modified by %s at %s, revision #%d"],
								userRuleHandler:get('lastModifiedBy'),
								date("%x %X", userRuleHandler:get('lastModifiedAt')),
								userRuleHandler:get('revision')
							)
						end,
						type = 'description',
						order = 12,
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
							return msg and ('|cffff0000'..msg..'|r') or 'OK'
						end,
						hidden = function()
							return not userRuleHandler:get('error')
						end,
						type = 'description',
						order = 29,
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
