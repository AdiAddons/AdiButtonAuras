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

local LibSpellbook = addon.GetLib('LibSpellbook-1.0')

local MOUSEOVER_CHANGED, MOUSEOVER_TICK, GROUP_CHANGED = addon.MOUSEOVER_CHANGED, addon.MOUSEOVER_TICK, addon.GROUP_CHANGED

------------------------------------------------------------------------------
-- Unit handling
------------------------------------------------------------------------------

local unitEvents = {
	target = 'PLAYER_TARGET_CHANGED',
	focus = 'PLAYER_FOCUS_CHANGED',
	mouseover = 'UPDATE_MOUSEOVER_UNIT',
	pet = 'UNIT_PET',
}

local unitIdentity = { group = addon.groupUnits }
for i, unit in ipairs(addon.unitList) do unitIdentity[unit] = unit end
local unitIdentityMeta = { __index = unitIdentity }

------------------------------------------------------------------------------
-- Macro handling
------------------------------------------------------------------------------

local function GetMacroAction(macroId)
	local macroSpell, _, macroSpellId = GetMacroSpell(macroId)
	if macroSpell or macroSpellId then
		return "spell", macroSpellId or LibSpellbook:Resolve(macroSpell)
	else
		local _, itemLink = GetMacroItem(macroId)
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

------------------------------------------------------------------------------
-- Action handling
------------------------------------------------------------------------------

local function GetActionSpell(actionType, actionId)
	-- Resolve macros
	local macroConditionals
	if actionType == "macro" then
		macroConditionals = GetMacroConditionals(actionId)
		actionType, actionId = GetMacroAction(actionId)
	end

	-- Resolve items and companions
	if actionType == "item" then
		return "item", actionId, macroConditionals
	elseif actionType == "spell" or actionType == "companion" then
		return "spell", actionId, macroConditionals
	end
end

------------------------------------------------------------------------------
-- Button overlay prototype
------------------------------------------------------------------------------

local overlayPrototype = setmetatable({
	Debug                 = addon.Debug,
	RegisterMessage       = addon.RegisterMessage,
	UnregisterMessage     = addon.UnregisterMessage,
	UnregisterAllMessages = addon.UnregisterAllMessages,
	SendMessage           = addon.SendMessage,
}, { __index = CreateFrame("Frame") })
local overlayMeta = { __index = overlayPrototype }

addon.overlayPrototype = overlayPrototype

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
	self.handlers = nil

	self:RegisterMessage(addonName..'_RulesUpdated', 'ForceUpdate')
	self:RegisterMessage(addon.DYNAMIC_UNIT_CONDITONALS_CHANGED, 'ForceUpdate')
	self:RegisterMessage(addon.CONFIG_CHANGED, 'OnConfigChanged')

	self:Show()
end

function overlayPrototype:OnEvent(event, ...)
	if self:IsVisible() then
		return assert(self[event], "No event handler for "..event)(self, event, ...)
	end
end

function overlayPrototype:OnShow()
	self:ForceUpdate('OnShow')
end

function overlayPrototype:OnHide()
	self:SetAction('OnHide')
end

function overlayPrototype:OnConfigChanged(event)
	self:ForceUpdate(event)
	self:UpdateDisplay(event)
end

function overlayPrototype:ForceUpdate(event)
	self:Debug('ForceUpdate', event)
	if not self:UpdateAction(event) and not self:UpdateDynamicUnits(event) then
		return self:UpdateState(event)
	end
end
overlayPrototype.PLAYER_ENTERING_WORLD = overlayPrototype.ForceUpdate

function overlayPrototype:UpdateAction(event)
	local actionId, actionType = self:GetAction()
	local actualType, actualId, macroConditionals = GetActionSpell(actionId, actionType)
	self:Debug('UpdateAction', event, '|', actionId, actionType, '=>', actualId, macroConditionals)
	return self:SetAction(event, actualType, actualId, macroConditionals)
end

