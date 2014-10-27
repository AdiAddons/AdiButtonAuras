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

-- GLOBALS: LibStub

function private.GetDebugOptions(addon, addonName)

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

	local t = {}
	local p = function(...) tinsert(t, strjoin(" ", tostringall(...))) end

	local function GetMainDebug()
		p("\nVersion", "|cffffffff"..tostring(GetAddOnMetadata(addonName, "Version")).."|r")

		local errorHandler
		if addon.BugGrabber then
			errorHandler = 'Embedded BugGrabber'
			p("\nError grabber:", "|cffffffff", errorHandler, "|r")
		elseif IsAddOnLoaded("!BugGrabber") or _G.BugGrabber then
			errorHandler = "BugGrabber"
		elseif IsAddOnLoaded("!Swatter") or _G.Swatter then
			errorHandler = "Swatter"
		elseif IsAddOnLoaded("!ImprovedErrorFrame") then
			errorHandler = "ImprovedErrorFrame"
		elseif GetCVarBool('scriptErrors') then
			errorHandler = "Blizzard Lua display"
		end
		p("\nError handler:", errorHandler and ("|cffffffff"..errorHandler.."|r") or "|cffff0000NONE|r")
	end

	local function GetLibraryVersions()
		for major, minor in pairs(addon.libraries) do
			if minor then
				p("- "..major..": |cffffffff"..tostring(minor).."|r")
			else
				p("- "..major..": |cffff0000NOT FOUND|r")
			end
		end
	end

	local function GetLPS()
		local lps = LibStub('LibPlayerSpells-1.0')
		for cat in lps:IterateCategories() do
			local _, patch, rev = lps:GetVersionInfo(cat)
			local maj, min = floor(patch/10000), floor(patch/100) % 100
			p(format("- %s: %d.%d, v%d", _G[cat] or cat, maj, min, rev))
		end
	end

	local function GetKnownSpells()
		p("\nConfigured spells (spells that are both in your spellbook and", addonName, "rules:")
		p("|cffffffff", strjoin("\n", IdToLink(addon.getkeys(addon.rules))), "|r")
	end

	local function CreatePanel(name, order, func)
		return {
			name = name,
			type = "group",
			order = order,
			args = {
				text = {
					name = function()
						wipe(t)
						func()
						return tconcat(t, "\n")
					end,
					type = "description",
					width = 'full',
					fontSize = 'medium',
				},
			}
		}
	end

	return {
		name = 'Debug',
		type = 'group',
		order = -1,
		childGroups  = 'tab',
		args = {
			general   = CreatePanel('General', 10, GetMainDebug),
			libraries = CreatePanel('Libraries', 20, GetLibraryVersions),
			lps       = CreatePanel('LibPlayerSpells-1.0', 30, GetLPS),
			spells    = CreatePanel('Spells', 40, GetKnownSpells),
		},
	}

end
