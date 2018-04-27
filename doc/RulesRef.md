### Table of contents:
1. [Concepts](#concepts)
1. [User rules](#user-rules)
1. [Documentation Format](#documentation-format)
1. [Specific Rules](#specific-rules):
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
    1. [ShowHealth](#ShowHealth)
    1. [ShowStacks](#ShowStacks)
    1. [Configure](#Configure)

### Concepts

World of Warcraft has a pretty complex system of auras and effects.

Every spell or ability is identified by an unique number, which is called the **spell identifier**, and which is often noted by an hash-number, e.g. #113043 for Omen of Clarity. Sites like wowhead.com and wowdb.com refer to the spells by their spell identifiers, e.g. : http://www.wowhead.com/spell=113043 or http://www.wowdb.com/spells/113043.

In most cases the ability in the spellbook, the ability on the action bar and the buff or debuff (which are collectively called *aura*) are identicial.

However, sometimes they differ. A passive ability can cause a spell to provide a buff that will in turn modify another ability. For example, in Legion, the passive ability Omen of Clarity (for Restoration Druids) causes Lifebloom to provide the buff Clearcasting, which modifies Regrowth. In AdiButtonAuras, Omen of Clarity is the *provider*, Clearcasting is the *modifier buff* and Regrowth is the *modified spell*.

Finally, in some cases, one given spell can have different spell identifiers depending on the character specialization. For example, in Legion, Omen of Clarity is identified by #113043 for Restoration and by #16864 for Feral druids.

For checking the spell identifiers you can use the "Debugging Tooltip" option of AdiButtonAuras.

<a name="user-rules"></a>
### User Rules

The user rule panel expects a snippet of code that returns one or several rules.
Please bear in mind that most of the examples are from past expansions. They are meant to help you write your own rules, not to be literally used.

An example returning one rule:

```lua
-- Display the buff from Glyph of Rejuvenation on the action Nourish
return BuffAliases {
    50464, -- Nourish
    96206, -- Glyph of Rejuvenation
}
```

Returning several rules:

```lua
return {
	-- Show the buff from Glyph of Rejuvenation on Nourish
	BuffAliases {
		50464, -- Nourish
		96206, -- Glyph of Rejuvenation
	},
	-- Show the Clearcasting buff on Regrowth, Wrath and Healing Touch if the character knows Omen of Clarity
	PassiveModifier {
		113043, -- Omen of Clarity
		{
			8936, -- Regrowth
			5176, -- Wrath
			5185, -- Healing Touch
		},
		16870, -- Clearcasting
		"player",
		"flash"
	}
}
```

<a name="documentation-format"></a>
### Documentation format

`RuleName { arg1, arg2, ..., argN }`
* `arg#` - required argument (_type_)
* (`arg#`) - optional argument (_type_)

<a name="specific-rules"></a>
### Specific Rules

<a name="SimpleBuffs"></a>
**`SimpleBuffs { buff1, ..., buffN }`**
>List of buffs cast by the player on any ally.
* `buff1` ... `buffN` - buff id (_number_)

***

<a name="SimpleDebuffs"></a>
**`SimpleDebuffs { debuff1, ..., debuffN }`**
>List of debuffs cast by the player on any enemy.
* `debuff1` ... `debuffN` - debuff id (_number_)

***

<a name="SharedSimpleBuffs"></a>
**`SharedSimpleBuffs { buff1, ..., buffN }`**
>List of buffs cast by anyone on any ally. Meant for situations where only one of that kind is possible (e.g. Soulstone)
* `buff1` ... `buffN` - buff id (_number_)

***

<a name="SharedSimpleDebuffs"></a>
**`SharedSimpleDebuffs { debuff1, ..., debuffN }`**
>List of debuffs cast by anyone on any enemy. Meant for situations where only one of that kind is possible (e.g. Forbearance)
* `debuff1` ... `debuffN` - debuff id (_number_)

***

<a name="SelfBuffs"></a>
**`SelfBuffs { buff1, ..., buffN }`**
>List of buffs cast by the player on the player
* `buff1` ... `buffN` - buff id (_number_)

***

<a name="PetBuffs"></a>
**`PetBuffs { buff1, ..., buffN }`**
>List of buffs cast by the player on his/her pet
* `buff1` ... `buffN` - buff id (_number_)

***

<a name="BuffAliases"></a>
**`BuffAliases { spells, buffs }`**
>Shows any of player's `buffs` on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* (`buffs`) - buff id (_number_ or _table_). Defaults to `spells` if omitted

***

<a name="DebuffAliases"></a>
**`DebuffAliases { spells, debuffs }`**
>Shows any of player's `debuffs` on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* (`debuffs`) - debuff id (_number_ or _table_). Defaults to `spells` if omitted

***

<a name="SelfBuffAliases"></a>
**`SelfBuffAliases { spells, buffs }`**
>Shows any of player's `buffs` on the player on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* (`buffs`) - buff id (_number_ or _table_). Defaults to `spells` if omitted

***

<a name="LongestDebuffOf"></a>
**`LongestDebuffOf { spells, debuffs }`**
>Shows the longuest of player's `buffs` on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* (`debuffs`) - debuff id (_number_ or _table_). Defaults to `spells` if omitted

***

<a name="PassiveModifier"></a>
**`PassiveModifier { passive, spells, buff, unit, highlight }`**
>Shows `highlight` on `spells` when `buff` is found on `unit`, if `passive` is known to the player.
* `passive` - passive spell id (_number_)
* `spells` - spell id (_number_ or _table_)
* `buff` - buff id (_number_)
* (`unit`) - [unit id](#unit-id) (_string_). Default value: "player"
* (`highlight`) - [highlight type](#highlight-type) (_string_). Default value: "good"

***

<a name="ShowPower"></a>
**`ShowPower { spells, power, handlerOrThreshold, highlight, providers, description }`**
>Shows the amount of `power` on `spells` and highlights `spells` depending on the amount of `power`.
* `spells` - spell id (_number_ or _table_)
* `power` - power type (_string_ - one of the keys of `Enum.PowerType` (e.g. `"Energy"` or `"SoulShards"`).
* (`handlerOrThreshold`) - specifies the conditions that should be met to highlight `spells` (_function_ or _number_)
    - if a _number_ is provided, it is interpreted as follows:
        - numbers in the [-1.0;1.0] range indicate a fraction of the maximum (e.g. 0.5 for 50%), else they are taken literally.
        - positive numbers indicate a minimum threshold, e.g. 50 triggers when the displayed value is greater than or equal to 50.
        - negative numbers indicate a maximum threshold, e.g. -50 triggers when the displayed value is less than or equal to 50.
    - if a _function_ is provided, it is only called if `max ~= 0` and gets the following arguments passed:
        - `current` - current amount of `power` (_number_)
        - `max` - the maximum possible amount of `power` (_number_)
        - `model` - see `model` under [handlers](./Rules.md#handlers) (_table_)
        - `highlight` - the [`highlight`](#highlight-type) passed to ShowPower or `"hint"` if it has been omitted (_string_)
    - default value: a _function_ that displays the current power value and highlights with a hint when it reaches its maximum
* (`highlight`) - [highlight type](#highlight-type) (_string_). Default value: "hint"
* (`providers`) - Spell id(s) of the spell(s) required to enable this rule (_number_ or _table_). Defaults to the `spells` if omitted.
* (`description`) - description for the options panel (_string_). Only used if a _function_ has been provided for `handlerOrThreshold`. Auto-generated else.

>Example:
```lua
ShowPower {
	5217, -- Tiger's Fury
	"Energy",
	35,
	"darken"
},
```
>This darkens Tiger's Fury when the player has more than 35 energy.

***

<a name="ShowHealth"></a>
**`ShowHealth { spells, unit, handlerOrThreshold, highlight, providers, description }`**
>Shows the health of the specified unit on `spells` and highlights `spells` depending on the health value.
* `spells` - spell id (_number_ or _table_)
* `unit` - the [unit](#unit-id) whose health is to be displayed (_string_)
* (`handlerOrThreshold`) - specifies the conditions that should be met to highlight `spells` (_function_ or _number_)
    - if a _number_ is provided, it is interpreted as follows:
        - numbers in the [-1.0;1.0] range indicate a fraction of the maximum (e.g. 0.5 for 50%), else they are taken literally.
        - positive numbers indicate a minimum threshold, e.g. 50 triggers when the displayed value is greater than or equal to 50.
        - negative numbers indicate a maximum threshold, e.g. -50 triggers when the displayed value is less than or equal to 50.
    - if a _function_ is provided, it is only called if `unit` exists and `max ~= 0` and gets the following arguments passed:
        - `current` - the unit's current amount of health (_number_)
        - `max` - the unit's maximum possible amount of health (_number_)
        - `model` - see `model` under [handlers](./Rules.md#handlers) (_table_)
        - `highlight` - the [`highlight`](#highlight-type) passed to ShowHealth or `"hint"` if it has been omitted (_string_)
    - default value: a _function_ that displays the current health value and highlights with a hint when it reaches its maximum
* (`highlight`) - [highlight type](#highlight-type) (_string_). Default value: "hint"
* (`providers`) - Spell id(s) of the spell(s) required to enable this rule (_number_ or _table_). Defaults to the `spells` if omitted.
* (`description`) - description for the options panel (_string_). Only used if a _function_ has been provided for `handlerOrThreshold`. Auto-generated else.

***

<a name="ShowStacks"></a>
**`ShowStacks { spells, aura, maxStacks, unit, handlerOrThreshold, highlight, providers, description }`**
>Shows the number of stacks of a given aura (cast by the player) on `spells` and highlights `spells` depending on the number of stacks.
* `spells` - spell id (_number_ or _table_)
* `aura` - spell id of the aura whose stacks are to be displayed (_number_).
* `maxStacks` - maximum number of stacks to expect (_number_ or _function_). Defaults to a function that returns `math.huge` if nil
* `unit` - the [unit](#unit-id) to scan for the aura (_string_). If the unit is `"enemy"` the aura is considered a debuff, else - a buff
* (`handlerOrThreshold`) - specifies the conditions that should be met to highlight `spells` (_function_ or _number_)
    - if a _number_ is provided, it is interpreted as follows:
        - numbers in the [-1.0;1.0] range indicate a fraction of the maximum (e.g. 0.5 for 50%), else they are taken literally.
        - positive numbers indicate a minimum threshold, e.g. 50 triggers when the number of stacks is greater than or equal to 50.
        - negative numbers indicate a maximum threshold, e.g. -50 triggers when the number of stacks is less than or equal to 50.
    - if a _function_ is provided, it is only called if `unit` exists and `max ~= 0` and gets the following arguments passed:
        - `current` - the current amount of stacks of `aura` (_number_)
        - `max` - the maximum possible amount of stacks of `aura` (_number_)
        - `model` - see `model` under [handlers](./Rules.md#handlers) (_table_)
        - `highlight` - the [`highlight`](#highlight-type) passed to ShowStacks or `"hint"` if it has been omitted (_string_)
    - default value: a _function_ that displays the current number of stacks and highlights with a hint when it reaches its maximum
* (`highlight`) - [highlight type](#highlight-type) (_string_)  
  default value: "hint"
* (`providers`) - Spell id(s) of the spell(s) required to enable this rule (_number_ or _table_). Defaults to the `spells` if omitted.
* (`description`) - description for the options panel (_string_). Only used if a _function_ has been provided for `handlerOrThreshold`. Auto-generated else.

***

<a name="Configure"></a>
**`Configure { key, description, spells, units, events, handlers, providers }`**
>This allows to create a highly customized rule, that affects `spells`, if any of `providers` is known by the player.
* `key` - unique string, used to disable the rule (_string_)
* `description` - description for the options panel (_string_)
* `spells` - spell id(s) (_number_ or _table_)
* `units` - [unit id(s)](#unit-id) (_string_ or _table_)
* `events` - event(s) (_string_ or _table_)
* `handlers` -  handler (_function_ or a _table_)
* (`providers`) - provider spell id (_number_ or _table_). Defaults to `spells` if omitted

***

### Other
<a name="highlight-type"></a>
**highlight type**
>One of the following:
* `"flash"` (active overlay)
* `"good"` (green border)
* `"bad"` (red border)
* `"darken"` (darkens the button)
* `"lighten"` (lightens the button)
* `"hint"` (displays a rotary star)
* `"stacks"` (not really a highlight: shows the number of aura stacks)

<a name="unit-id"></a>
**unit id**
>One of the following:
* one of the [standard unit ids](http://wow.gamepedia.com/UnitId#Base_Values).
* `"ally"` dynamically-resolved ally, depending on button macros, modifier keys, and auto-targeting settings.
* `"enemy"` dynamically-resolved enemy, depending on button macros, modifier keys, and auto-targeting settings.
