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


-- AdiButtonAuras.lua
L["Could not load configuration panel"] = true

-- Config.lua
L["AdiButtonAuras has no rule for this spell/item."] = true
L["AdiButtonAuras has special rules to suggest using a spell. How would like it to be display ?"] = true
L["Check so actions on cooldown do not flash."] = true
L["Check to disable flashs out of combat."] = true
L["Check to flash instead of displaying a border."] = true
L["Check to show a border when the (de)buff is missing."] = true
L["Color of the countdown text for values above 3."] = true
L["Color of the countdown text for values around 0."] = true
L["Color of the countdown text for values around 3."] = true
L["Configure spells and items individually."] = true
L["Countdown above 10"] = true
L["Countdown around 0"] = true
L["Countdown around 3"] = true
L["Countdown thresholds"] = true
L["Disabled"] = true
L["Duration above this threshold will use this format."] = true
L["Duration below this threshold will show decimals. Set to 0 to disable it."] = true
L["Durations above this threshold are hidden. Set to 0 to disable all countdowns."] = true
L["Enabled"] = true
L["Flash instead of border"] = true
L["Flashing border"] = true
L["Global"] = true
L["Inverted"] = true
L["Maximum duration for the \"2.7\" format"] = true
L["Maximum duration to show"] = true
L["Minimum duration for the \"2m\" format"] = true
L["Minimum duration for the \"4:58\" format"] = true
L["No flash on cooldown"] = true
L["No flash out of combat"] = true
L["No selection"] = true
L["Nothing"] = true
L["Profiles"] = true
L["Rotary star"] = true
L["Rules"] = true
L["Rules:"] = true
L["Select a spell or item by clicking on a green or blue button. Darkened buttons indicate spells and items unknown to AdiButtonAuras."] = true
L["Select which rules should by applied."] = true
L["Shift+click to toggle."] = true
L["Spells & items"] = true
L["Status"] = true
L["Suggestion display"] = true
L["THIS DOES NOT AFFECT BLIZZARD FLASHS."] = true
L["The color used for bad things, usually debuffs."] = true
L["The color used for good things, usually buffs."] = true
L["Uncheck to ignore this spell/item."] = true
L["\"Bad\" border"] = true
L["\"Good\" border"] = true
L["item"] = true
L["spell"] = true

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
L["suggest"] = true
L["the buff"] = true
L["the debuff"] = true
L["the group members"] = true
L["the targeted ally"] = true
L["the targeted enemy"] = true
L["your buff"] = true
L["your debuff"] = true
L["your pet"] = true
L["yourself"] = true

-- rules/Common.lua
L["%s when %s is casting/channeling a spell that you can interrupt."] = true
L["Show when @NAME or an equivalent haste buff is found on yourself."] = true
L["Track @NAME or equivalent raid buffs on all group members. Indicate the duration of the shortest buff and the number of missing buffs."] = true
L["a buff you can dispel"] = true
L["a debuff you can dispel"] = true
L["a debuff"] = true
L["of type '%s'"] = true

-- rules/Deathknight.lua
L["Shows Hint when target is below 35% health."] = true

-- rules/Druid.lua
L["Suggests to cast Rejuvenation to enable Glyph of Rejuvenation effect."] = true
L["Suggests when mastery is inactive."] = true
L["combo points"] = true
L["lunar energy"] = true
L["solar energy"] = true

-- rules/Monk.lua
L["Show %s count and suggest using it at 10 or more stacks."] = true
L["Show good border and remaining time of your summoned statue."] = true
L["Show hint when your health is below 35%."] = true
L["Show the number of group member affected by @NAME and the shortest duration."] = true
L["Suggest using @NAME under 92% mana."] = true
L["Suggest when at least %s %s are running and one of them is below %s seconds."] = true
L["Suggest when total effective healing would be at least %d times the base healing."] = true
L["stagger level"] = true

-- rules/Priest.lua
L["Show Power Word: Shield or Weakened Soul on targeted ally."] = true

-- rules/Shaman.lua
L["Show %s duration."] = true
L["Show %s stacks."] = true
L["air totems"] = true
L["earth totems"] = true
L["fire totems"] = true
L["water totems"] = true

