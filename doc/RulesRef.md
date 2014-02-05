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
`RuleName { arg1, arg2, ..., argN }`
* `arg#` - required argument (_type_)
* (`arg#`) - optional argument (_type_)

### Specific Rules:
<a name="ImportPlayerSpells"></a>
**`ImportPlayerSpells { arg1, arg2, ..., argN }`**
>Imports the spells for the specified class from LibPlayerSpells and builds the rules for them
* `arg1` - english class name of the class to be imported (_string_)
* `arg2` ... `argN` - spell ids to be excluded from the import, so that the rules for them can be defined in AdiButtonAuras (_number_)

***

<a name="SimpleBuffs"></a>
**`SimpleBuffs { arg1, ..., argN }`**
>List of buffs cast by the player on any ally
* `arg1` ... `argN` - buff id (_number_)  
    The provider spell ids are the same as the buff ids.

***

<a name="SimpleDebuffs"></a>
**`SimpleDebuffs { arg1, ..., argN }`**
>List of debuffs cast by the player on any enemy
* `arg1` ... `argN` - debuff id (_number_)  
    The provider spell ids are the same as the debuff ids.

***

<a name="SharedSimpleBuffs"></a>
**`SharedSimpleBuffs { arg1, ..., argN }`**
>List of buffs cast by anyone on any ally, where only one of that kind is possible (i.e. Soulstone)
* `arg1` ... `argN` - buff id (_number_)  
    The provider spell ids are the same as the buff ids.

***

<a name="SharedSimpleDebuffs"></a>
**`SharedSimpleDebuffs { arg1, ..., argN }`**
>List of debuffs cast by anyone on any enemy, where only one of that kind is possible (i.e. Hunter's Mark)
* `arg1` ... `argN` - debuff id (_number_)  
    The provider spell ids are the same as the debuff ids.

***

<a name="SelfBuffs"></a>
**`SelfBuffs { arg1, ..., argN }`**
>List of buffs cast by the player on the player
* `arg1` ... `argN` - buff id (_number_)  
    The provider spell ids are the same as the buff ids.

***

<a name="PetBuffs"></a>
**`PetBuffs { arg1, ..., argN }`**
>List of buffs cast by the player on his/her pet
* `arg1` ... `argN` - buff id (_number_)  
    The provider spell ids are the same as the buff ids.

***

<a name="BuffAliases"></a>
**`BuffAliases { arg1, arg2 }`**
>Maps the buff in `arg2` to the spells in `arg1` so that it's duration is shown on them
* `arg1` - spell id (_number_ or _table_)
* `arg2` - buff id (_number_)

***

<a name="DebuffAliases"></a>
**`DebuffAliases { arg1, arg2 }`**
>Maps the debuff in `arg2` to the spells in `arg1` so that it's duration is shown on them
* `arg1` - spell id (_number_ or _table_)
* `arg2` - debuff id (_number_)

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
**`SelfBuffAliases { arg1, arg2 }`**
>Maps the buff in `arg2` to the spells in `arg1` so that it's duration is shown on them.
* `arg1` - spell id (_number_)
* `arg2` - buff id (_number_)

***

<a name="LongestDebuffOf"></a>
**`LongestDebuffOf { arg1, arg2 }`**
>Displays the duration of the longest debuff in `arg2` on the spells in `arg1`.
* `arg1` - spell id (_number_ or _table_)
* `arg2` - buff id (_number_ or _table_)

***

<a name="PassiveModifier"></a>
**`PassiveModifier { arg1, arg2, arg3, arg4, arg5 }`**
>Maps the buff in `arg3` if applied to the unit in `arg4` to the spell(s) in `arg2` if the spell in `arg1` is known by the player.
* `arg1` - passive spell id (_number_)
* `arg2` - spell id (_number_ or _table_)
* `arg3` - buff id (_number_)
* (`arg4`) - unit id (_string_)  
    default value: "player"
* (`arg5`) - [highlight type](#highlight-type) (_string_)  
    default value: "good"

***

<a name="ShowPower"></a>
**`ShowPower { arg1, arg2, arg3, arg4, arg5 }`**
>Display power on the specified spell (i.e. number of Soul shard
* `arg1` - spell id of spells on which to display the power value (_number_ or _table_)
* `arg2` - power type (_string_)  
    One of the possible suffixes of `SPELL_POWER_` (i.e. "ENERGY")
* (`arg3`) - handler (_function_ or _number_)
    - if of type _number_ then it serves as a lower bound for displaying the power value either as percent (`arg3` is between -1 and 1) or as an absolute value else
    - default value: a _function_ that displays the current power value and highlights when it reaches it's maximum
* (`arg4`) - [highlight type](#highlight-type) (_string_)  
    default value: "flash"
* (`arg5`) - description for the config panel (_string_)  
    default value: "" (if the user supplied a _function_ in `arg3`), multiple possible values else

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
**`Configure { arg1, arg2, arg3, arg4, arg5, arg6, arg7 }`**
>All of the above are shorthands for this
* `arg1` - unique name (_string_)
* `arg2` - description for the options panel (_string_)
* `arg3` - spell id(s) (_number_ or _table_)
* `arg4` - unit id(s) (_string_ or _table_)
* `arg5` - event(s) (_string_ or _table_)
* `arg6` - handler (_function_ or _table_)
* (`arg7`) - provider spell id (_number_ or _table_)

***

### Other
<a name="highlight-type"></a>
**highlight type**
>One of the following:
* "flash" (active overlay)
* "good" (green border)
* "bad" (red border)
* "darken" (darker border)
* "lighten" (lighter border)