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

local addonName, addon = ...

local _G = _G
local CreateFrame = _G.CreateFrame
local GetAddOnInfo = _G.GetAddOnInfo
local GetCVarBool = _G.GetCVarBool
local GetModifiedClick = _G.GetModifiedClick
local gsub = _G.gsub
local hooksecurefunc = _G.hooksecurefunc
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local next = _G.next
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS
local pairs = _G.pairs
local select = _G.select
local strmatch = _G.strmatch
local tinsert = _G.tinsert
local type = _G.type
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID
local UnitIsUnit = _G.UnitIsUnit
local wipe = _G.wipe

local L = addon.L

-- API
local api = {}
addon.api = api
_G.AdiButtonAuras = api

------------------------------------------------------------------------------
-- Default config
------------------------------------------------------------------------------

addon.DEFAULT_SETTINGS = {
	profile = {
		enabled = { ['*'] = true },
		rules = { ['*'] = true },
		inverted = { ['*'] = false },
		flashPromotion = { ['*'] = false },
		colors = {
			good            = { 0.0, 1.0, 0.0, 0.7 },
			bad             = { 1.0, 0.0, 0.0, 0.7 },
			countdownLow    = { 1.0, 0.0, 0.0 },
			countdownMedium = { 1.0, 1.0, 0.0 },
			countdownHigh   = { 1.0, 1.0, 1.0 },
		},
		maxCountdown = 600,
		minMinutes = 600,
		minMinuteSecs = 60,
		maxTenth = 3,
		noFlashOnCooldown = false,
		noFlashOutOfCombat = false,
		hints = "show",
		fontSize = 13,
	}
}

------------------------------------------------------------------------------
-- Keep track of used libraries and their version
------------------------------------------------------------------------------

local libraries = {}
local function GetLib(major, silent)
	local lib, minor = LibStub(major, silent)
	libraries[major] = minor
	return lib, minor
end
addon.libraries, addon.GetLib = libraries, GetLib

------------------------------------------------------------------------------
-- Fetch default font
------------------------------------------------------------------------------

do
	local LSM = GetLib('LibSharedMedia-3.0')
	addon.DEFAULT_SETTINGS.profile.fontName = LSM:GetDefault(LSM.MediaType.FONT)

	local wantedFile = _G.NumberFontNormalSmall:GetFont()
	for name, file in pairs(LSM:HashTable(LSM.MediaType.FONT)) do
		if file == wantedFile then
			addon.DEFAULT_SETTINGS.profile.fontName = name
			break
		end
	end

end

------------------------------------------------------------------------------
-- Stuff to embed
------------------------------------------------------------------------------

if AdiDebug then
	AdiDebug:Embed(addon, addonName)
	addon.GetName = function() return addonName end
else
	addon.Debug = function() end
end

local mixins = {}
-- Event dispatching using CallbackHandler-1.0
local events = GetLib('CallbackHandler-1.0'):New(mixins, 'RegisterEvent', 'UnregisterEvent', 'UnregisterAllEvents')
local frame = CreateFrame("Frame")
frame:SetScript('OnEvent', function(_, ...) return events:Fire(...) end)
function events:OnUsed(_, event) return frame:RegisterEvent(event) end
function events:OnUnused(_, event) return frame:UnregisterEvent(event) end

-- Messaging using CallbackHandler-1.0
local bus = GetLib('CallbackHandler-1.0'):New(mixins, 'RegisterMessage', 'UnregisterMessage', 'UnregisterAllMessages')
addon.SendMessage = bus.Fire

local messages = {}
function bus:OnUsed(_, message)
	addon.Debug('Messages', 'OnUsed', message)
	if messages[message] and messages[message].OnUsed then
		messages[message].OnUsed(message)
	end
end
function bus:OnUnused(_, message)
	addon.Debug('Messages', 'OnUnused', message)
	if messages[message] and messages[message].OnUnused then
		messages[message].OnUnused(message)
	end
end
function mixins:DeclareMessage(message, OnUsed, OnUnused)
	messages[message] = { OnUsed = OnUsed, OnUnused = OnUnused }
end
function mixins:IsDeclaredMessage(str)
	return str and messages[str] and true
end

for name, func in pairs(mixins) do
	addon[name] = func
	api[name] = func
end

------------------------------------------------------------------------------
-- Initialization
------------------------------------------------------------------------------

local function IsLoadable(addon)
	local enabled, loadable = select(4, GetAddOnInfo(addon))
	return enabled and loadable and true or nil
end

local toWatch = {
	[addonName] = true,
	["LibActionButton-1.0"] = true,
	Dominos = IsLoadable('Dominos'),
	Bartender4 = IsLoadable('Bartender4'),
}

