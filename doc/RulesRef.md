### Table of contents:
1. [General Format](#general-format)
1. Specific Rules:
  1. [ImportPlayerSpells](#ImportPlayerSpells)
  1. [SimpleBuffs](#SimpleBuffs)
  1. [SimpleDebuffs](#SimpleDebuffs)
  1. [SharedSimpleBuffs](#SharedSimpleBuffs)
  1. [SharedSimpleDebuffs](#SharedSimpleDebuffs)
  1. [SelfBuffs](#SelfBuffs)
  1. [PetBuffs](#PetBuffs)
  1. [BuffAliases](#BuffAliases)
  1. [DebuffAliases](#DebuffAliases)
  1. [SelfBuffAliases](#SelfBuffAliases)
  1. [LongestDebuffOf](#LongestDebuffOf)
  1. [PassiveModifier](#PassiveModifier)
  1. [ShowPower](#ShowPower)
  1. [Configure](#Configure)

### General Format:
<a name="general-format"></a>
`RuleName { arg1, arg2, ..., argN }`
* `arg#` - required argument (_type_)
* (`arg#`) - optional argument (_type_)

### Specific Rules:
<a name="ImportPlayerSpells"></a>
**`ImportPlayerSpells { class, excludeSpell1, ..., excludeSpellN }`**
>Imports the spells for the specified class from LibPlayerSpells and builds the rules for them.
* `class` - english class name of the class to be imported (_string_)
* `excludeSpell1` ... `excludeSpellN` - spell ids to be excluded from the import, so that the rules for them can be defined in AdiButtonAuras (_number_)

***

<a name="SimpleBuffs"></a>
**`SimpleBuffs { buff1, ..., buffN }`**
>List of buffs cast by the player on any ally.
* `buff1` ... `buffN` - buff id (_number_)  
    The provider spell ids are the same as the buff ids.

***

<a name="SimpleDebuffs"></a>
**`SimpleDebuffs { debuff1, ..., debuffN }`**
>List of debuffs cast by the player on any enemy.
* `debuff1` ... `debuffN` - debuff id (_number_)  
    The provider spell ids are the same as the debuff ids.

***

<a name="SharedSimpleBuffs"></a>
**`SharedSimpleBuffs { buff1, ..., buffN }`**
>List of buffs cast by anyone on any ally, where only one of that kind is possible (i.e. Soulstone)
* `buff1` ... `buffN` - buff id (_number_)  
    The provider spell ids are the same as the buff ids.

***

<a name="SharedSimpleDebuffs"></a>
**`SharedSimpleDebuffs { debuff1, ..., debuffN }`**
>List of debuffs cast by anyone on any enemy, where only one of that kind is possible (i.e. Hunter's Mark)
* `debuff1` ... `debuffN` - debuff id (_number_)  
    The provider spell ids are the same as the debuff ids.

***

<a name="SelfBuffs"></a>
**`SelfBuffs { buff1, ..., buffN }`**
>List of buffs cast by the player on the player
* `buff1` ... `buffN` - buff id (_number_)  
    The provider spell ids are the same as the buff ids.

***

<a name="PetBuffs"></a>
**`PetBuffs { buff1, ..., buffN }`**
>List of buffs cast by the player on his/her pet
* `buff1` ... `buffN` - buff id (_number_)  
    The provider spell ids are the same as the buff ids.

***

<a name="BuffAliases"></a>
**`BuffAliases { spells, buffs }`**
>Show any of player's `buffs` on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* `buffs` - buff id (_number_ or _table_)

***

<a name="DebuffAliases"></a>
**`DebuffAliases { spells, debuff }`**
>Show any of player's `debuffs` on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* `debuffs` - debuff id (_number_ or _table_)

>Example:
```
DebuffAliases {
	{
		   348, -- Immolate
		108686, -- Immolate (Fire and Brimstone)
	},
	348, -- Immolate
},
```
>This will show the duration of the debuff [Immolate](http://www.wowhead.com/spell=348) on both variants of the spell [Immolate](http://www.wowhead.com/spell=348) (the normal and the [modified](http://www.wowhead.com/spell=108686) by [Fire and Brimstone](http://www.wowhead.com/spell=108683))

***

<a name="SelfBuffAliases"></a>
**`SelfBuffAliases { spells, buffs }`**
>Show any of player's `buffs` on the player on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* `buffs` - buff id (_number_ or _table_)

***

<a name="LongestDebuffOf"></a>
**`LongestDebuffOf { spells, buffs }`**
>Show the longuest of player's `buffs` on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* `buffs` - buff id (_number_ or _table_)

***

<a name="PassiveModifier"></a>
**`PassiveModifier { passive, spell, buff, unit, highlight }`**
>If `passive` is in player spellbook, highlight `spell` with `highlight` when `buff` is found on `unit`.
* `passive` - passive spell id (_number_)
* `spell` - spell id (_number_ or _table_)
* `buff` - buff id (_number_)
* (`unit`) - [unit id](#unit-id) (_string_)  
    default value: "player"
* (`highlight`) - [highlight type](#highlight-type) (_string_)  
    default value: "good"

***

<a name="ShowPower"></a>
**`ShowPower { spells, power, handlerOrThreshold, highlight, description }`**
>Display power on the specified spell (i.e. number of Soul shard).
* `spells` - spell id of spells on which to display the power value (_number_ or _table_)
* `power` - power type (_string_)  
    One of the possible suffixes of `SPELL_POWER_` (i.e. "ENERGY")
* (`handlerOrThreshold`) - handler (_function_ or _number_)
    - if a _number_ is provided, it is interpreted as follow :
        - numbers in the [-1.0;1.0] range indicate a fraction of the maximum, e.g. 0.5 for 50%, else they are taken as is.
        - positive numbers indicates a minimum threshold, e.g. 50 triggers when the power is equal or greater than 50.
        - negative numbers indicates a maximum threshold, e.g. -50 triggers when the power is equal or less than 50.
    - default value: a _function_ that displays the current power value and highlights when it reaches it's maximum
* (`highlight`) - [highlight type](#highlight-type) (_string_)  
    default value: "flash"
* (`description`) - description for the option panel (_string_)  
    default value: nothing if the user supplied a _function_ in `handlerOrThreshold`, else a dmeaningful description

>Example:
```
ShowPower {
	5217, -- Tiger's Fury
	"ENERGY",
	35,
	"darken"
},
```
>This darkens Tiger's Fury when the player has more than 35 energy.

***

<a name="Configure"></a>
**`Configure { key, description, spells, units, events, handlers, providers }`**
>This allows to create a highly customized rule, that affects `spells`, if any of `providers` is in the player spellbook.
* `key` - unique string, used to disable the rule (_string_)
* `description` - description for the option panel (_string_)
* `spells` - spell id(s) (_number_ or _table_)
* `units` - [unit id(s)](#unit-id) (_string_ or _table_)
* `events` - event(s) (_string_ or _table_)
* `handlers` -  handler (_function_ or a _table_ of _functions_)
* (`providers`) - provider spell id (_number_ or _table_)
	default value: `spells`

***

### Other
<a name="highlight-type"></a>
**highlight type**
>One of the following:
* `"flash"` (active overlay)
* `"good"` (green border)
* `"bad"` (red border)
* `"darken"` (darker border)
* `"lighten"` (lighter border)

<a name="unit-id"></a>
**unit id**
>One of the following:
* one of the [standard unit ids](http://wowpedia.org/World_of_Warcraft_API_Unit_IDs): player, target, pet, focus, raid1, ...
* `"ally"` dynamically-resolved ally, depending on button macros, modifier keys, and auto-targetting settings.
* `"enemy"` dynamically-resolved enemy, depending on button macros, modifier keys, and auto-targetting settings.
