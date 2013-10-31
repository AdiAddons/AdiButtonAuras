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

local overlayPrototype = addon.overlayPrototype

local function Timer_Update(self)
	local timeLeft = (self.expiration or 0) - GetTime()
	local delay

	if timeLeft >= 3600 then
		self:SetFormattedText("%dh", floor(timeLeft/3600))
		delay = timeLeft % 3600
	elseif timeLeft >= 600 then
		self:SetFormattedText("%dm", floor(timeLeft/60))
		delay = timeLeft % 60
	elseif timeLeft >= 60 then
		self:SetFormattedText("%d:%02d", floor(timeLeft/60), floor(timeLeft%60))
		delay = timeLeft % 1
	elseif timeLeft >= 3 then
		self:SetFormattedText("%d", floor(timeLeft))
		delay = timeLeft % 1
	elseif timeLeft > 0 then
		self:SetFormattedText("%.1f", floor(timeLeft*10)/10)
		delay = timeLeft % 0.1
	else
		if self.timerId then
			AceTimer:CancelTimer(self.timerId)
			self.timerId = nil
		end
		self:Hide()
		return
	end

	self.timerId = AceTimer.ScheduleTimer(self, "Update", delay)
	self:Show()
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
