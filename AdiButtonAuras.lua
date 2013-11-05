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

local LibSpellbook = LibStub('LibSpellbook-1.0')

--------------------------------------------------------------------------------
-- Stuff to embed
--------------------------------------------------------------------------------

if AdiDebug then
	AdiDebug:Embed(addon, addonName)
	addon.GetName = function() return addonName end
else
	addon.Debug = function() end
end

LibStub('AceEvent-3.0'):Embed(addon)

------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local function IsLoadable(addon)
	local enabled, loadable = select(4, GetAddOnInfo(addon))
	return enabled and loadable and true or nil
end

local toWatch = {
	[addonName] = true,
	Dominos = IsLoadable('Dominos'),
	Bartender4 = IsLoadable('Bartender4'),
}

function addon:ADDON_LOADED(event, name)
	if toWatch.Dominos and (name == 'Dominos' or IsAddOnLoaded('Dominos')) then
		self:Debug('Dominos loaded')
		toWatch.Dominos = nil
		self:ScanButtons("DominosActionButton", 120)
	end
	if toWatch.Bartender4 and (name == 'Bartender4' or IsAddOnLoaded('Bartender4')) then
		self:Debug('Bartender4 loaded')
		toWatch.Bartender4 = nil
		self:ScanButtons("BT4Button", 120)
	end
	if name == addonName then
		self:Debug(name, 'loaded')
		toWatch[addonName] = nil

		self:ScanButtons("ActionButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("BonusActionButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("MultiBarRightButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("MultiBarLeftButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("MultiBarBottomRightButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("MultiBarBottomLeftButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("StanceButton", NUM_STANCE_SLOTS)
		self:ScanButtons("PetActionButton", NUM_PET_ACTION_SLOTS)

		hooksecurefunc('ActionButton_Update', function(button)
			local overlay = self:GetOverlay(button)
			if overlay and overlay:IsVisible() then
				return overlay:UpdateAction('ActionButton_Update')
			end
		end)
		hooksecurefunc('PetActionBar_Update', function()
			for i = 1, NUM_PET_ACTION_SLOTS do
				local overlay = self:GetOverlay(_G['PetActionButton'..i])
				if overlay and overlay:IsVisible() then
					return overlay:UpdateAction('PetActionBar_Update')
				end
			end
		end)
		hooksecurefunc('StanceBar_UpdateState', function()
			for i = 1, NUM_STANCE_SLOTS do
				local overlay = self:GetOverlay(_G['StanceButton'..i])
				if overlay and overlay:IsVisible() then
					return overlay:UpdateAction('StanceBar_UpdateState')
				end
			end
		end)

		self:RegisterEvent('VARIABLES_LOADED', 'UpdateDynamicUnitConditionals')
		self:RegisterEvent('UPDATE_BINDINGS', 'UpdateDynamicUnitConditionals')
		self:RegisterEvent('CVAR_UPDATE')
		self:RegisterEvent('UPDATE_MACROS')
		self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
		self:UpdateDynamicUnitConditionals()

		LibSpellbook.RegisterCallback(addon, 'LibSpellbook_Spells_Changed')
		if LibSpellbook:HasSpells() then
			addon:LibSpellbook_Spells_Changed('OnLoad')
		end
	end
	if not next(toWatch) then
		self:Debug('No more addons to watch.')
		self:UnregisterEvent('ADDON_LOADED')
	end
end

addon:RegisterEvent('ADDON_LOADED')

