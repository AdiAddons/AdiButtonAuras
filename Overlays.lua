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

local LibAdiEvent = LibStub('LibAdiEvent-1.0')
local LibSpellbook = LibStub('LibSpellbook-1.0')
local AceTimer = LibStub('AceTimer-3.0')

local EMPTY_TABLE = setmetatable({}, { __newindex = function() error(2, "Read only table") end })

local getkeys = addon.getkeys

local overlayPrototype = setmetatable({}, { __index = CreateFrame("Frame") })
local overlayMeta = { __index = overlayPrototype }

addon.overlayPrototype = overlayPrototype

overlayPrototype.Debug = addon.Debug

local function GetBlizzardButtonAction(overlay)
	if overlay.button.action then
		return GetActionInfo(overlay.button.action)
	end
end

local function GetBlizzardButtonActionId(overlay)
	return overlay.button.action
end

local function GetLABAction(overlay)
	return overlay.button:GetAction()
end

function overlayPrototype:Initialize(button)
	self:Hide()
	self.button = button

	LibAdiEvent.Embed(self)

	if button.__LAB_Version then
		self.GetAction = GetLABAction
		self.GetActionId = function() end
	else
		self.GetAction = GetBlizzardButtonAction
		self.GetActionId = GetBlizzardButtonActionId
	end

	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)

	self:SetAllPoints(button)

	self:InitializeDisplay()

	self.units, self.events, self.handlers = EMPTY_TABLE, EMPTY_TABLE, EMPTY_TABLE

	self:Show()
end

function overlayPrototype:OnShow()
	self:FullUpdate('OnShow')
end

function overlayPrototype:OnHide()
	self:UnregisterAllEvents()
	if self.mouseoverTimerId then
		AceTimer.CancelTimer(self, self.mouseoverTimerId)
		self.mouseoverTimerId = nil
	end
	self.units, self.events, self.handlers = EMPTY_TABLE, EMPTY_TABLE, EMPTY_TABLE
	self.spellId, self.macroConditionals, self.unit, self.guid = nil, nil, nil, nil
end

function overlayPrototype:FullUpdate(event)
	self:UpdateAction(event)
end

--------------------------------------------------------------------------------
-- Macro handling
--------------------------------------------------------------------------------

local function GetMacroAction(macroId)
	local macroSpell, _, macroSpellId = GetMacroSpell(macroId)
	if macroSpell or macroSpellId then
		return "spell", macroSpellId or LibSpellbook:Resolve(macroSpell)
	else
		local _, itemLink = GetMacroItem(actionId)
		local itemId = itemLink and tonumber(itemLink:match('item:(%d+):'))
		if itemId then
			return "item", itemId
		end
	end
end

local conditionalPrefixes = {
	['#showtooltip'] = true,
	['#show'] = true,
}
for _, cmd in pairs({"CAST", "CASTRANDOM", "CASTSEQUENCE", "USE", "USERANDOM"}) do
	for i = 1, 16 do
		local alias = _G["SLASH_"..cmd..i]
		if alias then
			conditionalPrefixes[strlower(alias)] = true
		else
			break
		end
	end
end

local function GetFirstConditionals0(line, ...)
	if not line then return end
	local prefix, suffix = strsplit(" ", strtrim(line), 2)
	if prefix and suffix and conditionalPrefixes[strtrim(strlower(prefix))] then
		return suffix
	else
		return GetFirstConditionals0(...)
	end
end

local function StripSpells(term, ...)
	if term then
		return strmatch(strtrim(term), "^(%[.+%])") or "[]", StripSpells(...)
	end
end

local conditionalsCache = addon.Memoize(function(index)
	local body = GetMacroBody(index)
	local conditionals = body and GetFirstConditionals(strsplit("\n", body)) or false
	return conditionals and strjoin(';', StripSpells(strsplit(';', options)))
end)
LibAdiEvent:RegisterEvent('UPDATE_MACROS', function() return wipe(conditionalsCache) end)

local function GetMacroConditionals(index)
	return conditionalsCache[tonumber(index)]