-- rules/Warlock.lua
L["%s Else %s"] = true
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
L["Global"] = "Global"
L["\"Good\" border"] = "\"Bon\" pourtour" -- Needs review
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
elseif locale == 'esMX' then
L["a buff you can dispel"] = "un benefico que puedes disipar"
L["a debuff you can dispel"] = "un perjuicio que puedes disipar"
L["\"Bad\" border"] = "Borde 'malo'"
L["Check so actions on cooldown do not flash."] = "No destellar las acciones en cooldown."
L["Check to flash instead of displaying a border."] = "Destellar en vez de mostrar un borde."
L["Check to show a border when the (de)buff is missing."] = "Mostrar un borde cuando el beneficio o perjuicio se falta."
L["combo points"] = "puntos de combo"
L["Configure spells and items individually."] = "Configurar los hechizos y objectos de forma individual."
L["Countdown thresholds"] = "Umbrales de cuentra atrás"
L["darken"] = "oscurecerse"
L["Disabled"] = "Desactivado"
L["Duration above this threshold will use this format."] = "Duraciones más de este umbral se utilizan este formato."
L["Duration below this threshold will show decimals. Set to 0 to disable it."] = "Duraciones menos de este umbral se muestran décimas. Establece a 0 para desactivar."
L["Durations above this threshold are hidden. Set to 0 to disable all countdowns."] = "Duraciones más de este umbral se ocultan. Establece a 0 para desactivar todos cooldowns."
L["Enabled"] = "Activado"
L["flash"] = "destello"
L["Flash instead of border"] = "Destello en vez de borde"
L["Global"] = "Global"
L["\"Good\" border"] = "Borde 'bueno'"
L["Inverted"] = "Invertido"
L["it is above %s"] = "está mas de %s"
L["it is below %s"] = "está menos de %s"
L["lighten"] = "aclarar"
L["lunar energy"] = "energía lunar"
L["Maximum duration for the \"2.7\" format"] = "Duración máxima para el formato '2.7'"
L["Maximum duration to show"] = "Duración máxima para mostrar"
L["Minimum duration for the \"2m\" format"] = "Duración mínima para el formato '2m'"
L["Minimum duration for the \"4:58\" format"] = "Duración mínima para el formato '4:58'"
L["No flash on cooldown"] = "No destellar en cooldown"
L["No selection"] = "No hay selección"
L["Profiles"] = "Perfiles"
L["Rules"] = "Reglas"
L["Select a spell or item by clicking on a green or blue button. Darkened buttons indicate spells and items unknown to AdiButtonAuras."] = "Seleccione un hechizo o objeto haciendo clic en un botón verde o azul. Los botones oscurecidos inidcan los hechizos y objetos que son desconocidos para AdiButtonAuras."
L["Select which rules should by applied."] = "Seleccione cual reglas para applicar."
L["Shift+click to toggle."] = "Mayús-clic para alternar."
L["show duration and/or stack count"] = "mostrar duración y/o cuenta del montón"
L["Show %s."] = "Mostrar %s."
L["Show %s and %s when it reaches its maximum."] = "Mostrar %s y %s cuando se alcanza su máximo"
L["Show %s and %s when %s."] = "Mostrar %s y %s cuando %s."
L["show the \"bad\" border"] = "mostrar el borde 'malo'"
L["show the \"good\" border"] = "mostrar el borde 'bueno'"
L["Show the number of group member affected by @NAME and the shortest duration."] = "Mostrar el número del miembro del grupo quién está afectado por @NAME y la duración más corta."
L["Show when @NAME or an equivalent haste buff is found on yourself."] = "Mostrar cuando @NAME o un beneficio equivalente se encuentra en ti mismo."
L["solar energy"] = "energía solar"
L["Spells & items"] = "Hechizos y objetos"
L["stagger level"] = "nivel de Alpazar"
L["Status"] = "Estado"
L["%s when %s is casting/channeling a spell that you can interrupt."] = "%s cuando %s está lanzado o canalizando un hechizo que puedes interrumpir."
L["%s when %s %s is found on %s."] = "%s cuando %s %s se encuentra en %s."
L["%s when you have 3 or more stacks of %s."] = "%s cuando tienes 3 o más montones de %s."
L["the buff"] = "el beneficio"
L["The color used for bad things, usually debuffs."] = "El color a utilizar para las cosas malas, en general perjuicios."
L["The color used for good things, usually buffs."] = "El color a utilizar para las cosas malas, en general beneficios."
L["the debuff"] = "el perjuicio"
L["the group members"] = "los miembres del grupo"
L["the targeted ally"] = "el aliado seleccionado"
L["the targeted enemy"] = "el aliado seleccionado"
L["THIS DOES NOT AFFECT BLIZZARD FLASHS."] = "ESTO NO AFECTA LOS DESTELLOS DE BLIZZARD."
L["Uncheck to ignore this spell/item."] = "Deseleccione para ignorar este hechizo o objecto."
L["your buff"] = "tu beneficio"
L["your debuff"] = "tu perjuicio"
L["your pet"] = "tu mascota"
L["yourself"] = "tú mismo"

------------------------ ruRU ------------------------
-- no translation

