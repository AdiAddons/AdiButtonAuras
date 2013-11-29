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

local mixins = {}
-- Event dispatching using CallbackHandler-1.0
local events = LibStub('CallbackHandler-1.0'):New(mixins, 'RegisterEvent', 'UnregisterEvent', 'UnregisterAllEvents')
local frame = CreateFrame("Frame")
frame:SetScript('OnEvent', function(_, ...) return events:Fire(...) end)
function events:OnUsed(_, event) return frame:RegisterEvent(event) end
function events:OnUnused(_, event) return frame:UnregisterEvent(event) end

-- Messaging using CallbackHandler-1.0
local bus = LibStub('CallbackHandler-1.0'):New(mixins, 'RegisterMessage', 'UnregisterMessage', 'UnregisterAllMessages')
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

for n,m in pairs(mixins) do addon[n] = m end

------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

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

function addon:ADDON_LOADED(event, name)
	if toWatch.Dominos and (name == 'Dominos' or IsAddOnLoaded('Dominos')) then
		self:Debug('Dominos loaded')
		toWatch.Dominos = nil
		self:ScanButtons("DominosActionButton", 120)
	end
	if toWatch["LibActionButton-1.0"] and LibStub('LibActionButton-1.0', true) then
		self:Debug('Found LibActionButton-1.0')
		toWatch["LibActionButton-1.0"] = nil
		local lab = LibStub('LibActionButton-1.0')
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

		self:RegisterEvent('CVAR_UPDATE')
		self:RegisterEvent('UPDATE_MACROS')
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

--------------------------------------------------------------------------------
-- Group roster update
--------------------------------------------------------------------------------

local GROUP_CHANGED = addonName..'_Mouseover_Tick'
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

--------------------------------------------------------------------------------
-- Mouseover watching
--------------------------------------------------------------------------------

local AceTimer = LibStub('AceTimer-3.0')

local MOUSEOVER_CHANGED = addonName..'_Mouseover_Changed'
local MOUSEOVER_TICK = addonName..'_Mouseover_Tick'
local unitList = { "player", "pet", "target", "focus" }

addon.MOUSEOVER_CHANGED, addon.MOUSEOVER_TICK, addon.unitList = MOUSEOVER_CHANGED, MOUSEOVER_TICK, unitList

for i = 1,4 do tinsert(unitList, "party"..i) end
for i = 1,40 do tinsert(unitList, "raid"..i) end

local mouseoverUnit, mouseoverUnitTimer

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

function addon:UPDATE_MOUSEOVER_UNIT()
	local unit = ResolveMouseover()
	if mouseoverUnit ~= unit then
		mouseoverUnit = unit
		if unit == 'mouseover' then
			if not mouseoverUnitTimer then
				mouseoverUnitTimer = AceTimer.ScheduleRepeatingTimer(self, 'UPDATE_MOUSEOVER_UNIT', 0.5)
			end
		elseif mouseoverUnitTimer then
			AceTimer:CancelTimer(mouseoverUnitTimer)
			mouseoverUnitTimer = nil
		end
		return self:SendMessage(MOUSEOVER_CHANGED, unit)
	elseif unit == 'mouseover' then
		return self:SendMessage(MOUSEOVER_TICK, unit)
	end
end

function addon:GetMouseoverUnit()
	return mouseoverUnit
end

addon:DeclareMessage(
	MOUSEOVER_CHANGED,
	function()
		addon:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
		addon:UPDATE_MOUSEOVER_UNIT()
	end,
	function()
		addon:UnregisterEvent('UPDATE_MOUSEOVER_UNIT')
	end
)

--------------------------------------------------------------------------------
-- "ally" and "enemy" pseudo-units
--------------------------------------------------------------------------------

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
