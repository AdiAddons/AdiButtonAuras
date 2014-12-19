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

local _G = _G

function private.GetThemeOptions(addon, addonName)

	local unpack = _G.unpack
	local L = addon.L
	local Masque = addon.GetLib('Masque', true)

	local masqueOption
	if Masque then
		local group = Masque:Group(addonName)
		masqueOption = {
			name = L['Use Masque'],
			type = 'toggle',
			order = 25,
			set = function(_, enabled)
				if enabled then
					group:Enable()
				else
					group:Disable()
				end
			end,
			get = function()
				return not group.db.Disabled
			end,
		}
	end

	return {
		name = L['Theme'],
		type = 'group',
		order = 30,
		get = function(info)
			return addon.db.profile[info[#info]]
		end,
		set = function(info, value)
			addon.db.profile[info[#info]] = value
			addon:SendMessage(addon.THEME_CHANGED)
		end,
		args = {
			texts = {
				name = L['Texts'],
				type = 'group',
				inline = true,
				order = 10,
				args = {
					fontName = {
						name = L['Font'],
						desc = L['Select the font to be used to display both countdown and application count.'],
						type = 'select',
						dialogControl = 'LSM30_Font',
						-- GLOBALS: AceGUIWidgetLSMlists
						values = AceGUIWidgetLSMlists.font,
						order = 10,
					},
					fontSize = {
						name = L['Size'],
						desc = L['Adjust the font size of countdown and application count texts.'],
						type = 'range',
						min = 5,
						max = 30,
						step = 1,
						order = 20,
					},
				},
			},
			colors = {
				name = "Colors",
				type = "group",
				inline = true,
				order = 20,
				get = function(info)
					return unpack(addon.db.profile.colors[info[#info]], 1, 4)
				end,
				set = function(info, ...)
					local c = addon.db.profile.colors[info[#info]]
					c[1], c[2], c[3], c[4] = ...
					addon:SendMessage(addon.THEME_CHANGED)
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
			},
			masque = masqueOption,
			highlightTexture = {
				name = L['Highlight texture'],
				desc = L['Select the texture used to highlight buttons.'],
				type = 'select',
				dialogControl = 'LSM30_Background',
				values = addon.GetLib('LibSharedMedia-3.0'):HashTable(addon.HIGHLIGHT_MEDIATYPE),
				disabled = function() return Masque and addon.db.profile.masque end,
				order = 30,
				width = 'double',
			},
		},
	}

end
