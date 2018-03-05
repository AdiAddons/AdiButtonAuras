--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2016 Adirelle (adirelle@gmail.com)
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

local _G = _G

function private.GetSpellOptions(addon, addonName)

	local CreateFrame = _G.CreateFrame
	local format = _G.format
	local GameTooltip = _G.GameTooltip
	local GameTooltip_SetDefaultAnchor = _G.GameTooltip_SetDefaultAnchor
	local GetItemInfo = _G.GetItemInfo
	local GetSpellInfo = _G.GetSpellInfo
	local hooksecurefunc = _G.hooksecurefunc
	local ipairs = _G.ipairs
	local IsShiftKeyDown = _G.IsShiftKeyDown
	local pairs = _G.pairs
	local setmetatable = _G.setmetatable
	local UNKNOWN = _G.UNKNOWN
	local wipe = _G.wipe

	local L = addon.L

	local rules = addon.rules
	local descriptions = addon.descriptions

	local AceConfigRegistry = addon.GetLib('AceConfigRegistry-3.0')

	local function wrap(str, width)
		local a, b = str:find("%s+", width)
		if not a then return str end
		return str:sub(1, a-1).."\n"..wrap(str:sub(b+1), width)
	end

	------------------------------------------------------------------------------
	-- Handler
	------------------------------------------------------------------------------

	local handler = { current = nil }

	function handler:Select(key)
		if self.current == key then return end
		self.current = key
		AceConfigRegistry:NotifyChange(addonName)
	end

	function handler:GetRule()
		return self.current and rules[self.current]
	end

	function handler:GetCurrentName()
		local rule = self:GetRule()
		return rule and rule.name or L['No selection']
	end

	function handler:Get(info)
		local property = info[#info]
		return addon.db.profile[property][self.current]
	end

	function handler:Set(info, value)
		local property = info[#info]
		addon.db.profile[property][self.current] = value
		if property == "enabled" then
			addon:LibSpellbook_Spells_Changed('OnRuleConfigChanged')
		else
			addon:SendMessage(addon.CONFIG_CHANGED)
		end
	end

	function handler:GetRuleState(_, index)
		local rule = self:GetRule()
		return addon.db.profile.rules[rule.keys[index]]
	end

	function handler:SetRuleState(_, index, flag)
		local rule = self:GetRule()
		addon.db.profile.rules[rule.keys[index]] = flag
		addon:LibSpellbook_Spells_Changed('OnRuleConfigChanged')
	end

	local t = {}
	function handler:GetRuleList(_, index, flag)
		wipe(t)
		for i, key in ipairs(self:GetRule().keys) do
			t[i] = descriptions[key]
		end
		return t
	end

	function handler:HasNoRules(_, index, flag)
		local rule = self:GetRule()
		return not rule or not rule.keys or #(rule.keys) == 0
	end

	------------------------------------------------------------------------------
	-- Overlay prototype
	------------------------------------------------------------------------------

	local overlayPrototype = setmetatable({}, { __index = CreateFrame("Button") })
	local overlayMeta = { __index = overlayPrototype }

	local backdrop = {
		bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	function overlayPrototype:Initialize(overlay)
		self:Hide()

		self:SetFrameStrata("HIGH")

		self:SetBackdrop(backdrop)
		self:SetBackdropBorderColor(0,0,0,0)

		self:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], "ADD")

		self.overlay = overlay
		self:SetAllPoints(overlay)
		self:RegisterForClicks('LeftButtonUp')

		self:SetScript('OnShow', self.Update)
		self:SetScript('OnClick', self.OnClick)
		self:SetScript('OnEnter', self.OnEnter)
		self:SetScript('OnLeave', self.OnLeave)

		overlay:HookScript('OnShow', function() self:Show() end)
		overlay:HookScript('OnHide', function() self:Hide() end)

		hooksecurefunc(overlay, "SetAction", function()
			if self:IsVisible() then
				return self:Update()
			end
		end)

		addon.RegisterMessage(self, addon.CONFIG_CHANGED, "Update")
	end

	function overlayPrototype:Update()
		local type_, id = self.overlay.actionType, self.overlay.actionId
		self.conf, self.enabled, self.key = addon:GetActionConfiguration(type_, id)
		if type_ == "spell" then
			self.name = GetSpellInfo(id)
		elseif type_ == "item" then
			type_ = GetItemInfo(id)
		end
		if self.conf then
			if self.enabled then
				self:SetBackdropColor(0, 1, 0, 0.8)
			else
				self:SetBackdropColor(1, 0, 0, 0.8)
			end
		elseif type_ == "unsupported" then
			self:SetBackdropColor(1, 0.8, 0.4, 0)
		else
			self:SetBackdropColor(0, 0, 0, 0.8)
		end
		if GameTooltip:GetOwner() == self then
			self:OnEnter()
		end
	end

	function overlayPrototype:OnClick()
		if not self.conf then
			return
		end
		if IsShiftKeyDown() then
			addon.db.profile.enabled[self.key] = not addon.db.profile.enabled[self.key]
			addon.SendMessage(self, addon.CONFIG_CHANGED)
			return AceConfigRegistry:NotifyChange(addonName)
		end
		handler:Select(self.key)
	end

	function overlayPrototype:OnEnter()
		local type_, id = self.overlay.actionType, self.overlay.actionId
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:AddDoubleLine(self.name or "???", type_ and L[type_]) -- L['item'] L['spell'] L['unsupported']
		if self.conf then
			if self.enabled then
				GameTooltip:AddDoubleLine(L['Status'], L['Enabled'], nil, nil, nil, 0, 1, 0)
			else
				GameTooltip:AddDoubleLine(L['Status'], L['Disabled'], nil, nil, nil, 1, 0, 0)
			end
			if self.conf.keys then
				GameTooltip:AddLine(L['Rules:'])
				for i, key in ipairs(self.conf.keys) do
					local enabled = addon.db.profile.rules[key]
					GameTooltip:AddLine(wrap("- "..descriptions[key], 30), enabled and 0 or 1, enabled and 1 or 0, 0)
				end
			end
			GameTooltip:AddLine(L['Shift+click to toggle.'])
			--@debug@
			GameTooltip:AddLine("-- debug --", 0.5, 0.5, 0.5)
			GameTooltip:AddDoubleLine("Key", self.key, nil, nil, nil, 1, 1, 1)
			GameTooltip:AddDoubleLine("Id", self.id, nil, nil, nil, 1, 1, 1)
			local title = "Units"
			for unit in pairs(self.conf.units) do
				GameTooltip:AddDoubleLine(title, unit, nil, nil, nil, 1, 1, 1)
				title = " "
			end
			title = "Events"
			for event in pairs(self.conf.events) do
				GameTooltip:AddDoubleLine(title, event, nil, nil, nil, 1, 1, 1)
				title = " "
			end
			GameTooltip:AddDoubleLine('Handlers', #(self.conf.handlers), nil, nil, nil, 1, 1, 1)
			--@end-debug@
		elseif type_ == 'unsupported' then
			GameTooltip:AddDoubleLine(L['Status'], L['unsupported'], nil, nil, nil, 0.8, 0.4, 0.0)
			GameTooltip:AddLine(L['AdiButtonAuras cannot handle this button.'], 0.8, 0.4, 0.0)
		else
			GameTooltip:AddDoubleLine(L['Status'], UNKNOWN, nil, nil, nil, 0.5, 0.5, 0.5)
			GameTooltip:AddLine(format(L['AdiButtonAuras has no rules for this %s.'], type_ and L[type_] or L["button"]), 0.5, 0.5, 0.5)
			if self.key then
				GameTooltip:AddDoubleLine(L["Action 'key' for reference"], self.key, nil, nil, nil, 1, 1, 1)
			end
		end
		GameTooltip:Show()
	end

	function overlayPrototype:OnLeave()
		if GameTooltip:GetOwner() == self then
			GameTooltip:Hide()
		end
	end

	------------------------------------------------------------------------------
	-- The frame containing the parent overlays
	------------------------------------------------------------------------------

	local overlayParent = CreateFrame("Frame", addonName.."ConfigOverlayParent")

	local overlays = setmetatable({}, { __index = function(self, overlay)
		local conf = setmetatable(CreateFrame("Button", overlay:GetName().."Config", overlayParent), overlayMeta)
		conf:Initialize(overlay)
		self[overlay] = conf
		return conf
	end })

	overlayParent:SetScript('OnShow', function()
		for _, overlay in addon:IterateOverlays() do
			overlays[overlay]:SetShown(overlay:IsVisible())
		end
		handler:Select(nil)
	end)

	------------------------------------------------------------------------------
	-- "API"
	------------------------------------------------------------------------------

	function private.SetOverlayParent(parent)
		overlayParent:SetParent(parent)
	end

	function private.SelectSpell(key)
		return handler:Select(key)
	end

	------------------------------------------------------------------------------
	-- The options
	------------------------------------------------------------------------------

	local tmpRuleList = {}

	return {
		name = L['Spells & items'],
		desc = L['Configure spells and items.'],
		type = 'group',
		order = 20,
		handler = handler,
		disabled = function(info) return info[#info] ~= "spells" and not handler.current end,
		get = 'Get',
		set = 'Set',
		args = {
			_help = {
				name = L["- Select a spell or item by clicking a highlighted button from your actionbars. \n- Green buttons have recognized settings and are enabled. Red buttons are recognized but disabled. \n- Darkened buttons indicate spells and items unknown to AdiButtonAuras."],
				type = 'description',
				order = 1,
			},
			_name = {
				name = function() return handler:GetCurrentName() end,
				type = 'header',
				order = 10,
			},
			enabled = {
				name = L['Enabled'],
				desc = L['Uncheck to ignore this spell/item.'],
				order = 20,
				type = 'toggle',
			},
			flashPromotion = {
				name = L['Show flash instead'],
				desc = L['Check to show a flash instead of a colored border.'],
				order = 25,
				type = 'toggle',
				disabled = function()
					return addon.db.profile.missing[handler.current] ~= 'none'
				end,
			},
			_empty = {
				name = '',
				order = 30,
				type = 'description',
			},
			missing = {
				name = L['Show missing'],
				desc = L['Select the method for showing missing (de)buffs.'],
				order = 40,
				type = 'select',
				values = {
					none = L['Disabled'],
					highlight = L['Show border'],
					flash = L['Show flash'],
					hint = L['Show hint'],
				},
				set = function(info, value)
					handler:Set(info, value)
					if value ~= 'none' then
						addon.db.profile.flashPromotion[handler.current] = nil
					end
				end,
			},
			missingThreshold = {
				name = L['Show missing threshold'],
				desc = L['Show the missing highlight when the remaining duration is below this value.'],
				order = 45,
				type = 'range',
				min = 0,
				max = 10,
				step = 1,
				disabled = function()
					return addon.db.profile.missing[handler.current] == 'none'
				end,
			},
			rules = {
				name = L['Rules'],
				desc = L['Select which rules should by applied.'],
				order = 50,
				width = 'full',
				type = 'multiselect',
				get = 'GetRuleState',
				set = 'SetRuleState',
				values = 'GetRuleList',
				hidden = 'HasNoRules',
			},
		},
	}

end
