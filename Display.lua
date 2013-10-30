--[[
LuaAuras - Enhance action buttons using Lua handlers.
Copyright 2013 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

local addonName, addon = ...

local _G = _G
local CreateFrame = _G.CreateFrame
local floor = _G.floor
local GetTime = _G.GetTime
local next = _G.next
local pairs = _G.pairs
local tonumber = _G.tonumber

local overlayPrototype = addon.overlayPrototype

local PlanForUpdate, CancelUpdate
do
	local timerFrame = CreateFrame("Frame")
	local widgets = {}
	local elapsed = 0

	timerFrame:Hide()
	timerFrame:SetScript('OnUpdate', function(_, t)
		elapsed = elapsed + t
		if elapsed < 0.1 then return end
		for widget, delay in pairs(widgets) do
			delay = delay - elapsed
			if delay <= 0 then
				CancelUpdate(widget)
			else
				widgets[widget] = delay
				widget:Update(delay)
			end
		end
		elapsed = 0
	end)

	function PlanForUpdate(widget, delay)
		widgets[widget] = delay
		widget:Update(delay)
		widget:Show()
		timerFrame:Show()
	end

	function CancelUpdate(widget)
		widget:Hide()
		widgets[widget] = nil
		if not next(widgets) then
			timerFrame:Hide()
		end
	end

end

local function Timer_Update(timer, timeLeft)
	if timeLeft >= 3600 then
		timer:SetFormattedText("%dh", floor(timeLeft/3600))
	elseif timeLeft >= 600 then
		timer:SetFormattedText("%dm", floor(timeLeft/60))
	elseif timeLeft >= 60 then
		timer:SetFormattedText("%d:%02d", floor(timeLeft/60), floor(timeLeft%60))
	elseif timeLeft >= 3 then
		timer:SetFormattedText("%d", floor(timeLeft))
	else
		timer:SetFormattedText("%.1f", floor(timeLeft*10)/10)
	end
end

function overlayPrototype:InitializeDisplay()
	self:SetFrameLevel(self.button.cooldown:GetFrameLevel()+1)

	local border = self:CreateTexture(self:GetName().."Border", "BACKGROUND", NumberFontNormalSmall)
	border:SetPoint("CENTER", self)
	border:SetSize(62, 62)
	border:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
	border:SetBlendMode("ADD")
	border:Hide()
	self.Border = border

	local timer = self:CreateFontString(self:GetName().."Timer", "OVERLAY")
	timer:SetFont([[Fonts\ARIALN.TTF]], 13, "OUTLINE")
	timer:SetPoint("BOTTOMLEFT")
	timer.Update = Timer_Update
	timer:Hide()
	hooksecurefunc(timer, "Show", function() self:LayoutTexts() end)
	hooksecurefunc(timer, "Hide", function() self:LayoutTexts() end)
	self.Timer = timer

	local count = self:CreateFontString(self:GetName().."Count", "OVERLAY")
	count:SetFont([[Fonts\ARIALN.TTF]], 13, "OUTLINE")
	count:SetPoint("BOTTOMRIGHT")
	count:Hide()
	hooksecurefunc(count, "Show", function() self:LayoutTexts() end)
	hooksecurefunc(count, "Hide", function() self:LayoutTexts() end)
	self.Count = count
end

function overlayPrototype:LayoutTexts()
	self.Count:ClearAllPoints()
	self.Timer:ClearAllPoints()
	if self.Count:IsShown() then
		if self.Timer:IsShown() then
			self.Timer:SetPoint("BOTTOMLEFT")
			self.Count:SetPoint("BOTTOMRIGHT")
		else
			self.Count:SetPoint("BOTTOM")
		end
	elseif self.Timer:IsShown() then
		self.Timer:SetPoint("BOTTOM")
	end
end

function overlayPrototype:SetExpiration(expiration)
	expiration = tonumber(expiration) or 0
	if expiration == 0 or expiration <= GetTime() then expiration = nil end
	if self.expiration == expiration then return end
	self.expiration = expiration
	if expiration then
		PlanForUpdate(self.Timer, expiration - GetTime())
	else
		CancelUpdate(self.Timer)
	end
end

function overlayPrototype:SetCount(count)
	count = tonumber(count)
	if count == 0 then count = nil end
	if self.count == count then return end
	self.count = count
	self.Count:SetShown(count)
	if count then
		self.Count:SetFormattedText("%d", count)
	end
end

function overlayPrototype:SetHighlight(highlight)
	if self.highlight == highlight then return end
	self.highlight = highlight

	if highlight == "good" then
		self.Border:SetVertexColor(0, 1, 0)
		self.Border:Show()
	elseif highlight == "bad" then
		self.Border:SetVertexColor(1, 0, 0)
		self.Border:Show()
	elseif highlight == "flash" then
		self.Border:SetVertexColor(1, 1, 0.7)
		self.Border:Show()
	else
		self.Border:Hide()
	end
end
