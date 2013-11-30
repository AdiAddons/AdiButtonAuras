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

local L = setmetatable({}, {
	__index = function(self, key)
		if not key then return end
		--@debug@
		addon.Debug('Localization', key)
		--@end-debug@
		self[key] = key
		return key
	end,
})
addon.L = L

--------------------------------------------------------------------------------
-- Locales from localization system
--------------------------------------------------------------------------------

-- %Localization: adibuttonauras
-- THE END OF THE FILE IS UPDATED BY https://github.com/Adirelle/wowaceTools/#updatelocalizationphp.
-- ANY CHANGE BELOW THESES LINES WILL BE LOST.
-- UPDATE THE TRANSLATIONS AT http://www.wowace.com/addons/adibuttonauras/localization/
-- AND ASK THE AUTHOR TO UPDATE THIS FILE.

-- @noloc[[

------------------------ enUS ------------------------


-- Config.lua
L["Check to flash instead of displaying a border."] = true
L["Check to show a border when the buff is missing."] = true
L["Configure spells and items individually."] = true
L["Countdown Thresholds"] = true
L["Disabled"] = true
L["Do not display the flashing animation on actions in cooldown."] = true
L["Durations above this threshold are hidden."] = true
L["Enabled"] = true
L["Global"] = true
L["Handlers"] = true
L["Inverted"] = true
L["Maximum duration for \"2.7\" format"] = true
L["Maximum duration to show"] = true
L["Minimum duration for \"2m\" format"] = true
L["Minimum duration for \"4:58\" format"] = true
L["No flash in cooldown"] = true
L["Please select a spell or an item..."] = true
L["Profiles"] = true
L["Promote highlight to flash"] = true
L["Rules"] = true
L["Select which rules should by applied to the button."] = true
L["Shift+click to toggle."] = true
L["Spells & items"] = true
L["Status"] = true
L["THIS DOES NOT AFFECT BLIZZARD ANIMATIONS."] = true
L["The color used for bad things, usually debuffs."] = true
L["The color used for good things, usually buffs."] = true
L["Uncheck to ignore this spell/item."] = true
L["\"Bad\" border"] = true
L["\"Good\" border"] = true

-- RuleDSL.lua
L["%s when %s %s is found on %s."] = true
L["Darken"] = true
L["Flash"] = true
L["Lighten"] = true
L["Show %s and %s when %s %s%%."] = true
L["Show %s and %s when %s %s."] = true
L["Show %s and %s when it reaches its maximum."] = true
L["Show %s."] = true
L["Show duration and/or stack count"] = true
L["Show the \"bad\" border"] = true
L["Show the \"good\" border"] = true
L["group members"] = true
L["the buff"] = true
L["the debuff"] = true
L["the targeted ally"] = true
L["the targeted enemy"] = true
L["your buff"] = true
L["your debuff"] = true
L["your pet"] = true
L["yourself"] = true

-- plugins/Mistweaver.lua
L["Highlight when at least %s %s are running and one of them is below %s seconds."] = true
L["Highlight when total effective healing would be at least %d times the base healing."] = true
L["Show the number of group member affected by @NAME and the shortest duration."] = true

-- rules/Common.lua
L["Flash when the targeted enemy is casting/channeling a spell you can interrupt."] = true
L["Show good border when @NAME or an equivalent raid buff is found."] = true
L["Show when @NAME or an equivalent haste buff is found on yourself."] = true
L["a buff you can dispel"] = true
L["a debuff you can dispel"] = true

-- rules/Druid.lua
L["Flash when mastery is inactive."] = true
L["Show combo points and flash at 5."] = true
L["Show lunar energy."] = true
L["Show solar energy."] = true

-- rules/Monk.lua
L["Show stagger level."] = true

-- rules/Warlock.lua
L["Highlight with 3 or more stacks of %s."] = true


------------------------ frFR ------------------------
-- no translation

------------------------ deDE ------------------------
-- no translation

------------------------ esMX ------------------------
-- no translation

------------------------ ruRU ------------------------
-- no translation

------------------------ esES ------------------------
-- no translation

------------------------ zhTW ------------------------
-- no translation

------------------------ zhCN ------------------------
-- no translation

------------------------ koKR ------------------------
-- no translation

------------------------ ptBR ------------------------
-- no translation

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end
