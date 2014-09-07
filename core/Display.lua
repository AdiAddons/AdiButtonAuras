--[[
AdiButtonAuras - Display auras on action buttons.
Copyright 2013-2014 Adirelle (adirelle@gmail.com)
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

local _G = _G
local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime
local UIParent = _G.UIParent
local floor = _G.floor
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local pairs = _G.pairs
local strtrim = _G.strtrim
local tinsert = _G.tinsert
local tonumber = _G.tonumber
local tremove = _G.tremove
local type = _G.type
local unpack = _G.unpack

local AceTimer = addon.GetLib('AceTimer-3.0')
local LSM = addon.GetLib('LibSharedMedia-3.0')

local fontFile, fontSize, fontFlag = [[Fonts\ARIALN.TTF]], 13, "OUTLINE"

local overlayPrototype = addon.overlayPrototype
local ColorGradient = addon.ColorGradient

local function Timer_Update(self)
	local prefs = addon.db.profile
	local timeLeft = (self.expiration or 0) - GetTime()

	if timeLeft > prefs.maxCountdown then
		self.timerId = AceTimer.ScheduleTimer(self, "Update", timeLeft - prefs.maxCountdown)
		self:Hide()
		return
	end

	local delay
	if timeLeft >= 3600 then
		self:SetFormattedText("%dh", floor(timeLeft/3600))
		delay = timeLeft % 3600
	elseif timeLeft >= (self.compactTimeLeft and prefs.minMinuteSecs or prefs.minMinutes) then
		self:SetFormattedText("%dm", floor(timeLeft/60))
		delay = timeLeft % 60
	elseif timeLeft >= prefs.minMinuteSecs then
		self:SetFormattedText("%d:%02d", floor(timeLeft/60), floor(timeLeft%60))
		delay = timeLeft % 1
	elseif timeLeft >= prefs.maxTenth then
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

	local r, g, b = unpack(prefs.colors.countdownHigh)
	if timeLeft <= 3 then
		local r1, g1, b1 = unpack(prefs.colors.countdownLow)
		local r2, g2, b2 = unpack(prefs.colors.countdownMedium)
		r, g, b = ColorGradient(timeLeft, 3, r1, g1, b1, r2, g2, b2)
	elseif timeLeft <= 10 then
		local r2, g2, b2 = unpack(prefs.colors.countdownMedium)
		r, g, b = ColorGradient(timeLeft - 3, 7, r2, g2, b2, r, g, b)
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

	local border = self:CreateTexture(self:GetName().."Border", "BACKGROUND")
	border:SetAllPoints(self)
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
	if parentCountIsShown and count:IsShown() and parentCount:GetText() == count:GetText() then
		return count:Hide()
	end
	local countIsShown = count:IsShown() or parentCountIsShown
	timer.compactTimeLeft = countIsShown
	timer:SetJustifyH(countIsShown and "LEFT" or "CENTER")
	count:SetJustifyH(timer:IsShown() and "RIGHT" or "CENTER")
end

function overlayPrototype:SetExpiration(expiration)
	if type(expiration) ~= "number" or expiration <= GetTime() then
		expiration = nil
	end
	if self.expiration ~= expiration then
		self.expiration = expiration
		self:ApplyExpiration()
	end
end

function overlayPrototype:ApplyFont(fontString)
	local currentFile, currentSize = fontString:GetFont()
	local file, size = LSM:Fetch(LSM.MediaType.FONT, addon.db.profile.fontName), addon.db.profile.fontSize
	if currentFile ~= file or currentSize ~= size then
		fontString:SetFont(file, size, fontFlag)
	end
end

function overlayPrototype:ApplyExpiration()
	local expiration = self.expiration
	self.Timer.expiration = expiration
	self:ApplyFont(self.Timer)
	self.Timer:Update()
end

function overlayPrototype:SetCount(count)
	count = tonumber(count)
	if count == 0 then count = nil end
	if self.count == count then return end
	self.count = count
	self:ApplyCount()
end

function overlayPrototype:ApplyCount()
	local count = self.count
	self:ApplyFont(self.Count)
	self.Count:SetShown(count)
	if count then
		self.Count:SetFormattedText("%d", count)
	end
end

function overlayPrototype:SetHighlight(highlight)
	if self.highlight == highlight then return end
	self.highlight = highlight
	self:ApplyHighlight()
end

function overlayPrototype:ApplyHighlight()
	self:ApplyFlash()
	self:ApplyColoredBorder()
end

function overlayPrototype:ApplyFlash()
	if self:ShouldShowFlash() or self:ShouldShowHint("flash") then
		return self:ShowFlash()
	end
	self:HideFlash()
end

function overlayPrototype:ShouldShowFlash()
	return self.highlight == "flash" and not (addon.db.profile.noFlashOnCooldown and self.inCooldown) and (not addon.db.profile.noFlashOutOfCombat or self.inCombat)
end

function overlayPrototype:ApplyColoredBorder()
	local highlight = self.highlight
	local border = self.Border
	if highlight == "darken" or highlight == "lighten" then
		if border:GetTexture() ~= "Color-666666ff" then
			border:SetTexture(0.4, 0.4, 0.4, 1)
			border:SetVertexColor(1, 1, 1, 1)
		end
		border:SetBlendMode(highlight == "darken" and "MOD" or "ADD")
		return border:Show()
	end
	if highlight == "good" or highlight == "bad" then
		local texture = LSM:Fetch(addon.HIGHLIGHT_MEDIATYPE, addon.db.profile.highlightTexture)
		if border:GetTexture() ~= texture then
			border:SetTexture(texture)
			border:SetBlendMode("BLEND")
		end
		border:SetVertexColor(unpack(addon.db.profile.colors[highlight], 1, 4))
		return border:Show()
	end
	border:Hide()
end

function overlayPrototype:SetHint(hint)
	hint = not not hint
	if self.hint ~= hint then
		self.hint = hint
		self:ApplyHint()
	end
end

function overlayPrototype:ApplyHint()
	if addon.db.profile.hints == "flash" then
		self:ApplyFlash()
		return self:HideHint()
	end
	if self:ShouldShowHint("show")  then
		return self:ShowHint()
	end
	self:HideHint()
end

function overlayPrototype:ShouldShowHint(expectedSetting)
	return self.hint and not self.inCooldown and self.inCombat and addon.db.profile.hints == expectedSetting
end

function overlayPrototype:UpdateDisplay(event)
	self:Debug('UpdateDisplay' ,event)
	self.inCombat = InCombatLockdown()
	self:ApplyExpiration()
	self:ApplyCount()
	self:ApplyHighlight()
	self:ApplyHint()
	return true
end

function overlayPrototype:PLAYER_REGEN_ENABLED(event)
	self.inCombat = (event == "PLAYER_REGEN_DISABLED")
	self:ApplyHighlight()
	self:ApplyHint()
end
overlayPrototype.PLAYER_REGEN_DISABLED = overlayPrototype.PLAYER_REGEN_ENABLED

-- Overlay factory
local function CreateOverlayFactory(create, onAcquire, onRelease, onEnable, onDisable, onShow, onHide)
	local serial = 1
	local heap = {}

	local function Release(overlay)
		if heap[overlay] then return end
		heap[overlay] = true
		if onRelease then
			onRelease(overlay)
		end
		overlay.owner[heap] = nil
		overlay.owner = nil
		overlay:Hide()
		overlay:SetParent(nil)
		overlay:ClearAllPoints()
	end

	local function Create()
		serial = serial + 1
		local overlay = create(serial)
		overlay:Hide()
		overlay:SetScript('OnShow', onShow)
		overlay:SetScript('OnHide', onHide)
		overlay.Release = Release
		return overlay
	end

	local function Enable(owner)
		local overlay = owner[heap]
		if not overlay then
			overlay = tremove(heap) or Create()
			heap[overlay] = nil
			overlay.owner = owner
			owner[heap] = overlay
			onAcquire(overlay)
		end
		overlay:Show()
		if onEnable then
			onEnable(overlay)
		end
	end

	local function Disable(owner)
		local overlay = owner[heap]
		if overlay then
			(onDisable or Release)(overlay)
		end
	end

	return Enable, Disable
end

-- Use Blizzard template
overlayPrototype.ShowFlash, overlayPrototype.HideFlash = CreateOverlayFactory(
	-- create
	-- create
	function(serial)
		local overlay = CreateFrame("Frame", addonName.."Flash"..serial, UIParent, "ActionBarButtonSpellActivationAlert")
		overlay.animOut:SetScript("OnFinished", function() overlay:Release() end)
		return overlay
	end,
	-- onAcquire
	function(overlay)
		local button = overlay.owner.button
		local width, height = button:GetSize()
		overlay:SetParent(button)
		overlay:ClearAllPoints()
		overlay:SetSize(width * 1.4, height * 1.4)
		overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -width * 0.2, height * 0.2)
		overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", width * 0.2, -height * 0.2)
	end,
	-- onRelease
	function(overlay)
		if overlay.animOut:IsPlaying() then
			overlay.animOut:Stop()
		end
		if overlay.animIn:IsPlaying() then
			overlay.animIn:Stop()
		end
	end,
	-- onEnable
	function(overlay)
		if overlay.animOut:IsPlaying() then
			overlay.animOut:Stop()
			overlay.animIn:Play()
		end
	end,
	-- onDisable
	function(overlay)
		if overlay.animIn:IsPlaying() then
			overlay.animIn:Stop()
		end
		if overlay:IsVisible() then
			overlay.animOut:Play()
		else
			overlay:Release()
		end
	end,
	-- onShow
	function(overlay)
		overlay.animIn:Play()
	end,
	-- onHide
	function(overlay)
		overlay:Release()
	end
)

-- Another overlay, for suggestion
overlayPrototype.ShowHint, overlayPrototype.HideHint = CreateOverlayFactory(
	-- create
	function(serial)
		local overlay = CreateFrame("Frame", addonName.."Hint"..serial)
		overlay:SetAlpha(0.8)

		local tex = overlay:CreateTexture("OVERLAY")
		tex:SetTexture([[Interface\Cooldown\star4]])
		tex:SetBlendMode("ADD")
		tex:SetAllPoints(overlay)
		overlay.Texture = tex

		local animRotate = overlay:CreateAnimationGroup()
		animRotate:SetLooping("REPEAT")

		local rotation = animRotate:CreateAnimation("Rotation")
		rotation:SetOrder(1)
		rotation:SetDuration(3)
		rotation:SetDegrees(360)
		rotation:SetOrigin("CENTER", 0, 0)

		animRotate:Play()

		return overlay
	end,
	-- onAcquire
	function(overlay)
		overlay:SetParent(overlay.owner)
		overlay:SetPoint("CENTER")
		local w, h = overlay.owner:GetSize()
		overlay:SetSize(w*1.5, h*1.5)
	end
)
