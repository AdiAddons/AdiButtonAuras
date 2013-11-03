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
	for i, unit in pairs(unitList) do
		if UnitIsUnit(unit, "mouseover") then
			return unit
		end
	end
	return 'mouseover'
end

local mouseoverUnit
function addon:UPDATE_MOUSEOVER_UNIT()
	local unit = ResolveMouseover()
	if mouseoverUnit ~= unit then
		self:Debug('mouseover =', unit)
		mouseoverUnit = unit
		addon:SendMessage(addonName..'_Mouseover_Changed', unit)
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

	self.units, self.events, self.handlers = EMPTY_TABLE, EMPTY_TABLE, EMPTY_TABLE

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

--------------------------------------------------------------------------------
-- Blizzard button support
--------------------------------------------------------------------------------

local blizzardSupportPrototype = setmetatable({}, overlayMeta)
local blizzardSupportMeta = { __index = blizzardSupportPrototype }

function blizzardSupportPrototype:GetAction()
	return self.button.action and GetActionInfo(self.button.action)
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