local function UpdateHandler(event, button)
	local overlay = addon:GetOverlay(button)
	if overlay and overlay:IsVisible() then
		return overlay:UpdateAction(event)
	end

end
local CONFIG_CHANGED = addonName..'_Config_Changed'
local THEME_CHANGED = addonName..'_Theme_Changed'
addon.CONFIG_CHANGED = CONFIG_CHANGED
addon.THEME_CHANGED = THEME_CHANGED

function addon:ADDON_LOADED(event, name)
	-- Initialization
	if name == addonName then
		self:Debug(name, 'loaded')
		toWatch[addonName] = nil

		self.db = GetLib('AceDB-3.0'):New(addonName.."DB", self.DEFAULT_SETTINGS, true)
		self.db.RegisterCallback(self, "OnProfileChanged")
		self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
		self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

		GetLib('LibDualSpec-1.0'):EnhanceDatabase(self.db, addonName)

		self:ScanButtons("ActionButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("BonusActionButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("MultiBarRightButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("MultiBarLeftButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("MultiBarBottomRightButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("MultiBarBottomLeftButton", NUM_ACTIONBAR_BUTTONS)
		self:ScanButtons("StanceButton", NUM_STANCE_SLOTS)
		self:ScanButtons("PetActionButton", NUM_PET_ACTION_SLOTS)

		hooksecurefunc('ActionButton_Update', function(button)
			return UpdateHandler('ActionButton_Update', button)
		end)
		hooksecurefunc('PetActionBar_Update', function()
			for i = 1, NUM_PET_ACTION_SLOTS do
				UpdateHandler('PetActionBar_Update', _G['PetActionButton'..i])
			end
		end)
		hooksecurefunc('StanceBar_UpdateState', function()
			for i = 1, NUM_STANCE_SLOTS do
				UpdateHandler('StanceBar_UpdateState', _G['StanceButton'..i])
			end
		end)

		self:RegisterEvent('UPDATE_MACROS')

		self:UpdateDynamicUnitConditionals()

		local LibSpellbook = GetLib('LibSpellbook-1.0')
		LibSpellbook.RegisterCallback(addon, 'LibSpellbook_Spells_Changed')
		if LibSpellbook:HasSpells() then
			addon:LibSpellbook_Spells_Changed('OnLoad')
		end
	end

	-- Supported addons and libraries
	if toWatch.Dominos and (name == 'Dominos' or IsAddOnLoaded('Dominos')) then
		self:Debug('Dominos loaded')
		toWatch.Dominos = nil
		self:ScanButtons("DominosActionButton", 120)
	end
	if toWatch["LibActionButton-1.0"] and GetLib('LibActionButton-1.0', true) then
		self:Debug('Found LibActionButton-1.0')
		toWatch["LibActionButton-1.0"] = nil
		local lab = GetLib('LibActionButton-1.0')
		lab.RegisterCallback(self, 'OnButtonCreated', UpdateHandler)
		lab.RegisterCallback(self, 'OnButtonUpdate', UpdateHandler)
		for button in pairs(lab:GetAllButtons()) do
			local _ = self:GetOverlay(button)
		end
	end
	if toWatch.Bartender4 and (name == 'Bartender4' or IsAddOnLoaded('Bartender4')) then
		self:Debug('Bartender4 loaded')
		toWatch.Bartender4 = nil
		self:ScanButtons("BT4Button", 120)
		self:ScanButtons("BT4PetButton", NUM_PET_ACTION_SLOTS)
		self:ScanButtons("BT4StanceButton", NUM_STANCE_SLOTS)
	end

	if not next(toWatch) then
		self:Debug('No more addons to watch.')
		self:UnregisterEvent('ADDON_LOADED')
	end
end

addon:RegisterEvent('ADDON_LOADED')

function addon:OnProfileChanged()
	self:SendMessage(CONFIG_CHANGED)
end

function addon:GetActionConfiguration(actionType, actionId)
	if type(actionType) ~= "string" then return end
	local key
	if type(actionId) == "number" then
		key = actionType..':'..actionId
	else
		key, actionType, actionId = actionType, strmatch(actionType, "^(%a+):(%d+)$")
		actionId = tonumber(actionId)
	end
	if not key then return end
	local conf = self.spells[key] or (actionType == "item" and self.items[actionId])
	if conf then
		return conf, self.db.profile.enabled[key], key, actionType, actionId
	else
		return nil, false, key, actionType, actionId
	end

end

------------------------------------------------------------------------------
-- Handle load-on-demand configuration
------------------------------------------------------------------------------

-- Create a fake configuration panel
local configLoaderPanel = CreateFrame("Frame")
configLoaderPanel.name = addonName
configLoaderPanel:Hide()
configLoaderPanel:SetScript('OnShow', function() return addon:OpenConfiguration() end)
InterfaceOptions_AddCategory(configLoaderPanel)

-- The loading handler
function addon:OpenConfiguration(args)
	local loaded, why

	-- Replace the handler to avoid infinite recursive loops
	addon.OpenConfiguration = function()
		if not loaded then
			print(format('|cffff0000[%s] %s: %s|r', addonName, L["Could not load configuration panel"], _G["ADDON_"..why]))
		end
	end

	-- Remove the fake configuration panel
	configLoaderPanel:SetScript('OnShow', nil)
	configLoaderPanel:Hide()
	for i, panel in ipairs(INTERFACEOPTIONS_ADDONCATEGORIES) do
		if panel == configLoaderPanel then
			tremove(INTERFACEOPTIONS_ADDONCATEGORIES, i)
			break
		end
	end

	-- Load the configuration addon
	loaded, why = LoadAddOn(addonName..'_Config')
	if loaded then
		CloseAllWindows()
		CloseAllWindows()
		InterfaceOptionsFrame_OpenToCategory(addonName)
	end

	-- Forward the arguments
	return addon:OpenConfiguration(args)
end

-- The slash command
_G.SLASH_ADIBUTTONAURAS1 = "/adibuttonauras"
_G.SLASH_ADIBUTTONAURAS2 = "/aba"
_G.SlashCmdList["ADIBUTTONAURAS"] = function(args) return addon:OpenConfiguration(args) end

-- Used to register the actual configuration GUI, with access to internals
function addon.api:CreateConfig(func)
	return func(addonName, addon)
end

------------------------------------------------------------------------------
-- Group roster update
------------------------------------------------------------------------------

local GROUP_CHANGED = addonName..'_Group_Changed'
local groupPrefix, groupSize = "", 0
local groupUnits = {}
addon.GROUP_CHANGED, addon.groupUnits = GROUP_CHANGED, groupUnits

function addon:GROUP_ROSTER_UPDATE(event)
	local prefix, start, size = "", 1, 0
	if IsInRaid() then
		prefix, size = "raid", 40
	elseif IsInGroup() then
		prefix, start, size = "party", 0, 4
	else
		start = 0
	end
	if prefix ~= groupPrefix then
		wipe(groupUnits)
	end
	local changed = false
	for i = start, size do
		local unit, petUnit
		if i == 0 then
			unit, petUnit = "player", "pet"
		else
			unit, petUnit = prefix..i, prefix..'pet'..i
		end
		local guid, petGUID = UnitGUID(unit), UnitGUID(petUnit)
		if groupUnits[unit] ~= guid or groupUnits[petUnit] ~= petGUID then
			groupUnits[unit], groupUnits[petUnit] = guid, petGUID
			changed = true
		end
	end
	if changed then
		addon.Debug('Group', addon.getkeys(groupUnits))
		return self:SendMessage(GROUP_CHANGED)
	end
end

function addon:UNIT_PET(event, unit)
	local petUnit
	if unit == "player" then
		petUnit = "pet"
	elseif groupUnits[unit] then
		petUnit = gsub(unit.."pet", "(%d+)pet", "pet%1")
	else
		return
	end
	local guid = UnitGUID(petUnit)
	if groupUnits[petUnit] ~= guid then
		groupUnits[petUnit] = guid
		return self:SendMessage(GROUP_CHANGED)
	end
end

addon:DeclareMessage(
	GROUP_CHANGED,
	function()
		addon:RegisterEvent('GROUP_ROSTER_UPDATE')
		addon:RegisterEvent('UNIT_PET')
		addon:GROUP_ROSTER_UPDATE('OnUse')
	end,
	function()
		addon:UnregisterEvent('GROUP_ROSTER_UPDATE')
		addon:UnregisterEvent('UNIT_PET')
	end
)

------------------------------------------------------------------------------
-- Mouseover watching
------------------------------------------------------------------------------

local MOUSEOVER_CHANGED = addonName..'_Mouseover_Changed'
local MOUSEOVER_TICK = addonName..'_Mouseover_Tick'
local unitList = { "player", "pet", "target", "focus" }

addon.MOUSEOVER_CHANGED, addon.MOUSEOVER_TICK, addon.unitList = MOUSEOVER_CHANGED, MOUSEOVER_TICK, unitList

for i = 1,4 do tinsert(unitList, "party"..i) end
for i = 1,40 do tinsert(unitList, "raid"..i) end

local mouseoverUnit, mouseoverGUID = 'mouseover'

local function ResolveMouseover()
	if UnitExists('mouseover') then
		for i, unit in pairs(unitList) do
			if UnitIsUnit(unit, "mouseover") then
				return unit
			end
		end
		return 'mouseover'
	end
end

local mouseoverFrame = CreateFrame("Frame")
mouseoverFrame:Hide()

function mouseoverFrame:Update(event)
	local unit = ResolveMouseover()
	mouseoverGUID = UnitGUID('mouseover')
	if mouseoverUnit ~= unit then
		mouseoverUnit = unit
		self:SetShown(unit == 'mouseover')
		addon.Debug('Mouseover', event, 'Changed:', unit)
		return addon:SendMessage(MOUSEOVER_CHANGED, 'mouseover', unit)
	elseif unit == 'mouseover' then
		addon.Debug('Mouseover', event, 'Tick')
		return addon:SendMessage(MOUSEOVER_TICK)
	end
end

local timer = 0
function mouseoverFrame:OnUpdate(elapsed)
	timer = timer - elapsed
	if timer <= 0 or UnitGUID('mouseover') ~= mouseoverGUID then
		timer = 0.5
		return self:Update('OnUpdate')
	end
end

mouseoverFrame:SetScript('OnEvent', mouseoverFrame.Update)
mouseoverFrame:SetScript('OnUpdate', mouseoverFrame.OnUpdate)

function addon:GetMouseoverUnit()
	return mouseoverUnit
end

do
	local mouseoverUsed = 0
	local function OnUsed(msg)
		if mouseoverUsed == 0 then
			mouseoverFrame:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
			addon.Debug('Mouseover', 'Started listening to UPDATE_MOUSEOVER_UNIT')
			mouseoverFrame:Update('OnUsed')
		end
		mouseoverUsed = mouseoverUsed + 1
	end
	local function OnUnused(msg)
		mouseoverUsed = mouseoverUsed - 1
		if mouseoverUsed == 0 then
			mouseoverFrame:UnregisterEvent('UPDATE_MOUSEOVER_UNIT')
			mouseoverFrame:Hide()
			addon.Debug('Mouseover', 'Stopped listening to UPDATE_MOUSEOVER_UNIT')
		end
	end
	addon:DeclareMessage(MOUSEOVER_CHANGED, OnUsed, OnUnused)
	addon:DeclareMessage(MOUSEOVER_TICK, OnUsed, OnUnused)
end

------------------------------------------------------------------------------
-- "ally" and "enemy" pseudo-units
------------------------------------------------------------------------------

local DYNAMIC_UNIT_CONDITONALS_CHANGED = addonName..'_DynamicUnitConditionals_Changed'
local dynamicUnitConditionals = {}

addon.DYNAMIC_UNIT_CONDITONALS_CHANGED = DYNAMIC_UNIT_CONDITONALS_CHANGED
addon.dynamicUnitConditionals = dynamicUnitConditionals

function addon:UpdateDynamicUnitConditionals()
	local selfCast, focusCast = GetModifiedClick("SELFCAST"), GetModifiedClick("FOCUSCAST")
	local enemy = "[harm]"
	local ally
	if GetCVarBool("autoSelfCast") then
		ally = "[help,nodead][@player]"
	else
		ally = "[help]"
	end
	if focusCast ~= "NONE" then
		enemy = "[@focus,mod:"..focusCast.."]"..enemy
		ally = "[@focus,mod:"..focusCast.."]"..ally
	end
	if selfCast ~= "NONE" then
		ally = "[@player,mod:"..selfCast.."]"..ally
	end
	if dynamicUnitConditionals.enemy ~= enemy or dynamicUnitConditionals.ally ~= ally then
		dynamicUnitConditionals.enemy, dynamicUnitConditionals.ally = enemy, ally
		addon:SendMessage(DYNAMIC_UNIT_CONDITONALS_CHANGED)
	end
end

function addon:CVAR_UPDATE(_, name)
	if name == "autoSelfCast" then
		return self:UpdateDynamicUnitConditionals()
	end
end

addon:DeclareMessage(
	DYNAMIC_UNIT_CONDITONALS_CHANGED,
	function()
		addon:RegisterEvent('CVAR_UPDATE')
		addon:RegisterEvent('VARIABLES_LOADED', 'UpdateDynamicUnitConditionals')
		addon:RegisterEvent('UPDATE_BINDINGS', 'UpdateDynamicUnitConditionals')
		addon:UpdateDynamicUnitConditionals()
	end,
	function()
		addon:UnregisterEvent('CVAR_UPDATE')
		addon:UnregisterEvent('VARIABLES_LOADED')
		addon:UnregisterEvent('UPDATE_BINDINGS')
	end
)
