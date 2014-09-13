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

AdiButtonAuras:CreateConfig(function(addonName, addon)

	local _G = _G
	local GetItemInfo = _G.GetItemInfo
	local GetSpellInfo = _G.GetSpellInfo
	local strmatch = _G.strmatch

	local AceConfig = addon.GetLib('AceConfig-3.0')
	local AceConfigDialog = addon.GetLib('AceConfigDialog-3.0')
	local LibSpellbook = addon.GetLib('LibSpellbook-1.0')

	local L = addon.L

	local profiles = addon.GetLib('AceDBOptions-3.0'):GetOptionsTable(addon.db)
	addon.GetLib('LibDualSpec-1.0'):EnhanceOptions(profiles, addon.db)
	profiles.order = -10
	profiles.disabled = false

	AceConfig:RegisterOptionsTable(addonName, {
		--@debug@
		name = addonName..' DEV',
		--@end-debug@
		--[===[@non-debug@
		name = addonName..' @project-version@',
		--@end-non-debug@]===]
		type = 'group',
		childGroups = 'tab',
		args = {
			global    = private.GetGlobalOptions(addon, addonName),
			spells    = private.GetSpellOptions(addon, addonName),
			theme     = private.GetThemeOptions(addon, addonName),
			userRules = private.GetUserRulesOptions(addon, addonName),
			--@debug@
			debug     = private.GetDebugOptions(addon, addonName),
			--@end-debug@
			profiles  = profiles,
		},
	})

	local panels = {
		main      = AceConfigDialog:AddToBlizOptions(addonName, addonName, nil, "global"),
		spells    = AceConfigDialog:AddToBlizOptions(addonName, L['Spells & items'], addonName, "spells"),
		theme     = AceConfigDialog:AddToBlizOptions(addonName, L['Theme'], addonName, "theme"),
		userRules = AceConfigDialog:AddToBlizOptions(addonName, L['User rules'], addonName, "userRules"),
		profiles  = AceConfigDialog:AddToBlizOptions(addonName, L['Profiles'], addonName, "profiles"),
		--@debug@
		debug     = AceConfigDialog:AddToBlizOptions(addonName, "Debug", addonName, "debug"),
		--@end-debug@
	}

	-- Pass the spell panel frame
	private.SetOverlayParent(panels.spells)

	-- Aliases
	panels[""] = panels.main
	panels.spell = panels.spells
	panels.profile = panels.profiles

	-- Override addon OpenConfiguration
	function addon:OpenConfiguration(what)
		what = (what or ""):trim():lower()

		if panels[what] then
			return InterfaceOptionsFrame_OpenToCategory(panels[what])
		end

		local _type, id = strmatch(what, '([si][pt]e[lm]l?):(%d+)')
		if not id then
			id = LibSpellbook:Resolve(what)
			if id then
				_type = 'spell'
			end
		end
		local key = (_type == 'spell' or _type == 'item') and id and _type..':'..id
		if key and addon.spells[key] then
			InterfaceOptionsFrame_OpenToCategory(spellPanel)
			private.SelectSpell(key)
		end
	end

end)
