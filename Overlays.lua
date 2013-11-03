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

local AceEvent = LibStub('AceEvent-3.0')
local LibSpellbook = LibStub('LibSpellbook-1.0')
local AceTimer = LibStub('AceTimer-3.0')

local EMPTY_TABLE = setmetatable({}, { __newindex = function() error(2, "Read only table") end })

local getkeys = addon.getkeys

--------------------------------------------------------------------------------
-- Unit handling
--------------------------------------------------------------------------------

local unitList = { "player", "pet", "target", "focus" }
local unitIdentity = {}
for i = 1,4 do tinsert(unitList, "party"..i) end
for i = 1,40 do tinsert(unitList, "raid"..i) end
for i, unit in ipairs(unitList) do unitIdentity[unit] = unit end

local unitEvents = {
	target = 'PLAYER_TARGET_CHANGED',
	focus = 'PLAYER_FOCUS_CHANGED',
	mouseover = 'UPDATE_MOUSEOVER_UNIT',
	pet = 'UNIT_PET',
}

local unitIdentityMeta = { __index = unitIdentity }

local dynamicUnitConditionals = {}

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
		addon:SendMessage(addonName..'_DynamicUnitConditionals_Changed')
	end
end

function addon:CVAR_UPDATE(_, name)
	if name == "autoSelfCast" then
		return self:UpdateDynamicUnitConditionals()
	end
end

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

local MOUSEOVER_CHANGED = addonName..'_Mouseover_Changed'
local MOUSEOVER_TICK = addonName..'_Mouseover_Tick'

local mouseoverUnit, mouseoverUnitTimer
function addon:UPDATE_MOUSEOVER_UNIT()
	local unit = ResolveMouseover()
	if mouseoverUnit ~= unit then
		self:Debug('mouseover changed:', unit)
		mouseoverUnit = unit
		if unit == 'mouseover' then
			if not mouseoverUnitTimer then
				mouseoverUnitTimer = AceTimer.ScheduleRepeatingTimer(self, 'UPDATE_MOUSEOVER_UNIT', 0.5)
			end
		elseif mouseoverUnitTimer then
			AceTimer.CancelTimer(mouseoverUnitTimer)
			mouseoverUnitTimer = nil
		end
		return self:SendMessage(MOUSEOVER_CHANGED, unit)
	elseif unit == 'mouseover' then
		self:Debug('mouseover tick')
		return self:SendMessage(MOUSEOVER_TICK, unit)
	end
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

local function GetFirstConditionals(line, ...)
	if not line then return end
	local prefix, suffix = strsplit(" ", strtrim(line), 2)
	if prefix and suffix and conditionalPrefixes[strtrim(strlower(prefix))] then
		return suffix
	else
		return GetFirstConditionals(...)
	end
end

local function StripSpells(term, ...)
	if term then
		return strmatch(strtrim(term), "^(%[.+%])") or "[]", StripSpells(...)
	end
end

local conditionalsCache = addon.Memoize(function(index)
	local body = GetMacroBody(index)
	if not body then return false end
	local conditionals = GetFirstConditionals(strsplit("\n", body))
	if not conditionals or strtrim(conditionals) == "" then return false end
	return gsub(
		gsub(
			strjoin(';', StripSpells(strsplit(';', conditionals))),
			"target=",
			"@"
		),
		"mod:",
		"modifier:"
	)
end)

function addon:UPDATE_MACROS()
	wipe(conditionalsCache)
end

local function GetMacroConditionals(index)
	return conditionalsCache[tonumber(index)]
end

--------------------------------------------------------------------------------
-- Action handling
--------------------------------------------------------------------------------

local function GetActionSpell(actionType, actionId)
	-- Resolve macros
	local macroConditionals
	if actionType == "macro" then
		macroConditionals = GetMacroConditionals(actionId)
		actionType, actionId = GetMacroAction(actionId)
	end

	-- Resolve items and companions
	if actionType == "item" then
		local spell = GetItemSpell(actionId)
		return LibSpellbook:Resolve(spell), macroConditionals
	elseif actionType == "spell" or actionType == "companion" then
		return actionId, macroConditionals
	end
end

