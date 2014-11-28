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

function private.GetGlobalOptions(addon)

	local format = _G.format

	local L = addon.L

	return {
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
			debuggingTooltip = {
				name = L['Debugging Tooltip'],
				desc = L['Display spell and item identifiers in tooltips to help debugging AdiButtonAuras.'],
				type = 'toggle',
				order = 25,
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
		},
	}

end