function overlayPrototype:SetAction(event, actionType, actionId, macroConditionals)
	local conf, enabled, spellId = addon:GetActionConfiguration(actionType, actionId)
	if not enabled then
		conf = nil
	end

	if self.spellId == spellId and self.conf == conf and self.macroConditionals == macroConditionals then return end
	self.spellId, self.conf, self.macroConditionals = spellId, conf, macroConditionals

	local hasDynamicUnits = false
	local units = wipe(self.units)
	local events = wipe(self.events)
	wipe(self.unitConditionals)
	self:UnregisterAllEvents()
	self:UnregisterMessage(MOUSEOVER_CHANGED)
	self:UnregisterMessage(MOUSEOVER_TICK)
	self:UnregisterMessage(GROUP_CHANGED)

	if conf then
		self:Debug('SetAction', event, GetSpellLink(spellId), macroConditionals)
		for event in pairs(conf.events) do
			events[event] = 'ScheduleUpdate'
		end
		for unit in pairs(conf.units) do
			units[unit] = 'UpdateGUID'
		end

		for token, default in pairs(addon.dynamicUnitConditionals) do
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

		if units.group then
			self:RegisterMessage(GROUP_CHANGED, 'ScheduleUpdate')
		end

		for unit, handler in pairs(units) do
			local event = unitEvents[unit]
			if event and events[event] ~= handler then
				self:Debug('Event', event, '=>', handler)
				events[event] = handler
			end
		end

		for event, handler in pairs(events) do
			if not self[event] then
				self[event] = event:match('^UNIT_') and self.GenericUnitEvent or self.GenericEvent
			end
			self:RegisterEvent(event)
		end

		self:RegisterEvent('PLAYER_ENTERING_WORLD')
		self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
		self:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')

		self.handlers = conf.handlers
	else
		self.handlers = nil

	end

	return hasDynamicUnits and self:UpdateDynamicUnits(event) or self:ScheduleUpdate(event)
end

function overlayPrototype:GenericUnitEvent(event, unit)
	if self.units[unit] or unit == self.unitMap.ally or unit == self.unitMap.enemy or (self.units.group and self.unitMap.group[unit]) then
		return self:ScheduleUpdate(event)
	end
end

function overlayPrototype:GenericEvent(event, unit)
	if self.events[event] then
		return self[self.events[event]](self, event, unit)
	end
end

function overlayPrototype:ACTIONBAR_SLOT_CHANGED(event, actionId)
	if actionId == 0 or actionId == self:GetActionId() then
		self:UpdateDynamicUnits(event)
	end
end

function overlayPrototype:UNIT_PET(event, unit)
	if unit == "player" then
		return self:GenericEvent(event, "pet")
	end
end

function overlayPrototype:PLAYER_TARGET_CHANGED(event)
	return self:GenericEvent(event, "target")
end

function overlayPrototype:PLAYER_FOCUS_CHANGED(event)
	return self:GenericEvent(event, "focus")
end

function overlayPrototype:ACTIONBAR_UPDATE_COOLDOWN(event)
	local start, duration = self:GetActionCooldown()
	local inCooldown = start and duration and start > 0 and duration > 2 or false
	addon.Debug('Cooldown', self, 'start=', start, 'duration=', duration, 'inCooldown=', inCooldown)
	if self.inCooldown ~= inCooldown then
		self.inCooldown = inCooldown
		self:ApplyHighlight()
	end
end