--------------------------------------------------------------------------------
-- Button overlay prototype
--------------------------------------------------------------------------------

local overlayPrototype = setmetatable({}, { __index = CreateFrame("Frame") })
local overlayMeta = { __index = overlayPrototype }

addon.overlayPrototype = overlayPrototype

overlayPrototype.Debug = addon.Debug

function overlayPrototype:Initialize(button)
	self:Hide()
	self.button = button

	self:SetScript('OnEvent', self.OnEvent)
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)

	self:SetAllPoints(button)

	self:InitializeDisplay()

	self.unitMap = setmetatable({}, unitIdentityMeta)
	self.guids = {}
	self.unitConditionals = {}
	self.units = {}
	self.events = {}
	self.handlers = EMPTY_TABLE

	AceEvent.RegisterMessage(self, addonName..'_RulesUpdated', 'ForceUpdate')
	AceEvent.RegisterMessage(self, addonName..'_DynamicUnitConditionals_Changed', 'ForceUpdate')

	self:Show()
end

function overlayPrototype:OnEvent(event, ...)
	if self:IsVisible() then
		return self[event](self, event, ...)
	end
end

function overlayPrototype:OnShow()
	self:ForceUpdate('OnShow')
end

function overlayPrototype:OnHide()
	self:SetAction('OnHide', nil, nil)
end

function overlayPrototype:ForceUpdate(event)
	self:Debug('ForceUpdate', event)
	if not self:UpdateAction(event) and not self:UpdateDynamicUnits(event) then
		return self:UpdateState(event)
	end
end

function overlayPrototype:UpdateAction(event)
	local actionId, actionType = self:GetAction()
	local spellId, macroConditionals = GetActionSpell(actionId, actionType)
	self:Debug('UpdateAction', event, '|', actionId, actionType, '=>', spellId, macroConditionals)
	return self:SetAction(event, spellId, macroConditionals)
end

function overlayPrototype:SetAction(event, spellId, macroConditionals)
	local conf = spellId and addon.spells[spellId]
	if self.spellId == spellId and self.conf == conf and self.macroConditionals == macroConditionals then return end
	self.spellId, self.conf, self.macroConditionals = spellId, conf, macroConditionals

	local hasDynamicUnits = false
	local units = wipe(self.units)
	local events = wipe(self.events)
	wipe(self.unitConditionals)
	self:UnregisterAllEvents()
	AceEvent.UnregisterMessage(self, MOUSEOVER_CHANGED)
	AceEvent.UnregisterMessage(self, MOUSEOVER_TICK)

	if conf then
		self:Debug('SetAction', event, GetSpellLink(spellId), macroConditionals)
		for event in pairs(conf.events) do
			events[event] = 'ScheduleUpdate'
		end
		for unit in pairs(conf.units) do
			units[unit] = 'UpdateGUID'
		end

		for token, default in pairs(dynamicUnitConditionals) do
			if units[token] then
				local cond = macroConditionals and gsub(macroConditionals , "%[%]", default) or default
				self.unitConditionals[token] = cond
				-- Dynamic always includes target
				units.target = 'UpdateDynamicUnits'
				for unit in cond:gmatch('@(%a+%d*)') do
					units[unit] = 'UpdateDynamicUnits'
				end
				if strmatch(cond, 'mod:') then
					events.MODIFIER_STATE_CHANGED = 'UpdateDynamicUnits'
				end
				hasDynamicUnits = true
			end
		end

		for unit, handler in pairs(units) do
			local event = unitEvents[unit]
			if event and events[event] ~= handler then
				events[event] = handler
			end
		end

		for event, handler in pairs(events) do
			if not self[event] then
				self[event] = event:match('^UNIT_') and self.GenericUnitEvent or self.GenericEvent
			end
			self:RegisterEvent(event)
		end

		self:RegisterEvent('PLAYER_ENTERING_WORLD', 'ForceUpdate')
		if macroConditionals then
			self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
		end

		self.handlers = conf.handlers
	else
		self.handlers = EMPTY_TABLE
	end

	return hasDynamicUnits and self:UpdateDynamicUnits(event) or self:ScheduleUpdate(event)
end

