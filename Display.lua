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

local AceTimer = LibStub('AceTimer-3.0')

local _G = _G
local CreateFrame = _G.CreateFrame
local floor = _G.floor
local GetTime = _G.GetTime
local next = _G.next
local pairs = _G.pairs
local tonumber = _G.tonumber

local fontFile, fontSize, fontFlag = [[Fonts\ARIALN.TTF]], 13, "OUTLINE"

local overlayPrototype = addon.overlayPrototype

local function Timer_Update(self)
	local timeLeft = (self.expiration or 0) - GetTime()
	local r, g, b, delay = 1, 1, 1

	if timeLeft >= 3600 then
		self:SetFormattedText("%dh", floor(timeLeft/3600))
		delay = timeLeft % 3600
	elseif timeLeft >= 600 then
		self:SetFormattedText("%dm", floor(timeLeft/60))
		delay = timeLeft % 60
	elseif timeLeft >= 60 and not self.compactTimeLeft then
		self:SetFormattedText("%d:%02d", floor(timeLeft/60), floor(timeLeft%60))
		delay = timeLeft % 1
	elseif timeLeft >= 3 then
		self:SetFormattedText("%d", floor(timeLeft))
		delay = timeLeft % 1
		if timeLeft <= 10 then
			r, g, b = 1, 1, (timeLeft - 3) / 7
		end
	elseif timeLeft > 0 then
		self:SetFormattedText("%.1f", floor(timeLeft*10)/10)
		delay = timeLeft % 0.1
		r, g, b = 1, 0.5 + timeLeft / 6, 0
	else
		if self.timerId then
			AceTimer:CancelTimer(self.timerId)
			self.timerId = nil
		end
		self:Hide()
		return
	end
	self:SetTextColor(r, g, b, 1)

	self.timerId = AceTimer.ScheduleTimer(self, "Update", delay)
	self:Show()
end

local function Text_OnShowHide(text)
	text:GetParent():LayoutTexts()
end

function overlayPrototype:InitializeDisplay()
	self:SetFrameLevel(self.button.cooldown:GetFrameLevel()+1)
	self.parentCount = _G[self.button:GetName().."Count"]

	local border = self:CreateTexture(self:GetName().."Border", "BACKGROUND", NumberFontNormalSmall)
	border:Hide()
	self.Border = border

	local timer = self:CreateFontString(self:GetName().."Timer", "OVERLAY")
	timer:SetFont(fontFile, fontSize, fontFlag)
	timer:SetPoint("BOTTOMLEFT", 2, 2)
	timer:SetPoint("BOTTOMRIGHT", -2, 2)
	timer:SetJustifyV("BOTTOM")
	timer.Update = Timer_Update
	timer:Hide()
	hooksecurefunc(timer, "Show", Text_OnShowHide)
	hooksecurefunc(timer, "Hide", Text_OnShowHide)
	self.Timer = timer

	local count = self:CreateFontString(self:GetName().."Count", "OVERLAY")
	count:SetFont(fontFile, fontSize, fontFlag)
	count:SetPoint("BOTTOMLEFT", 2, 2)
	count:SetPoint("BOTTOMRIGHT", -2, 2)
	count:SetJustifyV("BOTTOM")
	count:Hide()
	hooksecurefunc(count, "Show", Text_OnShowHide)
	hooksecurefunc(count, "Hide", Text_OnShowHide)
	self.Count = count
end

function overlayPrototype:LayoutTexts()
	local count, timer = self.Count, self.Timer
	local parentCount = self.parentCount
	local parentCountIsShown = parentCount:IsShown() and strtrim(parentCount:GetText() or "") ~= ""
	local countIsShown = count:IsShown() or parentCountIsShown
	self.compactTimeLeft = parentCountIsShown
	timer:SetJustifyH(countIsShown and "LEFT" or "CENTER")
	count:SetJustifyH(timer:IsShown() and "RIGHT" or "CENTER")
end

function overlayPrototype:SetExpiration(expiration)
	if type(expiration) ~= "number" or expiration <= GetTime() then
		expiration = nil
	end
	if self.expiration ~= expiration then
		self.expiration = expiration
		self.Timer.expiration = expiration
		self.Timer:Update()
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

	if highlight == "flash" then
		self:ShowOverlayGlow()
	else
		self:HideOverlayGlow()
	end

	local border = self.Border
	if highlight == "darken" or highlight == "lighten" then
		if border:GetTexture() ~= "Color-666666ff" then
			border:SetAllPoints(self)
			border:SetTexture(0.4, 0.4, 0.4, 1)
			border:SetVertexColor(1, 1, 1, 1)
		end
		border:SetBlendMode(highlight == "darken" and "MOD" or "ADD")
		border:Show()
	elseif highlight == "good" or highlight == "bad" then
		if border:GetTexture() ~= [[Interface\Buttons\UI-ActionButton-Border]] then
			border:ClearAllPoints()
			border:SetPoint("CENTER", self)
			border:SetSize(62, 62)
			border:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
			border:SetBlendMode("ADD")
		end
		if highlight == "good" then
			border:SetVertexColor(0, 1, 0, 1)
		else
			border:SetVertexColor(1, 0, 0, 1)
		end
		border:Show()
	else
		border:Hide()
	end
end

do
	local serial = 1
	local heap = {}

	local OnHide, AnimOutFinished

	local function CreateOverlayGlow()
		serial = serial + 1
		local overlay = CreateFrame("Frame", addonName.."ButtonOverlay"..serial, UIParent, "ActionBarButtonSpellActivationAlert")
		overlay.animOut:SetScript("OnFinished", AnimOutFinished)
		overlay:SetScript("OnHide", OnHide)
		return overlay
	end

	function AnimOutFinished(animGroup)
		local overlay = animGroup:GetParent()
		overlay:Hide()
		overlay:ClearAllPoints()
		overlay:SetParent(nil)
		overlay.state.overlay = nil
		overlay.state = nil
		tinsert(heap, overlay)
	end

	function OnHide(button)
		if button.animOut:IsPlaying() then
			button.animOut:Stop()
			return AnimOutFinished(button.animOut)
		end
	end

	function overlayPrototype:ShowOverlayGlow()
		local overlay = self.overlay
		if overlay then
			if overlay.animOut:IsPlaying() then
				overlay.animOut:Stop()
				overlay.animIn:Play()
			end
		else
			overlay = tremove(heap) or CreateOverlayGlow()
			local button = self.button
			local width, height = button:GetSize()
			overlay:SetParent(button)
			overlay:ClearAllPoints()
			overlay:SetSize(width * 1.4, height * 1.4)
			overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -width * 0.2, height * 0.2)
			overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", width * 0.2, -height * 0.2)
			overlay:Show()
			overlay.animIn:Play()
			overlay.state, self.overlay = self, overlay
		end
	end

	function overlayPrototype:HideOverlayGlow()
		local overlay = self.overlay
		if overlay then
			if overlay.animIn:IsPlaying() then
				overlay.animIn:Stop()
			end
			if overlay:IsVisible() then
				overlay.animOut:Play()
			else
				AnimOutFinished(overlay.animOut)
			end
		end
	end
end
