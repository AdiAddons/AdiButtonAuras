--[[
LuaAuras - Enhance action buttons using Lua handlers.
Copyright 2013 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

local addonName, addon = ...

local LibAdiEvent = LibStub('LibAdiEvent-1.0')

local overlayPrototype = setmetatable({}, { __index = CreateFrame("Frame") })
local overlayMeta = { __index = overlayPrototype }

_G.overlayPrototype = overlayPrototype
_G.overlayMeta = overlayMeta

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

	self:Show()
end

function overlayPrototype:OnShow()
	self:FullUpdate('OnShow')
end

function overlayPrototype:OnHide()
	self:UnregisterAllEvents()
end

function overlayPrototype:FullUpdate(event)
	self:UpdateAction(event)
end

local function ResolveMacroSpell(macroId)
	local _, _, macroSpellId = GetMacroSpell(macroId)
	if macroSpellId then
		return "spell", macroSpellId
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

	local macroOptionsMemo = setmetatable({}, {__index = function(self, index)
		local body = GetMacroBody(index)
		local options = body and FindMacroOptions(strsplit("\n", body)) or false
		if options then
			options = strjoin(';', GetConds(strsplit(';', options)))
		end
		self[index] = options or false
		return options
	end})
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
		local link = GetSpellLink(spell)
		spellId = link and tonumber(link:match('spell:(%d+):'))
	elseif actionType == "spell" or actionType == "companion" then
		spellId = actionId
	end

	if spellId then
		local spellName = GetSpellInfo(spellId)
		local spellType = IsHelpfulSpell(spellName) and "helpful" or IsHarmfulSpell(spellName) and "harmful" or "unknown"
		if targetCmd then
			targetCmd = gsub(targetCmd , "%[%]", defaultTargets[spellType])
		else
			targetCmd = defaultTargets[spellType]
		end
	end

	if self.spellId ~= spellId or self.targetCmd ~= targetCmd then
		self.spellId, self.targetCmd = spellId, targetCmd
		if spellId then
			self:RegisterEvent('PLAYER_TARGET_CHANGED', 'UpdateTarget')
		else
			self:UnregisterEvent('PLAYER_TARGET_CHANGED', 'UpdateTarget')
		end
		if spellId and targetCmd and strmatch(targetCmd, '@focus') then
			self:RegisterEvent('PLAYER_FOCUS_CHANGED', 'UpdateTarget')
		else
			self:UnregisterEvent('PLAYER_FOCUS_CHANGED', 'UpdateTarget')
		end
		if spellId and targetCmd and strmatch(targetCmd, '@mouseover') then
			self:RegisterEvent('PLAYER_FOCUS_CHANGED', 'UpdateTarget')
		else
			self:UnregisterEvent('PLAYER_FOCUS_CHANGED', 'UpdateTarget')
		end
		if spellId and targetCmd and strmatch(targetCmd, 'mod:') then
			self:RegisterEvent('MODIFIER_STATE_CHANGED', 'UpdateTarget')
		else
			self:UnregisterEvent('MODIFIER_STATE_CHANGED', 'UpdateTarget')
		end
		if origType == 'macro' then
			self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
		else
			self:UnregisterEvent('ACTIONBAR_SLOT_CHANGED')
		end
		return self:UpdateTarget(event)
	end
end

function overlayPrototype:UNIT_PET(event, unit)
	if unit == "player" then
		return self:UpdateTarget(event)
	end
end

function overlayPrototype:ACTIONBAR_SLOT_CHANGED(event, id)
	if id == self:GetActionId() then
		return self:UpdateTarget(event)
	end
end

function overlayPrototype:UNIT_PET(event, unit)
	if unit == "player" then
		return self:UpdateTarget(event)
	end
end

function overlayPrototype:UpdateTarget(event)
	local unit
	if self.spellId then
		local _, target = SecureCmdOptionParse(self.targetCmd)
		unit = (target and target ~= "") and target or "target"
	end
	local guid = unit and UnitGUID(unit)
	self.unit = unit
	if self.guid ~= guid then
		self.guid = guid
		return self:Scan(event)
	end
end

function overlayPrototype:Scan(event)
	self:Debug('Scan', event, self.spellId, self.unit)
end

local overlays = setmetatable({}, { __index = function(t, button)
	local overlay = false
	if button and button.IsObjectType and button:IsObjectType("Button") then
		local name = button:GetName()
		overlay = setmetatable(CreateFrame("Frame", name and (name..'Overlay'), button), overlayMeta)
		overlay:Initialize(button)
	end
	t[button] = overlay
	return overlay
end })

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
