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

AdiButtonAuras:CreateConfig(function(addonName, addon)

	local _G = _G
	local CreateFrame = _G.CreateFrame
	local format = _G.format
	local GameTooltip = _G.GameTooltip
	local GameTooltip_SetDefaultAnchor = _G.GameTooltip_SetDefaultAnchor
	local GetAddOnMetadata = _G.GetAddOnMetadata
	local GetCVarBool = _G.GetCVarBool
	local GetItemInfo = _G.GetItemInfo
	local GetSpellInfo = _G.GetSpellInfo
	local InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory
	local IsAddOnLoaded = _G.IsAddOnLoaded
	local IsShiftKeyDown = _G.IsShiftKeyDown
	local pairs = _G.pairs
	local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
	local setmetatable = _G.setmetatable
	local strjoin = _G.strjoin
	local strmatch = _G.strmatch
	local tinsert = _G.tinsert
	local tonumber = _G.tonumber
	local tostring = _G.tostring
	local tostringall = _G.tostringall
	local UIParent = _G.UIParent
	local UISpecialFrames = _G.UISpecialFrames
	local UNKNOWN = _G.UNKNOWN
	local unpack = _G.unpack
	local wipe = _G.wipe

	local L = addon.L

	local AceConfig = addon.GetLib('AceConfig-3.0')
	local AceConfigDialog = addon.GetLib('AceConfigDialog-3.0')
	local AceConfigRegistry = addon.GetLib('AceConfigRegistry-3.0')

	local selectedKey, selectedName, selectedConf

	------------------------------------------------------------------------------
	-- Button overlays for selection
	------------------------------------------------------------------------------

	local configParent
	local function BuildConfigParent(parent)
		if configParent then return end

		configParent = CreateFrame("Frame", addonName.."ConfigOverlay", parent)
		configParent:Hide()

		local configOverlays

		function configParent:Update()
			AceConfigRegistry:NotifyChange(addonName)
		end

		configParent:SetScript('OnShow', function(self)
			for _, overlay in addon:IterateOverlays() do
				configOverlays[overlay]:SetShown(overlay:IsVisible())
			end
			self:Update()
		end)

		-- Overlays

		local overlayPrototype = setmetatable({	Debug = addon.Debug}, { __index = CreateFrame("Button") })
		local overlayMeta = { __index = overlayPrototype }

		configOverlays = setmetatable({}, { __index = function(t, overlay)
			local conf = setmetatable(CreateFrame("Button", overlay:GetName().."Config", configParent), overlayMeta)
			conf:Initialize(overlay)
			t[overlay] = conf
			return conf
		end })

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

			addon.RegisterMessage(self, addon.CONFIG_CHANGED, "Update")
		end

		function overlayPrototype:Update()
			self.conf, self.enabled, self.key, self.type, self.id = addon:GetActionConfiguration(self.overlay.spellId)
			if self.type == "spell" then
				self.name = GetSpellInfo(self.id)
			elseif self.type == "item" then
				self.name = GetItemInfo(self.id)
			end
			if self.conf then
				if self.enabled then
					self:SetBackdropColor(0, 1, 0, 0.8)
				else
					self:SetBackdropColor(1, 0, 0, 0.8)
				end
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
			else
				selectedKey, selectedName, selectedConf = self.key, self.name, self.conf
			end
			AceConfigRegistry:NotifyChange(addonName)
		end

		local function wrap(str, width)
			local a, b = str:find("%s+", width)
			if not a then return str end
			return str:sub(1, a-1).."\n"..wrap(str:sub(b+1), width)
		end

		function overlayPrototype:OnEnter()
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
			GameTooltip:AddDoubleLine(self.name, self.type and L[self.type]) -- L['item'] L['spell']
			if self.conf then
				if self.enabled then
					GameTooltip:AddDoubleLine(L['Status'], L['Enabled'], nil, nil, nil, 0, 1, 0)
				else
					GameTooltip:AddDoubleLine(L['Status'], L['Disabled'], nil, nil, nil, 1, 0, 0)
				end
				if self.conf.keys then
					GameTooltip:AddLine(L['Rules:'])
					for i, ruleKey in ipairs(self.conf.keys) do
						local enabled = addon.db.profile.rules[ruleKey]
						GameTooltip:AddLine(wrap("- "..addon.ruleDescs[ruleKey], 30), enabled and 0 or 1, enabled and 1 or 0, 0)
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
			else
				GameTooltip:AddDoubleLine(L['Status'], UNKNOWN, nil, nil, nil, 0.5, 0.5, 0.5)
				GameTooltip:AddLine(L['AdiButtonAuras has no rule for this spell/item.'])
			end
			GameTooltip:Show()
		end

		function overlayPrototype:OnLeave()
			if GameTooltip:GetOwner() == self then
				GameTooltip:Hide()
			end
		end

		configParent:Show()
	end

	------------------------------------------------------------------------------
	-- Version display
	------------------------------------------------------------------------------

	local function ColorClass(c, ...)
		if c then
			return "|c"..RAID_CLASS_COLORS[c].colorStr..c.."|r", ColorClass(...)
		end
	end

	local function IdToLink(idstr, ...)
		if not idstr then return end
		local id = tonumber(strmatch(idstr, "^spell:(%d+)$"))
		if id then
			local name, _, icon = GetSpellInfo(id)
			return format("|T%s:0|t %s", icon, name), IdToLink(...)
		else
			return IdToLink(...)
		end
	end

	local GetVersionInfo
	do
		local t = {}
		local p = function(...) tinsert(t, strjoin(" ", tostringall(...))) end
		function GetVersionInfo()
			wipe(t)

			p("\nVersion", "|cffffffff"..tostring(GetAddOnMetadata(addonName, "Version")).."|r")

			p("\nLibraries:")
			for major, minor in pairs(addon.libraries) do
				if minor then
					p("- "..major..": |cffffffff"..tostring(minor).."|r")
				else
					p("- "..major..": |cffff0000NOT FOUND|r")
				end
			end

			local bugGrabber
			if addon.BugGrabber then
				bugGrabber = 'Embedded BugGrabber'
				p("\nError grabber:", "|cffffffff", bugGrabber, "|r")
			elseif IsAddOnLoaded("!BugGrabber") or _G.BugGrabber then
				bugGrabber = "BugGrabber"
			elseif IsAddOnLoaded("!Swatter") or _G.Swatter then
				bugGrabber = "Swatter"
			elseif IsAddOnLoaded("!ImprovedErrorFrame") then
				bugGrabber = "ImprovedErrorFrame"
			elseif GetCVarBool('scriptErrors') then
				bugGrabber = "Blizzard Lua display"
			end
			p("\nError handler:", bugGrabber and ("|cffffffff"..bugGrabber.."|r") or "|cffff0000NONE|r")

			p("\nLibPlayerSpells-1.0 database versions:")
			local lps = LibStub('LibPlayerSpells-1.0')
			for cat in lps:IterateCategories() do
				local _, patch, rev = lps:GetVersionInfo(cat)
				local maj, min = floor(patch/10000), floor(patch/100) % 100
				p(format("- %s: %d.%d, v%d", _G[cat] or cat, maj, min, rev))
			end

			p("\nConfigured spells (spells that are both in your spellbook and", addonName, "rules:")

			p("|cffffffff", strjoin(", ", IdToLink(addon.getkeys(addon.spells))), "|r")

			return table.concat(t, "\n")
		end
	end

	------------------------------------------------------------------------------
	-- Options
	------------------------------------------------------------------------------

	local options
	local function GetOptions()
		if options then return options end

		local profiles = addon.GetLib('AceDBOptions-3.0'):GetOptionsTable(addon.db)
		addon.GetLib('LibDualSpec-1.0'):EnhanceOptions(profiles, addon.db)
		profiles.order = -10
		profiles.disabled = false

		local tmpRuleList = {}

		options = {
			--@debug@
			name = addonName..' DEV',
			--@end-debug@
			--[===[@non-debug@
			name = addonName..' @project-version@',
			--@end-non-debug@]===]
			type = 'group',
			get = 'Get',
			set =' Set',
			childGroups = 'tab',
			args = {
				global = {
					name = L['Global'],
					type = 'group',
					order = 10,
					get = function(info)
						return addon.db.profile[info[#info]]
					end,
					set = function(info, value)
						addon.db.profile[info[#info]] = value
						addon:SendMessage(addon.CONFIG_CHANGED)
					end,
					args = {
						noFlashOnCooldown = {
							name = L['No flash on cooldown'],
							desc = format("%s\n|cffff0000%s|r",
								L['When checked, actions on cooldown do not flash.'],
								L['THIS DOES NOT AFFECT BLIZZARD FLASHES.']
							),
							type = 'toggle',
							order = 10,
						},
						noFlashOutOfCombat = {
							name = L['No flash out of combat'],
							desc = format("%s\n|cffff0000%s|r",
								L['When checked, flashes are disabled while out of combat.'],
								L['THIS DOES NOT AFFECT BLIZZARD FLASHES.']
							),
							type = 'toggle',
							order = 15,
						},
						hints = {
							name = L['Spell Hints'],
							desc = L['AdiButtonAuras provides custom rules to suggest the use of some spells. Choose how these hints are displayed below.'],
							type = 'select',
							order = 20,
							values = {
								show  = L['Rotary Star'],
								flash = L['Flashing Border'],
								hide  = L['Disabled'],
							},
						},
						countdownThresholds = {
							name = L["Countdown Thresholds"],
							type = "group",
							inline = true,
							order = -2,
							args = {
								maxCountdown = {
									name = L['Maximum duration to show'],
									desc = L['Durations above this threshold are hidden. Set to 0 to disable all countdowns.'],
									type = 'range',
									width = 'full',
									order = 10,
									min = 0,
									max = 3600*5,
									softMax = 600,
									step = 5,
								},
								minMinutes = {
									name = L['Minimum duration for the "2m" format'],
									desc = L['Durations above this threshold will use this format.'],
									type = 'range',
									width = 'full',
									order = 20,
									min = 60,
									max = 600,
									softMax = 300,
									step = 10,
								},
								minMinuteSecs = {
									name = L['Minimum duration for the "4:58" format'],
									desc = L['Durations above this threshold will use this format.'],
									type = 'range',
									width = 'full',
									order = 30,
									min = 60,
									max = 600,
									softMax = 300,
									step = 10,
								},
								maxTenth = {
									name = L['Maximum duration for the "2.7" format'],
									desc = L['Durations below this threshold will show decimals. Set to 0 to disable.'],
									type = 'range',
									width = 'full',
									order = 40,
									min = 0,
									max = 10,
									step = 0.5,
								},
							}
						},
						colors = {
							name = "Colors",
							type = "group",
							inline = true,
							order = -1,
							get = function(info)
								return unpack(addon.db.profile.colors[info[#info]], 1, 4)
							end,
							set = function(info, ...)
								local c = addon.db.profile.colors[info[#info]]
								c[1], c[2], c[3], c[4] = ...
								addon:SendMessage(addon.CONFIG_CHANGED)
							end,
							args = {
								good = {
									name = L['"Good" border'],
									desc = L['The color used for good things, usually buffs.'],
									type = 'color',
									hasAlpha = true,
									order = 10,
								},
								bad = {
									name = L['"Bad" border'],
									desc = L['The color used for bad things, usually debuffs.'],
									type = 'color',
									hasAlpha = true,
									order = 20,
								},
								countdownLow = {
									name = L['Countdown around 0'],
									desc = L['Color of the countdown text for values around 0.'],
									type = 'color',
									order = 30,
								},
								countdownMedium = {
									name = L['Countdown around 3'],
									desc = L['Color of the countdown text for values around 3.'],
									type = 'color',
									order = 40,
								},
								countdownHigh = {
									name = L['Countdown above 10'],
									desc = L['Color of the countdown text for values above 3.'],
									type = 'color',
									order = 50,
								},
							},
						}
					},
				},
				spells = {
					name = L['Spells & items'],
					desc = L['Configure spells and items.'],
					type = 'group',
					order = 20,
					disabled = function(info) return info[#info] ~= "spells" and not selectedKey end,
					args = {
						_help = {
							name = L["- Select a spell or item by clicking a highlighted button from your actionbars. \n- Green buttons have recognized settings and are enabled. Red buttons are recognized but disabled. \n- Darkened buttons indicate spells and items unknown to AdiButtonAuras."],
							type = 'description',
							order = 1,
						},
						_name = {
							name = function() return selectedName or L["No selection"] end,
							type = 'header',
							order = 10,
						},
						enabled = {
							name = L['Enabled'],
							desc = L['Uncheck to ignore this spell/item.'],
							order = 20,
							type = 'toggle',
							get = function()
								return addon.db.profile.enabled[selectedKey]
							end,
							set = function(_, flag)
								addon.db.profile.enabled[selectedKey] = flag
								addon:SendMessage(addon.CONFIG_CHANGED)
							end
						},
						inverted = {
							name = L['Inverted'],
							desc = L['Check to show a border when the (de)buff is missing.'],
							order = 30,
							type = 'toggle',
							get = function()
								return addon.db.profile.inverted[selectedKey]
							end,
							set = function(_, flag)
								addon.db.profile.inverted[selectedKey] = flag
								addon:SendMessage(addon.CONFIG_CHANGED)
							end
						},
						flashPromotion = {
							name = L['Show flash instead'],
							desc = L['Check to show a flash instead of a colored border.'],
							order = 40,
							type = 'toggle',
							width = 'double',
							get = function()
								return addon.db.profile.flashPromotion[selectedKey]
							end,
							set = function(_, flag)
								addon.db.profile.flashPromotion[selectedKey] = flag
								addon:SendMessage(addon.CONFIG_CHANGED)
							end
						},
						rules = {
							name = L['Rules'],
							desc = L['Select which rules should by applied.'],
							order = 50,
							width = 'full',
							type = 'multiselect',
							get = function(_, index)
								return addon.db.profile.rules[selectedConf.keys[index]]
							end,
							set = function(_, index, flag)
								addon.db.profile.rules[selectedConf.keys[index]] = flag
								addon:LibSpellbook_Spells_Changed('OnRuleConfigChanged')
							end,
							values = function()
								wipe(tmpRuleList)
								for i, key in ipairs(selectedConf.keys) do
									tmpRuleList[i] = addon.ruleDescs[key]
								end
								return tmpRuleList
							end,
							hidden = function() return not selectedConf or not selectedConf.keys or #(selectedConf.keys) == 0 end
						},
					},
				},
				--@debug@
				debug = {
					name = 'Debug information',
					type = 'group',
					order = -1,
					args = {
						_text = {
							name = GetVersionInfo,
							type = "description",
							width = 'full',
							fontSize = 'medium',
						},
					},
				},
				--@end-debug@
				profiles = profiles,
			},
		}

		return options
	end

	------------------------------------------------------------------------------
	-- Setup
	------------------------------------------------------------------------------

	AceConfig:RegisterOptionsTable(addonName, GetOptions)

	local mainPanel = AceConfigDialog:AddToBlizOptions(addonName, addonName, nil, "global")
	local spellPanel = AceConfigDialog:AddToBlizOptions(addonName, L['Spells & items'], addonName, "spells")
	local profilePanel = AceConfigDialog:AddToBlizOptions(addonName, L['Profiles'], addonName, "profiles")
	--@debug@
	AceConfigDialog:AddToBlizOptions(addonName, "Debug", addonName, "debug")
	--@end-debug@

	spellPanel:HookScript('OnShow', function(self)
		selectedKey, selectedName, selectedConf = nil, nil, nil
		if not configParent then
			BuildConfigParent(self)
		end
	end)

	local LibSpellbook = addon.GetLib('LibSpellbook-1.0')

	-- Override addon OpenConfiguration
	function addon:OpenConfiguration(what)
		what = (what or ""):trim():lower()
		if what == 'spell' or what == 'spells' then
			return InterfaceOptionsFrame_OpenToCategory(spellPanel)
		elseif what == 'profile' or what == 'profiles' then
			return InterfaceOptionsFrame_OpenToCategory(profilePanel)
		end
		if what then
			local _type, id = strmatch(what, '([si][pt]e[lm]l?):(%d+)')
			if not id then
				id = LibSpellbook:Resolve(what)
				if id then
					_type = 'spell'
				end
			end
			local key = (_type == 'spell' or _type == 'item') and id and _type..':'..id
			if key and addon.spells[key] then
				local name = _type == 'spell' and GetSpellInfo(id) or GetItemInfo(id)
				InterfaceOptionsFrame_OpenToCategory(spellPanel)
				selectedKey, selectedName, selectedConf = key, name, addon.spells[key]
				AceConfigRegistry:NotifyChange(addonName)
				return
			end
		end
		InterfaceOptionsFrame_OpenToCategory(mainPanel)
	end

end)