function overlayPrototype:UpdateDynamicUnits(event, unit)
	local updated, watchMouseover = false, false

	updated = self:UpdateGUID(event, unit) or updated

	for token, conditional in pairs(self.unitConditionals) do
		local _, unit = SecureCmdOptionParse(conditional)
		if not unit or unit == "" then
			unit = "target"
		elseif unit == "mouseover" then
			local mouseoverUnit = addon:GetMouseoverUnit()
			if mouseoverUnit and UnitIsUnit(mouseoverUnit, unit) then
				unit = mouseoverUnit
			else
				watchMouseover = true
			end
		end
		self.unitMap[token] = unit
		updated = self:UpdateGUID(event, unit) or updated
	end

	if watchMouseover then
		self:RegisterMessage(MOUSEOVER_CHANGED, 'UpdateGUID')
		self:RegisterMessage(MOUSEOVER_TICK, 'ScheduleUpdate')
	else
		self:UnregisterMessage(MOUSEOVER_CHANGED)
		self:UnregisterMessage(MOUSEOVER_TICK)
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

	model.count, model.expiration, model.highlight  = 0, 0, nil

	if self.handlers then
		local unitMap = self.unitMap
		for i, handler in ipairs(self.handlers) do
			handler(unitMap, model)
		end

		if addon.db.profile.inverted[self.spellId] then
			if model.highlight then
				if model.highlight ~= "flash" then
					model.highlight = nil
				end
			else
				model.highlight = self.units.enemy and "bad" or "good"
			end
		end
	end

	--self:Debug("Scan =>", model.highlight, model.count, model.expiration)
	self:SetCount(model.count)
	self:SetExpiration(model.expiration)
	self:SetHighlight(model.highlight)

	return true
end

function overlayPrototype:GetActionId()
	-- NOOP
end

function overlayPrototype:GetActionCooldown()
	-- NOOP
end

------------------------------------------------------------------------------
-- Blizzard button support
------------------------------------------------------------------------------

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

function blizzardSupportPrototype:GetActionCooldown()
	if self.button.action then
		return GetActionCooldown(self.button.action)
	end
end

------------------------------------------------------------------------------
-- LibActionButton support
------------------------------------------------------------------------------

local labSupportPrototype = setmetatable({}, overlayMeta)
local labSupportMeta = { __index = labSupportPrototype }

function labSupportPrototype:GetAction()
	local actionType, actionId = self.button:GetAction()
	if actionType == "action" then
		return GetActionInfo(actionId)
	else
		return actionType, actionId
	end
end

function labSupportPrototype:GetActionCooldown()
	return self.button:GetCooldown()
end

------------------------------------------------------------------------------
-- Stance buttons
------------------------------------------------------------------------------

local stanceButtonPrototype = setmetatable({}, overlayMeta)
local stanceButtonMeta = { __index = stanceButtonPrototype }

function stanceButtonPrototype:GetAction()
	local _, name = GetShapeshiftFormInfo(self.button:GetID())
	local ids = LibSpellbook:GetAllIds(name)
	if ids then
		return 'spell', (next(ids))
	end
end

function stanceButtonPrototype:GetActionCooldown()
	return GetShapeshiftFormCooldown(self.button:GetID())
end

------------------------------------------------------------------------------
-- Pet action buttons
------------------------------------------------------------------------------

local petActionButtonPrototype = setmetatable({}, overlayMeta)
local petActionButtonMeta = { __index = petActionButtonPrototype }

function petActionButtonPrototype:GetAction()
	local spellId = select(8, GetPetActionInfo(self.button:GetID()))
	if spellId and spellId ~= 0 then
		return 'spell', spellId
	end
end

function petActionButtonPrototype:GetActionCooldown()
	return GetPetActionCooldown(self.button:GetID())
end

------------------------------------------------------------------------------
-- Overlay spawning
------------------------------------------------------------------------------

local overlays = addon.Memoize(function(button)
	if button and button.IsObjectType and button:IsObjectType("Button") then
		local name = button:GetName()
		local meta = blizzardSupportMeta
		if button.__LAB_Version then
			meta = labSupportMeta
		elseif name then
			if strmatch(name, 'StanceButton') then
				meta = stanceButtonMeta
			elseif strmatch(name, 'PetActionButton') or strmatch(name, 'PetButton') then
				meta = petActionButtonMeta
			end
		end
		local overlay = setmetatable(CreateFrame("Frame", name and (name..'Overlay'), button), meta)
		overlay:Initialize(button)
		return overlay
	else
		return false
	end
end)

function addon:GetOverlay(button)
	return button and overlays[button]
end

function addon:IterateOverlays()
	return pairs(overlays)
end

function addon:ScanButtons(prefix, count)
	for i = 1, count or 12 do
		local button = _G[prefix..i]
		if button then
			local dummy = overlays[button]
		end
	end
end
