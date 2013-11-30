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
		geterrorhandler()(format("Unlocalized string: %q", tostring(key)))
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
L["Click to show or hide overlay over action buttons."] = true
L["Configure spells and items individually."] = true
L["Countdown Thresholds"] = true
L["Disabled"] = true
L["Durations above this threshold are hidden."] = true
L["Enabled"] = true
L["Global"] = true
L["Handlers"] = true
L["Hide button highlights"] = true
L["Maximum duration for \"2.7\" format"] = true
L["Maximum duration to show"] = true
L["Minimum duration for \"2m\" format"] = true
L["Minimum duration for \"4:58\" format"] = true
L["Please select a spell or an item..."] = true
L["Shift+click to toggle."] = true
L["Show button highlights"] = true
L["Spells & items"] = true
L["Status"] = true
L["The color used for bad things, usually debuffs."] = true
L["The color used for good things, usually buffs."] = true
L["Uncheck to ignore this spell/item."] = true
L["\"Bad\" border"] = true
L["\"Good\" border"] = true


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
