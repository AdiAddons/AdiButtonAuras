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
local C_Timer = _G.C_Timer
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
local max = _G.max
local ceil = _G.ceil
local InCombatLockdown = _G.InCombatLockdown

local LSM = addon.GetLib('LibSharedMedia-3.0')
local LBG = addon.GetLib('LibButtonGlow-1.0')

local fontFile, fontSize, fontFlag = [[Fonts\ARIALN.TTF]], 13, "OUTLINE"

local overlayPrototype = addon.overlayPrototype
local ColorGradient = addon.ColorGradient

local function Timer_Update(self)
	local timeLeft = (self.expiration or 0) - GetTime()
	if timeLeft <= 0 then
		self:Hide()
		return
	end

	local prefs = addon.db.profile
	if timeLeft > prefs.maxCountdown then
		C_Timer.After(max(0.1, timeLeft - prefs.maxCountdown), function() return Timer_Update(self) end)
		self:Hide()
		return
	end

	local delay
	if timeLeft > 3600 then
		self:SetFormattedText("%dh", floor(timeLeft/3600))
		delay = ceil(timeLeft % 3600)
	elseif timeLeft > (self.compactTimeLeft and prefs.minMinuteSecs or prefs.minMinutes) then
		self:SetFormattedText("%dm", floor(timeLeft/60))
		delay = ceil(timeLeft % 60)
	elseif timeLeft > prefs.minMinuteSecs then
		self:SetFormattedText("%d:%02d", floor(timeLeft/60), floor(timeLeft%60))
		delay = ceil((timeLeft % 1) * 10) / 10
	elseif timeLeft > prefs.maxTenth then
		self:SetFormattedText("%d", floor(timeLeft))
		delay = ceil((timeLeft % 1) * 10) / 10
	else
		self:SetFormattedText("%.1f", floor(timeLeft*10)/10)
		delay = 0.1
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

	C_Timer.After(max(0.1, delay), function() return Timer_Update(self) end)
	self:Show()
end

local function Text_OnShowHide(text)
	text:GetParent():LayoutTexts()
end

function overlayPrototype:InitializeDisplay()
	self:SetFrameLevel(self.button.cooldown:GetFrameLevel()+1)
	self.parentCount = _G[self.button:GetName().."Count"]

	local highlight = self:CreateTexture(self:GetName().."Highlight", "BACKGROUND")
	highlight:SetAllPoints(self)
	highlight:Hide()
	self.Highlight = highlight

	local overlay = self:CreateTexture(self:GetName().."Overlay", "BACKGROUND")
	overlay:SetTexture(0.4, 0.4, 0.4, 1)
	overlay:SetAllPoints(self)
	overlay:Hide()
	self.Overlay = overlay

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

	self:ApplySkin()
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

------------------------------------------------------------------------------
-- Theme and skinning
------------------------------------------------------------------------------

function overlayPrototype:ApplyFont(fontString)
	local currentFile, currentSize = fontString:GetFont()
	local file, size = LSM:Fetch(LSM.MediaType.FONT, addon.db.profile.fontName), addon.db.profile.fontSize
	if currentFile ~= file or currentSize ~= size then
		fontString:SetFont(file, size, fontFlag)
	end
end

function overlayPrototype:ApplyHighlightSkin()
	local highlight = self.Highlight
	local texture = LSM:Fetch(addon.HIGHLIGHT_MEDIATYPE, addon.db.profile.highlightTexture)
	highlight:SetTexture(texture)
end

function overlayPrototype:ApplySkin()
	if not self:Masque() then
		self:ApplyHighlightSkin()
	end
	self:ApplyFont(self.Timer)
	self:ApplyFont(self.Count)
end

------------------------------------------------------------------------------
-- Masque support
------------------------------------------------------------------------------

local Masque, MasqueVersion = addon.GetLib('Masque', true)
if Masque then
	local group = Masque:Group(addonName)

	-- Provide a fake background to Masque, to avoid masking the underlying button
	local NOOP = function() end
	local fakeBackground = setmetatable({}, { __index = function() return NOOP end})

	function overlayPrototype:Masque()
		if not self.masqueData then
			self.masqueData = {
				Border = self.Highlight,
				Normal = false,
				FloatingBG = fakeBackground,
			}
			group:AddButton(self, self.masqueData)
		end
		return not group.db.Disabled
	end

	Masque.Register(addonName, function() addon:SendMessage(addon.THEME_CHANGED) end)
else
	function overlayPrototype:Masque()
		return false
	end
end

------------------------------------------------------------------------------
-- State setters
------------------------------------------------------------------------------

function overlayPrototype:SetExpiration(expiration)
	if type(expiration) ~= "number" or expiration <= GetTime() then
		expiration = nil
	end
	if self.expiration == expiration then return end
	self.expiration = expiration
	self:ApplyExpiration()
end

function overlayPrototype:SetCount(count)
	count = tonumber(count)
	if count == 0 then count = nil end
	if self.count == count then return end
	self.count = count
	self:ApplyCount()
end

function overlayPrototype:SetHighlight(highlight)
	if self.highlight == highlight then return end
	self.highlight = highlight
	self:ApplyHighlight()
end

function overlayPrototype:SetFlash(flash)
	flash = not not flash
	if self.flash == flash then return end
	self.flash = flash
	self:ApplyFlash()
end

function overlayPrototype:SetHint(hint)
	hint = not not hint
	if self.hint == hint then return end
	self.hint = hint
	self:ApplyHint()
end

------------------------------------------------------------------------------
-- Actual state feedback
------------------------------------------------------------------------------

function overlayPrototype:ApplyExpiration()
	local expiration = self.expiration
	self.Timer.expiration = expiration
	self.Timer:Update()
end

function overlayPrototype:ApplyCount()
	local count = self.count
	self.Count:SetShown(count)
	if count then
		self.Count:SetFormattedText("%d", count)
	end
end

function overlayPrototype:ApplyHighlight()
	self:ApplyColoredHighlight()
end

function overlayPrototype:ApplyFlash()
	if self:ShouldShowFlash() or self:ShouldShowHint("flash") then
		return self:ShowFlash()
	end
	self:HideFlash()
end

function overlayPrototype:ShouldShowFlash()
	if addon.db.profile.noFlashOnCooldown and self.inCooldown then
		return false
	end
	if addon.db.profile.noFlashOutOfCombat and not self.inCombat then
		return false
	end
	return self.flash
end

function overlayPrototype:ApplyColoredHighlight()
	local type, highlight, overlay = self.highlight, self.Highlight, self.Overlay
	if type == "darken" or type == "lighten" then
		overlay:SetBlendMode(type == "darken" and "MOD" or "ADD")
		overlay:Show()
	else
		overlay:Hide()
	end
	if type == "good" or type == "bad" then
		highlight:SetVertexColor(unpack(addon.db.profile.colors[type], 1, 4))
		highlight:Show()
	else
		highlight:Hide()
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
	self:ApplyFlash()
	self:ApplyHint()
	return true
end

function overlayPrototype:PLAYER_REGEN_ENABLED(event)
	self.inCombat = (event == "PLAYER_REGEN_DISABLED")
	self:ApplyHint()
	self:ApplyFlash()
end
overlayPrototype.PLAYER_REGEN_DISABLED = overlayPrototype.PLAYER_REGEN_ENABLED

-- Use LibButtonGlow-1.0 for flashing animation
overlayPrototype.ShowFlash = LBG.ShowOverlayGlow
overlayPrototype.HideFlash = LBG.HideOverlayGlow

------------------------------------------------------------------------------
-- Animations
------------------------------------------------------------------------------

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
