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

local L = setmetatable({}, {
	__index = function(self, key)
		if not key then return end
		--@debug@
		addon.Debug('Localization', key)
		--@end-debug@
		self[key] = key
		return key
	end,
})
addon.L = L

--------------------------------------------------------------------------------
-- Locales from localization system
--------------------------------------------------------------------------------

-- %Localization: adibuttonauras
-- THE END OF THE FILE IS UPDATED BY https://github.com/Adirelle/wowaceTools/#updatelocalizationphp.
-- ANY CHANGE BELOW THESES LINES WILL BE LOST.
-- UPDATE THE TRANSLATIONS AT http://www.wowace.com/addons/adibuttonauras/localization/
-- AND ASK THE AUTHOR TO UPDATE THIS FILE.

-- @noloc[[

------------------------ enUS ------------------------


-- Config.lua
L["Check so actions on cooldown do not flash."] = true
L["Check to flash instead of displaying a border."] = true
L["Check to show a border when the (de)buff is missing."] = true
L["Configure spells and items individually."] = true
L["Countdown thresholds"] = true
L["Disabled"] = true
L["Duration above this threshold will use this format."] = true
L["Duration below this threshold will show decimals. Set to 0 to disable it."] = true
L["Durations above this threshold are hidden. Set to 0 to disable all countdowns."] = true
L["Enabled"] = true
L["Flash instead of border"] = true
L["Global"] = true
L["Inverted"] = true
L["Maximum duration for the \"2.7\" format"] = true
L["Maximum duration to show"] = true
L["Minimum duration for the \"2m\" format"] = true
L["Minimum duration for the \"4:58\" format"] = true
L["No flash on cooldown"] = true
L["No selection"] = true
L["Profiles"] = true
L["Rules"] = true
L["Select a spell or item by clicking on a green or blue button. Darkened buttons indicate spells and items unknown to AdiButtonAuras."] = true
L["Select which rules should by applied."] = true
L["Shift+click to toggle."] = true
L["Spells & items"] = true
L["Status"] = true
L["THIS DOES NOT AFFECT BLIZZARD FLASHS."] = true
L["The color used for bad things, usually debuffs."] = true
L["The color used for good things, usually buffs."] = true
L["Uncheck to ignore this spell/item."] = true
L["\"Bad\" border"] = true
L["\"Good\" border"] = true

-- RuleDSL.lua
L["%s when %s %s is found on %s."] = true
L["Show %s and %s when %s."] = true
L["Show %s and %s when it reaches its maximum."] = true
L["Show %s."] = true
L["darken"] = true
L["flash"] = true
L["it is above %s"] = true
L["it is below %s"] = true
L["lighten"] = true
L["show duration and/or stack count"] = true
L["show the \"bad\" border"] = true
L["show the \"good\" border"] = true
L["the buff"] = true
L["the debuff"] = true
L["the group members"] = true
L["the targeted ally"] = true
L["the targeted enemy"] = true
L["your buff"] = true
L["your debuff"] = true
L["your pet"] = true
L["yourself"] = true

-- plugins/Mistweaver.lua
L["Highlight when at least %s %s are running and one of them is below %s seconds."] = true
L["Highlight when total effective healing would be at least %d times the base healing."] = true
L["Show the number of group member affected by @NAME and the shortest duration."] = true

-- rules/Common.lua
L["%s when %s is casting/channeling a spell that you can interrupt."] = true
L["Show when @NAME or an equivalent haste buff is found on yourself."] = true
L["a buff you can dispel"] = true
L["a debuff you can dispel"] = true

-- rules/Druid.lua
L["Flash when mastery is inactive."] = true
L["combo points"] = true
L["lunar energy"] = true
L["solar energy"] = true

-- rules/Monk.lua
L["stagger level"] = true

-- rules/Warlock.lua
L["%s when you have 3 or more stacks of %s."] = true


------------------------ frFR ------------------------
local locale = GetLocale()
if locale == 'frFR' then
L["a buff you can dispel"] = "un buff que vous pouvez dissiper" -- Needs review
L["a debuff you can dispel"] = "un débuff que vous pouvez dissiper" -- Needs review
L["\"Bad\" border"] = "\"Mauvais\" pourtour" -- Needs review
L["Check so actions on cooldown do not flash."] = "Cochez pour que les actions en cooldown ne flashent pas." -- Needs review
L["Check to flash instead of displaying a border."] = "Cochez pour flasher au lieu d'afficher un bord" -- Needs review
L["Check to show a border when the (de)buff is missing."] = "Cochez pour afficher un pourtour quand le (dé)buff est absent." -- Needs review
L["combo points"] = "les points de combo" -- Needs review
L["Configure spells and items individually."] = "Configurer individuellement les sorts et les objets."
L["Countdown thresholds"] = "Seuils du compte à rebours" -- Needs review
L["darken"] = "assombrir" -- Needs review
L["Disabled"] = "Désactivé"
L["Duration above this threshold will use this format."] = "Les durées au-dessus de ce seuil sont affichées avec ce format." -- Needs review
L["Duration below this threshold will show decimals. Set to 0 to disable it."] = "Les durées sous ce seuil seront affichées avec les décimales. Choissisez 0 pour le désactiver." -- Needs review
L["Durations above this threshold are hidden. Set to 0 to disable all countdowns."] = "Les durées au-dessus de ce seuil sont cachés. Choisissez 0 pour désactiver tous les comptes à rebours." -- Needs review
L["Enabled"] = "Activé"
L["flash"] = "flasher" -- Needs review
L["Flash instead of border"] = "Flash au lieu du pourtour" -- Needs review
L["Flash when mastery is inactive."] = "Flasher quand la maîtrise est inactive." -- Needs review
L["Global"] = "Global"
L["\"Good\" border"] = "\"Bon\" pourtour" -- Needs review
L["Highlight when at least %s %s are running and one of them is below %s seconds."] = "Surligner quand au moins %s %s sont en cours et que l'une d'elle est en dessous de %s secondes." -- Needs review
L["Highlight when total effective healing would be at least %d times the base healing."] = "Surligner quand le soin total effectif dépassera %d fois le soin de base." -- Needs review
L["Inverted"] = "Inversé" -- Needs review
L["it is above %s"] = "c'est au-dessus de %s" -- Needs review
L["it is below %s"] = "c'est au-dessous de %s" -- Needs review
L["lighten"] = "éclaircir" -- Needs review
L["lunar energy"] = "l'énergie lunaire" -- Needs review
L["Maximum duration for the \"2.7\" format"] = "Durée maximale du format \"2.7\"" -- Needs review
L["Maximum duration to show"] = "Durée maximale à afficher" -- Needs review
L["Minimum duration for the \"2m\" format"] = "Durée minimale du format \"2m\"" -- Needs review
L["Minimum duration for the \"4:58\" format"] = "Durée minimale du format \"4:58\"" -- Needs review
L["No flash on cooldown"] = "Pas de flash en cooldown" -- Needs review
L["No selection"] = "Pas de sélection" -- Needs review
L["Profiles"] = "Profils" -- Needs review
L["Rules"] = "Règles" -- Needs review
L["Select a spell or item by clicking on a green or blue button. Darkened buttons indicate spells and items unknown to AdiButtonAuras."] = "Choisissez un sort ou un objet en cliquant sur un bouton bleu ou vert. Les boutons assombris indiquent les sorts et objets inconnus pour AdiButtonAuras." -- Needs review
L["Select which rules should by applied."] = "Sélectionnez les règles à appliquer." -- Needs review
L["Shift+click to toggle."] = "Maj+clic pour (dés)activer." -- Needs review
L["show duration and/or stack count"] = "afficher la duration et/ou le nombre d'applications" -- Needs review
L["Show %s."] = "Afficher %s." -- Needs review
L["Show %s and %s when it reaches its maximum."] = "Afficher %s et %s quand le maximum est atteint." -- Needs review
L["Show %s and %s when %s."] = "afficher %s et %s quand %s." -- Needs review
L["show the \"bad\" border"] = "afficher le pourtour \"mauvais\"" -- Needs review
L["show the \"good\" border"] = "afficher le pourtour \"bon\"" -- Needs review
L["Show the number of group member affected by @NAME and the shortest duration."] = "Affiche le nombre de membres du groupe affecté par @NAME et sa durée la plus courte;" -- Needs review
L["Show when @NAME or an equivalent haste buff is found on yourself."] = "Affiche quand vous avez @NAME ou un buff de hâte équivalent." -- Needs review
L["solar energy"] = "l'énergie solaire" -- Needs review
L["Spells & items"] = "Sorts & objets" -- Needs review
L["stagger level"] = "le niveau de report" -- Needs review
L["Status"] = "Statut" -- Needs review
L["%s when %s is casting/channeling a spell that you can interrupt."] = "%s quand %s lance un sort que vous pouvez interrompre." -- Needs review
L["%s when %s %s is found on %s."] = "%s quand %s %s est trouvé sur %s." -- Needs review
L["%s when you have 3 or more stacks of %s."] = "%s quand vous avez 3 %s ou plus." -- Needs review
L["the buff"] = "le buff" -- Needs review
L["The color used for bad things, usually debuffs."] = "La couleur utilisée pour les mauvaises choses, généralement les débuffs." -- Needs review
L["The color used for good things, usually buffs."] = "La couleur utilisée pour les bonnes choses, généralement les buffs." -- Needs review
L["the debuff"] = "le débuff" -- Needs review
L["the group members"] = "les membres du groupe" -- Needs review
L["the targeted ally"] = "l'allié ciblé" -- Needs review
L["the targeted enemy"] = "l'ennemi ciblé" -- Needs review
L["THIS DOES NOT AFFECT BLIZZARD FLASHS."] = "CELA N'AFFECTE PAS LES FLASHS DE BLIZZARD." -- Needs review
L["Uncheck to ignore this spell/item."] = "Décochez pour ignorer ce sort/objet." -- Needs review
L["your buff"] = "votre buff" -- Needs review
L["your debuff"] = "votre débuff" -- Needs review
L["your pet"] = "votre familier" -- Needs review
L["yourself"] = "vous-même" -- Needs review

------------------------ deDE ------------------------
-- no translation

------------------------ esMX ------------------------
-- no translation

------------------------ ruRU ------------------------
-- no translation

------------------------ esES ------------------------
-- no translation

------------------------ zhTW ------------------------
-- no translation

------------------------ zhCN ------------------------
-- no translation

------------------------ koKR ------------------------
-- no translation

------------------------ ptBR ------------------------
-- no translation
end

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end
