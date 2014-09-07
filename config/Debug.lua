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

function private.GetDebugOptions(addon, addonName)

	local _G = _G
	local floor = _G.floor
	local format = _G.format
	local GetAddOnMetadata = _G.GetAddOnMetadata
	local GetCVarBool = _G.GetCVarBool
	local GetSpellInfo = _G.GetSpellInfo
	local IsAddOnLoaded = _G.IsAddOnLoaded
	local pairs = _G.pairs
	local strjoin = _G.strjoin
	local strmatch = _G.strmatch
	local tinsert = _G.tinsert
	local tonumber = _G.tonumber
	local tostring = _G.tostring
	local tostringall = _G.tostringall
	local wipe = _G.wipe

	local tconcat = _G.table.concat

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

			p("|cffffffff", strjoin(", ", IdToLink(addon.getkeys(addon.rules))), "|r")

			return tconcat(t, "\n")
		end
	end

	return {
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
	}

end
