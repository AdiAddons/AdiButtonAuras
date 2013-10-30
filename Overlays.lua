--[[
LuaAuras - Enhance action buttons using Lua handlers.
Copyright 2013 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

local addonName, addon = ...

local LibAdiEvent = LibStub('LibAdiEvent-1.0')
local LibSpellbook = LibStub('LibSpellbook-1.0')

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
	self.units, self.events, self.handlers = EMPTY_TABLE, EMPTY_TABLE, EMPTY_TABLE
	self.spellId, self.targetCmd, self.unit, self.guid = nil, nil, nil, nil
end

function overlayPrototype:FullUpdate(event)
	self:UpdateAction(event)
end

local function ResolveMacroSpell(macroId)
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

local ResolveMacroTargeting
do
	local optionPrefixes = {
		['#showtooltip'] = true,
		['#show'] = true,
	}
	for _, cmd in pairs({"CAST", "CASTRANDOM", "CASTSEQUENCE", "USE", "USERANDOM"}) do
		for i = 1, 16 do
			local alias = _G["SLASH_"..cmd..i]
			if alias then
				optionPrefixes[strlower(alias)] = true
			else
				break
			end
		end
	end

	local function FindMacroOptions(line, ...)
		if not line then return end
		local prefix, suffix = strsplit(" ", strtrim(line), 2)
		if prefix and suffix and optionPrefixes[strtrim(strlower(prefix))] then
			return suffix
		else
			return FindMacroOptions(...)
		end
	end

	local function GetConds(term, ...)
		if term then
			return strmatch(strtrim(term), "^(%[.+%])") or "[]", GetConds(...)
		end
	end

	local macroOptionsMemo = addon.Memoize(function(index)
		local body = GetMacroBody(index)
		local options = body and FindMacroOptions(strsplit("\n", body)) or false
		return options and strjoin(';', GetConds(strsplit(';', options)))
	end)
	LibAdiEvent:RegisterEvent('UPDATE_MACROS', function() return wipe(macroOptionsMemo) end)

	function ResolveMacroTargeting(index)
		return macroOptionsMemo[tonumber(index)]
	end
end

local defaultTargets = { unknown = "[]" }
do
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

	local function UpdateDefaultTargets()
		defaultTargets.harmful = ApplyModifiedClick("[harm]")
		defaultTargets.helpful = ApplyModifiedClick(GetCVarBool("autoSelfCast") and "[help,nodead][@player]" or "[help]")
	end

	LibAdiEvent:RegisterEvent('VARIABLES_LOADED', UpdateDefaultTargets)
	LibAdiEvent:RegisterEvent('CVAR_UPDATE', UpdateDefaultTargets)
	UpdateDefaultTargets()
end


function overlayPrototype:UpdateAction(event)
	local origType, origId = self:GetAction()
	local actionType, actionId = origType, origId
	local spellId, targetCmd

	-- Resolve macros
	if origType == 'macro' then
		actionType, actionId = ResolveMacroSpell(origId)
		targetCmd = ResolveMacroTargeting(origId)
	end

	-- Resolve items and companions
	if actionType == "item" then
		local spell = GetItemSpell(actionId)
		spellId = LibSpellbook:Resolve(spell)
	elseif actionType == "spell" or actionType == "companion" then
		spellId = actionId
	end

	local conf = spellId and addon.spells[spellId]
	if conf then
		local spellName = GetSpellInfo(spellId)
		local spellType = IsHelpfulSpell(spellName) and "helpful" or IsHarmfulSpell(spellName) and "harmful" or "unknown"
		if targetCmd then
			targetCmd = gsub(targetCmd , "%[%]", defaultTargets[spellType])
		else
			targetCmd = defaultTargets[spellType]
		end
	end

	if self.spellId ~= spellId or self.spellConf ~= conf or self.targetCmd ~= targetCmd then
		self.spellId, self.spellConf, self.targetCmd = spellId, conf, targetCmd

		self.hasConf = not not conf
		self.units = conf and conf.units or EMPTY_TABLE
		self.handlers = conf and conf.handlers or EMPTY_TABLE

		targetCmd = targetCmd or ""

		if self.units.default then
			self:RegisterEvent('PLAYER_TARGET_CHANGED', 'UpdateTarget')
			self:SetEventRegistered(strmatch(targetCmd, '@focus'), 'PLAYER_FOCUS_CHANGED', 'UpdateTarget')
			self:SetEventRegistered(strmatch(targetCmd, '@mouseover'), 'UPDATE_MOUSEOVER_UNIT', 'UpdateTarget')
			self:SetEventRegistered(strmatch(targetCmd, '@pet'), 'UNIT_PET', 'UpdateTarget')
			self:SetEventRegistered(strmatch(targetCmd, 'mod:'), 'MODIFIER_STATE_CHANGED', 'UpdateTarget')
		else
			self:UnregisterEvent('PLAYER_TARGET_CHANGED', 'UpdateTarget')
			self:UnregisterEvent('PLAYER_FOCUS_CHANGED', 'UpdateTarget')
			self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT', 'UpdateTarget')
			self:UnregisterEvent('UNIT_PET', 'UpdateTarget')
			self:UnregisterEvent('MODIFIER_STATE_CHANGED', 'UpdateTarget')
		end
		self:SetEventRegistered(conf and origType == 'macro', 'ACTIONBAR_SLOT_CHANGED', 'UpdateTarget')

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
			self:Debug('UpdateAction', 'spell=', spellId, 'units=', getkeys(self.units), 'events=', getkeys(self.events), #self.handlers, 'handlers')
		else
			self:Debug('UpdateAction', 'nospell')
		end

		self:UpdateTarget(event)
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
	local unit
	if self.targetCmd then
		local _, target = SecureCmdOptionParse(self.targetCmd)
		unit = (target and target ~= "") and target or "target"
	end
	local guid = unit and UnitGUID(unit)
	self.unit = unit
	if self.guid ~= guid then
		self.guid = guid
		self:Scan(event)
	end
end

function overlayPrototype:ScheduleScan(event, unit)
	if not unit or (self.units.default and unit == self.unit) or self.units[unit] then
		self:Debug('Scheduling scan on', event, unit)
		self:SetScript('OnUpdate', self.ScheduledScan)
	end
end

function overlayPrototype:ScheduledScan(event, elapsed)
	self:SetScript('OnUpdate', nil)
	return self:Scan('OnUpdate')
end

local model = {}
function overlayPrototype:Scan(event)
	self:Debug('Scan', event, self.spellId, self.unit)

	local unit = self.unit

	model.count = 0
	model.expiration = 0
	model.highlight = nil

	for i, handler in ipairs(self.handlers) do
		local value = handler(unit, model)
		if value then
			self:Debug('Scan:', value)
		end
	end

	self:Debug("Scan =>", model.highlight, model.count, model.expiration)
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