function overlayPrototype:GenericUnitEvent(event, unit)
	if self.units[unit] or unit == self.unitMap.ally or unit == self.unitMap.enemy then
		return self:ScheduleUpdate(event)
	end
end

function overlayPrototype:GenericEvent(event)
	if self.events[event] then
		return self[self.events[event]](self, event)
	end
end

function overlayPrototype:ACTIONBAR_SLOT_CHANGED(event, actionId)
	if actionId == 0 or actionId == self:GetActionId() then
		self:UpdateDynamicUnits(event)
	end
end

function overlayPrototype:UNIT_PET(event, unit)
	if unit == "player" then
		return self:GenericEvent(event)
	end
end

function overlayPrototype:UpdateDynamicUnits(event)
	local updated, watchMouseover = false, false

	for token, conditional in pairs(self.unitConditionals) do
		local _, unit = SecureCmdOptionParse(conditional)
		if not unit or unit == "" then
			unit = "target"
		elseif unit == "mouseover" then
			if mouseoverUnit and UnitIsUnit(mouseoverUnit, unit) then
				unit = mouseoverUnit
			else
				watchMouseover = true
			end
		end
		if self.unitMap[token] ~= unit then
			self.unitMap[token] = unit
			updated = self:UpdateGUID(event, unit) or updated
		end
	end

	if watchMouseover then
		AceEvent.RegisterMessage(self, MOUSEOVER_CHANGED, 'UpdateGUID', 'mouseover')
		AceEvent.RegisterMessage(self, MOUSEOVER_TICK, 'ScheduleUpdate')
	else
		AceEvent.UnregisterMessage(self, MOUSEOVER_CHANGED)
		AceEvent.UnregisterMessage(self, MOUSEOVER_TICK)
	end

	return updated
end

function overlayPrototype:UpdateGUID(event, unit)
	if not unit then return end
	local guid = UnitGUID(unit)
	if self.guids[unit] ~= guid then
		self.guids[unit] = guid
		return self:ScheduleUpdate(event)
	end
end

function overlayPrototype:ScheduleUpdate(event)
	self:SetScript('OnUpdate', self.UpdateState)
	return true
end

local model = {}
function overlayPrototype:UpdateState(event)
	self:SetScript('OnUpdate', nil)

	local unitMap = self.unitMap
	model.count, model.expiration, model.highlight  = 0, 0, nil

	for i, handler in ipairs(self.handlers) do
		handler(unitMap, model)
	end

	--self:Debug("Scan =>", model.highlight, model.count, model.expiration)
	self:SetCount(model.count)
	self:SetExpiration(model.expiration)
	self:SetHighlight(model.highlight)

	return true
end

--------------------------------------------------------------------------------
-- Blizzard button support
--------------------------------------------------------------------------------

local blizzardSupportPrototype = setmetatable({}, overlayMeta)
local blizzardSupportMeta = { __index = blizzardSupportPrototype }

function blizzardSupportPrototype:GetAction()
	if self.button.action then
		return GetActionInfo(self.button.action)
	end
end

function blizzardSupportPrototype:GetActionId()
	return self.button.action
end

--------------------------------------------------------------------------------
-- LibActionButton support
--------------------------------------------------------------------------------

local labSupportPrototype = setmetatable({}, overlayMeta)
local labSupportMeta = { __index = labSupportPrototype }

function labSupportPrototype:GetAction()
	return self.button:GetAction()
end

function labSupportPrototype:GetActionId()
	-- NOOP
end

--------------------------------------------------------------------------------
-- Overlay spawning
--------------------------------------------------------------------------------

local overlays = addon.Memoize(function(button)
	if button and button.IsObjectType and button:IsObjectType("Button") then
		local name = button:GetName()
		local overlay = setmetatable(
			CreateFrame("Frame", name and (name..'Overlay'), button),
			button.__LAB_Version and labSupportMeta or blizzardSupportMeta
		)
		overlay:Initialize(button)
		return overlay
	else
		return false
	end
end)

function addon:GetOverlay(button)
	return button and overlays[button]
end

function addon:ScanButtons(prefix, count)
	for i = 1, count or 12 do
		local button = _G[prefix..i]
		if button then
			local dummy = overlays[button]
		end
	end
end