------------------------ esES ------------------------
elseif locale == 'esES' then
L["a buff you can dispel"] = "un benefico que puedes disipar"
L["a debuff you can dispel"] = "un perjuicio que puedes disipar"
L["\"Bad\" border"] = "Borde 'malo'"
L["Check so actions on cooldown do not flash."] = "No destellar las acciones en cooldown."
L["Check to flash instead of displaying a border."] = "Destellar en vez de mostrar un borde."
L["Check to show a border when the (de)buff is missing."] = "Mostrar un borde cuando el beneficio o perjuicio se falta."
L["combo points"] = "puntos de combo"
L["Configure spells and items individually."] = "Configurar los hechizos y objectos de forma individual."
L["Countdown thresholds"] = "Umbrales de cuentra atrás"
L["darken"] = "oscurecerse"
L["Disabled"] = "Desactivado"
L["Duration above this threshold will use this format."] = "Duraciones más de este umbral se utilizan este formato."
L["Duration below this threshold will show decimals. Set to 0 to disable it."] = "Duraciones menos de este umbral se muestran décimas. Establece a 0 para desactivar."
L["Durations above this threshold are hidden. Set to 0 to disable all countdowns."] = "Duraciones más de este umbral se ocultan. Establece a 0 para desactivar todos cooldowns."
L["Enabled"] = "Activado"
L["flash"] = "destello"
L["Flash instead of border"] = "Destello en vez de borde"
L["Global"] = "Global"
L["\"Good\" border"] = "Borde 'bueno'"
L["Inverted"] = "Invertido"
L["it is above %s"] = "está mas de %s"
L["it is below %s"] = "está menos de %s"
L["lighten"] = "aclarar"
L["lunar energy"] = "energía lunar"
L["Maximum duration for the \"2.7\" format"] = "Duración máxima para el formato '2.7'"
L["Maximum duration to show"] = "Duración máxima para mostrar"
L["Minimum duration for the \"2m\" format"] = "Duración mínima para el formato '2m'"
L["Minimum duration for the \"4:58\" format"] = "Duración mínima para el formato '4:58'"
L["No flash on cooldown"] = "No destellar en cooldown"
L["No selection"] = "No hay selección"
L["Profiles"] = "Perfiles"
L["Rules"] = "Reglas"
L["Select a spell or item by clicking on a green or blue button. Darkened buttons indicate spells and items unknown to AdiButtonAuras."] = "Seleccione un hechizo o objeto haciendo clic en un botón verde o azul. Los botones oscurecidos inidcan los hechizos y objetos que son desconocidos para AdiButtonAuras."
L["Select which rules should by applied."] = "Seleccione cual reglas para applicar."
L["Shift+click to toggle."] = "Mayús-clic para alternar."
L["show duration and/or stack count"] = "mostrar duración y/o cuenta del montón"
L["Show %s."] = "Mostrar %s."
L["Show %s and %s when it reaches its maximum."] = "Mostrar %s y %s cuando se alcanza su máximo"
L["Show %s and %s when %s."] = "Mostrar %s y %s cuando %s."
L["show the \"bad\" border"] = "mostrar el borde 'malo'"
L["show the \"good\" border"] = "mostrar el borde 'bueno'"
L["Show the number of group member affected by @NAME and the shortest duration."] = "Mostrar el número del miembro del grupo quién está afectado por @NAME y la duración más corta."
L["Show when @NAME or an equivalent haste buff is found on yourself."] = "Mostrar cuando @NAME o un beneficio equivalente se encuentra en ti mismo."
L["solar energy"] = "energía solar"
L["Spells & items"] = "Hechizos y objetos"
L["stagger level"] = "nivel de Alpazar"
L["Status"] = "Estado"
L["%s when %s is casting/channeling a spell that you can interrupt."] = "%s cuando %s está lanzado o canalizando un hechizo que puedes interrumpir."
L["%s when %s %s is found on %s."] = "%s cuando %s %s se encuentra en %s."
L["%s when you have 3 or more stacks of %s."] = "%s cuando tienes 3 o más montones de %s."
L["the buff"] = "el beneficio"
L["The color used for bad things, usually debuffs."] = "El color a utilizar para las cosas malas, en general perjuicios."
L["The color used for good things, usually buffs."] = "El color a utilizar para las cosas malas, en general beneficios."
L["the debuff"] = "el perjuicio"
L["the group members"] = "los miembres del grupo"
L["the targeted ally"] = "el aliado seleccionado"
L["the targeted enemy"] = "el aliado seleccionado"
L["THIS DOES NOT AFFECT BLIZZARD FLASHS."] = "ESTO NO AFECTA LOS DESTELLOS DE BLIZZARD."
L["Uncheck to ignore this spell/item."] = "Deseleccione para ignorar este hechizo o objecto."
L["your buff"] = "tu beneficio"
L["your debuff"] = "tu perjuicio"
L["your pet"] = "tu mascota"
L["yourself"] = "tú mismo"

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
