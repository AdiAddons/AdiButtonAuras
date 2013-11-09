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

-- Informative control panel
local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = addonName
frame:Hide()

frame:SetScript('OnShow', function()
	frame:SetScript('OnShow', nil)
	
	local header = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	header:SetPoint("TOPLEFT", 16, -16)
	header:SetText(addonName)
	
	local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -16)
	text:SetPoint("BOTTOMRIGHT", -16, 16)
	text:SetJustifyV("TOP")
	text:SetJustifyH("LEFT")
	
	local t = {}
	local p = function(...) tinsert(t, strjoin(" ", tostringall(...))) end

	p("\nPlease note there is no configuration options right now. This panel just is just there for debugging purpose.")

	p("\nVersion", "|cffffffff"..tostring(GetAddOnMetadata(addonName, "Version")).."|r")
	
	p("\nLibraries:")
	for i, lib in ipairs{"CallbackHandler-1.0", "AceTimer-3.0", "AceEvent-3.0", "LibDispellable-1.0", "DRData-1.0", "LibSpellbook-1.0"} do
		local found, minor = LibStub(lib, true)
		if found then
			p("-", lib, "|cffffffff v"..tostring(minor).."|r")
		else
			p("-", lib, "|cffff0000NOT FOUND|r")
		end
	end

	local bugGrabber
	if addon.BugGrabber then
		bugGrabber = 'Embedded BugGrabber'
		p("\nError grabber:", "|cffffffff", name, "|r")
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
	
	local function ColorClass(c, ...)
		if c then
			return "|c"..RAID_CLASS_COLORS[c].colorStr..c.."|r", ColorClass(...)
		end
	end
	
	p("\nSpecific configuration for classes: ", strjoin(", ", ColorClass(addon.getkeys(addon.knownClasses))))
	
	p("\nConfigured spells (spells that are both in your spellbook and", addonName, "rules:")
	
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
	p("|cffffffff", strjoin(", ", IdToLink(addon.getkeys(addon.spells))), "|r")
	
	text:SetText(table.concat(t, "\n"))
end)

InterfaceOptions_AddCategory(frame)