end

--------------------------------------------------------------------------------
-- Unit handling
--------------------------------------------------------------------------------

local unitList = { "player", "pet", "target", "focus" }
for i = 1,4 do tinsert(unitList, "party"..i) end
for i = 1,40 do tinsert(unitList, "raid"..i) end

local dynamicUnitConditionals = { default = "[]" }

local function ApplyModifiedClick(base)
	local selfCast, focusCast = GetModifiedClick("SELFCAST"), GetModifiedClick("FOCUSCAST")
	if focusCast ~= "NONE" then
		base = "[@focus,mod:"..focusCast.."]"..base
	end
	if selfCast ~= "NONE" then
		base = "[@player,mod:"..selfCast.."]"..base
	end
	return base
end

local function UpdateDynamicUnitConditionals()
	local enemy = ApplyModifiedClick("[harm]")
	local ally = ApplyModifiedClick(GetCVarBool("autoSelfCast") and "[help,nodead][@player]" or "[help]")
	if dynamicUnitConditionals.enemy ~= enemy or dynamicUnitConditionals.ally ~= ally then
		dynamicUnitConditionals.enemy, dynamicUnitConditionals.ally = enemy, ally
	end
end

LibAdiEvent:RegisterEvent('VARIABLES_LOADED', UpdateDynamicUnitConditionals)
LibAdiEvent:RegisterEvent('CVAR_UPDATE', function(_, _, name)
	if name == "autoSelfCast" then
		return UpdateDynamicUnitConditionals()
	end
end)
LibAdiEvent:RegisterEvent('UPDATE_BINDINGS', UpdateDynamicUnitConditionals)
UpdateDynamicUnitConditionals()

local mouseoverUnit
LibAdiEvent:RegisterEvent('UPDATE_MOUSEOVER_UNIT', function()
	if UnitExists('mouseover') then
		for i, unit in pairs(unitList) do
			if UnitIsUnit(unit, "mouseover") then
				addon:Debug('Using', unit, 'for mouseover')
				mouseoverUnit = unit
				return
			end
		end
	end
	addon:Debug('Using mouseover as is')
	mouseoverUnit = nil
end)

local function GetActionSpell(actionType, actionId)
	local isMacro = (actionType == "macro")
	local macroConditionals

	-- Resolve macros
	if isMacro then
		macroConditionals, actionType, actionId = GetMacroConditionals(actionId), GetMacroAction(actionId)
	end

	-- Resolve items and companions
	if actionType == "item" then
		local spell = GetItemSpell(actionId)
		return LibSpellbook:Resolve(spell), macroConditionals, isMacro
	elseif actionType == "spell" or actionType == "companion" then
		return actionId, macroConditionals, isMacro
	end
end

local function ResolveTargeting(spellId, units, macroConditionals)
	local spellName = GetSpellInfo(spellId)
	local spellType
	if units.ally or (units.default and IsHelpfulSpell(spellName)) then
		spellType = "helpful"
	elseif units.enemy or (units.default and IsHarmfulSpell(spellName)) then
		spellType = "harmful"
	elseif units.default then
		spellType = "unknown"
	else
		return
	end
	return macroConditionals and gsub(macroConditionals , "%[%]", dynamicUnitConditionals[spellType]) or dynamicUnitConditionals[spellType]
end

function overlayPrototype:UpdateAction(event)
	local spellId, macroConditionals, isMacro = GetActionSpell(self:GetAction())
	local conf = spellId and addon.spells[spellId]
	local macroConditionals = conf and ResolveTargeting(spellId, conf.units, macroConditionals)

	if self.spellId ~= spellId or self.spellConf ~= conf or self.macroConditionals ~= macroConditionals then
		self.spellId, self.spellConf, self.macroConditionals = spellId, conf, macroConditionals

		if not conf then
			isMacro = false
		end

		self.units = conf and conf.units or EMPTY_TABLE
		self.handlers = conf and conf.handlers or EMPTY_TABLE

		self:SetEventRegistered(conf, 'PLAYER_ENTERING_WORLD', 'ScheduleScan')
		self:SetEventRegistered(self.units.target, 'PLAYER_TARGET_CHANGED', 'ScheduleScan')
		self:SetEventRegistered(self.units.focus, 'PLAYER_FOCUS_CHANGED', 'ScheduleScan')
		self:SetEventRegistered(self.units.mouseover, 'UPDATE_MOUSEOVER_UNIT', 'ScheduleScan')
		self:SetEventRegistered(self.units.pet, 'UNIT_PET', 'ScheduleScan')

		local events = conf and conf.events or EMPTY_TABLE
		if self.events ~= events then
			for event in pairs(self.events) do
				if not events[event] then
					self:UnregisterEvent(event, 'ScheduleScan')
				end
			end
			for event in pairs(events) do
				if not self.events[event] then
					self:RegisterEvent(event, 'ScheduleScan')
				end
			end
			self.events = events
		end

		if conf then
			self:Debug('UpdateAction', 'spell=', GetSpellInfo(spellId), 'macroConditionals=', macroConditionals, 'units=', getkeys(self.units), 'events=', getkeys(self.events), #self.handlers, 'handlers')
		end

		self.smartTargeting = macroConditionals and (conf.units.default or conf.units.ally or conf.units.enemy or isMacro)
		if self.smartTargeting then
			self:RegisterEvent('PLAYER_TARGET_CHANGED', 'UpdateTarget')
			local atTargets = gsub(gsub(macroConditionals, 'target=', '@'), "modifier:", "mod:")
			self:SetEventRegistered(strmatch(atTargets, '@focus'), 'PLAYER_FOCUS_CHANGED', 'UpdateTarget')
			self:SetEventRegistered(strmatch(atTargets, '@mouseover'), 'UPDATE_MOUSEOVER_UNIT', 'UpdateTarget')
			self:SetEventRegistered(strmatch(atTargets, '@pet'), 'UNIT_PET', 'UpdateTarget')
			self:SetEventRegistered(strmatch(macroConditionals, 'mod:'), 'MODIFIER_STATE_CHANGED', 'UpdateTarget')
			self:SetEventRegistered(isMacro, 'ACTIONBAR_SLOT_CHANGED', 'UpdateTarget')

			self:UpdateTarget(event)
		else
			self:UnregisterEvent('PLAYER_TARGET_CHANGED', 'UpdateTarget')
			self:UnregisterEvent('PLAYER_FOCUS_CHANGED', 'UpdateTarget')
			self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT', 'UpdateTarget')
			self:UnregisterEvent('UNIT_PET', 'UpdateTarget')
			self:UnregisterEvent('MODIFIER_STATE_CHANGED', 'UpdateTarget')
			self:UnregisterEvent('ACTIONBAR_SLOT_CHANGED', 'UpdateTarget')

			self.unit, self.guid = nil, nil
			self:Scan(event)
		end
	end
end

function overlayPrototype:SetEventRegistered(enabled, event, handler)
	if enabled then
		self:RegisterEvent(event, handler)
	else
		self:UnregisterEvent(event, handler)
	end
end

function overlayPrototype:UpdateTarget(event, arg)
	if event == 'UNIT_PET' and arg ~= 'player' then return end
	if event == 'ACTIONBAR_SLOT_CHANGED' and arg ~= self:GetActionId() then return end
	local _, target = SecureCmdOptionParse(self.macroConditionals)
	local unit = (target and target ~= "") and target or "target"
	if unit == "mouseover" and mouseoverUnit and UnitIsUnit(mouseoverUnit, unit) then
		unit = mouseoverUnit
	end
	if self.unit ~= unit then
		self.unit = unit
		if unit == "mouseover" and UnitExists("mouseover") then
			if not self.mouseoverTimerId then
				-- Rescan evey 0.5 seconds since we won't get any event
				self.mouseoverTimerId = AceTimer.ScheduleRepeatingTimer(self, "Scan", 0.5)
				self:Debug('Scheduled repeating scans')
			end
		elseif self.mouseoverTimerId then
			self:Debug('Cancelled repeating scans')
			AceTimer.CancelTimer(self, self.mouseoverTimerId)
			self.mouseoverTimerId = nil
		end
	end
	local guid = unit and UnitGUID(unit)
	if self.guid ~= guid then
		self.guid = guid
		self:Scan(event)
	end
end

function overlayPrototype:ScheduleScan(event, unit)
	if not unit or (self.smartTargeting and unit == self.unit) or self.units[unit] and not self.mouseoverTimerId then
		self:SetScript('OnUpdate', self.ScheduledScan)
	end
end

function overlayPrototype:ScheduledScan(event, elapsed)
	self:SetScript('OnUpdate', nil)
	return self:Scan('OnUpdate')
end

local model = {}
function overlayPrototype:Scan(event)
	--self:Debug('Scan', event, self.spellId, self.unit)

	local unit = self.unit
	model.count, model.expiration, model.highlight  = 0, 0, nil

	if unit or not self.smartTargeting then
		for i, handler in ipairs(self.handlers) do
			local value = handler(unit, model)
			if value then
				self:Debug('Scan:', value)
			end
		end
	end

	--self:Debug("Scan =>", model.highlight, model.count, model.expiration)
	self:SetCount(model.count)
	self:SetExpiration(model.expiration)
	self:SetHighlight(model.highlight)
end

local overlays = addon.Memoize(function(button)
	if button and button.IsObjectType and button:IsObjectType("Button") then
		local name = button:GetName()
		local overlay = setmetatable(CreateFrame("Frame", name and (name..'Overlay'), button), overlayMeta)
		overlay:Initialize(button)
		return overlay
	else
		return false
	end
end)

function addon:UpdateAllOverlays(event)
	for button, overlay in pairs(overlays) do
		overlay:FullUpdate(event)
	end
end

do

	local function ScanGlobalButtons(prefix, count)
		for i = 1, count or 12 do
			local button = _G[prefix..i]
			if button then
				local dummy = overlays[button]
			end
		end
	end

	local function IsLoadable(addon)
		local enabled, loadable = select(4, GetAddOnInfo(addon))
		return enabled and loadable and true or nil
	end

	local toWatch = {
		[addonName] = true,
		Dominos = IsLoadable('Dominos'),
		Bartender4 = IsLoadable('Bartender4'),
	}

	local function ADDON_LOADED(_, event, name)
		if name == addonName then
			toWatch[addonName] = nil
			addon:Debug(name, 'loaded')
			ScanGlobalButtons("ActionButton", 12)
			ScanGlobalButtons("BonusActionButton", 12)
			ScanGlobalButtons("MultiBarRightButton", 12)
			ScanGlobalButtons("MultiBarLeftButton", 12)
			ScanGlobalButtons("MultiBarBottomRightButton", 12)
			ScanGlobalButtons("MultiBarBottomLeftButton", 12)
			hooksecurefunc('ActionButton_Update', function(button) return overlays[button]:FullUpdate('ActionButton_Update') end)
		end
		if toWatch.Dominos and (name == 'Dominos' or IsAddOnLoaded('Dominos')) then
			addon:Debug('Dominos loaded')
			toWatch.Dominos = nil
			ScanGlobalButtons("DominosActionButton", 120)
		end
		if toWatch.Bartender4 and (name == 'Bartender4' or IsAddOnLoaded('Bartender4')) then
			addon:Debug('Bartender4 loaded')
			toWatch.Bartender4 = nil
			ScanGlobalButtons("BT4Button", 120)
		end
		if not next(toWatch) then
			addon:Debug('Button loading done')
			LibAdiEvent:UnregisterEvent('ADDON_LOADED', ADDON_LOADED)
			toWatch, ADDON_LOADED, IsLoadable, ScanGlobalButtons = nil, nil, nil, nil
		end
	end

	LibAdiEvent:RegisterEvent('ADDON_LOADED', ADDON_LOADED)

end

