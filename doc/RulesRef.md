### Table of contents:
1. [Concepts](#concepts)
1. [User rules](#user-rules)
1. [Documentation Format](#documentation-format)
1. Specific Rules:
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
  1. [ShowStacks](#ShowStacks)
  1. [Configure](#Configure)

### Concepts

World of Warcraft has a pretty complex system of buffs and effects.

Every spell or ability is identified by an unique number, which is called the **spell identifier**, and which is often noted by an hash-number, e.g. #113043 for Omen of Clarity. Sites like wowhead.com and wowdb.com refer to the spells by their spell identifiers, e.g. : http://www.wowhead.com/spell=113043 or http://www.wowdb.com/spells/113043-omen-of-clarity.

In most cases, the ability in the spellbook, the ability in the action bar and the buff or debuff (which are collectively called *aura*) are identicial.

However, sometimes they differ. A passive ability can cause a spell to provide a buff that will in turn modify another ability. For example, in Mists of Pandaria (MoP), the passive ability Omen of Clarity causes Lifebloom to provide the buff Clearcasting, which modifies Regrowth, Wrath and Healing Touch. In AdiButtonAuras, Omen of Clarity is the *provider*, Clearcasting is the *modifier buff* and Regrowth, Wrath and Healing Touch are the *modified spells*.

Finally, in some cases, one given spell can have different spell identifiers depending on the character specialization and glyphs. For example, in Warlords of Draenor (WoD), Omen of Clarity is identified by #113043 for Restoration and by #16864 for Feral.

For checking the spell identifiers, I recommend using the "Debugging Tooltip" option of AdiButtonAuras.

<a name="user-rules"></a>
### User Rules

The user rule panel expects a snippet of code that returns one of several rules.

An example (of a MoP rule) returning one rule:

```lua
-- Display the buff from Glyph of Rejuvenation on the action Nourish.
return BuffAliases {
    50464, -- Nourish
    96206, -- Glyph of Rejuvenation
}
```

Returning several rules:

```lua
return {
	-- Show Glyph of Rejuvenation buff on Nourish
	BuffAliases {
		50464, -- Nourish
		96206, -- Glyph of Rejuvenation
	},
	-- Show Clearcasting buff on Regrowth, Wrath and Healing Touch if the character knows Omen of Clarity
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
>List of buffs cast by anyone on any ally, where only one of that kind is possible (e.g. Soulstone)
* `buff1` ... `buffN` - buff id (_number_)

***

<a name="SharedSimpleDebuffs"></a>
**`SharedSimpleDebuffs { debuff1, ..., debuffN }`**
>List of debuffs cast by anyone on any enemy, where only one of that kind is possible (e.g. Hunter's Mark)
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
    The provider spell ids are the same as the buff ids.

***

<a name="BuffAliases"></a>
**`BuffAliases { spells, buffs }`**
>Shows any of player's `buffs` on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* `buffs` - buff id (_number_ or _table_)

***

<a name="DebuffAliases"></a>
**`DebuffAliases { spells, debuff }`**
>Shows any of player's `debuffs` on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* `debuffs` - debuff id (_number_ or _table_)

>Example:
```lua
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
>Shows any of player's `buffs` on the player on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* `buffs` - buff id (_number_ or _table_)

***

<a name="LongestDebuffOf"></a>
**`LongestDebuffOf { spells, buffs }`**
>Shows the longuest of player's `buffs` on all of `spells`.
* `spells` - spell id (_number_ or _table_)
* `buffs` - buff id (_number_ or _table_)

***

<a name="PassiveModifier"></a>
**`PassiveModifier { passive, spell, buff, unit, highlight }`**
>If `passive` is in player spellbook, highlights `spell` with `highlight` when `buff` is found on `unit`.
* `passive` - passive spell id (_number_)
* `spell` - spell id (_number_ or _table_)
* `buff` - buff id (_number_)
* (`unit`) - [unit id](#unit-id) (_string_)
    default value: "player"
* (`highlight`) - [highlight type](#highlight-type) (_string_)
    default value: "good"

***

<a name="ShowPower"></a>
**`ShowPower { spells, power, handlerOrThreshold, highlight, providers, description }`**
>Displays the specified power on the given spell(s) (e.g. the number of Soul Shards).
>Also creates a second rule to highlight the spell(s) depending on the value; highlight with a hint at maximum by default (i.e. `handlerOrThreshold` is set to 1.0).
* `spells` - spell id(s) of the spell(s) on which to display the power value (_number_ or _table_)
* `power` - power type (_string_ - one of the possible suffixes of `SPELL_POWER_` (e.g. ``"ENERGY"``) or `"COMBO"` for combo points).
* (`handlerOrThreshold`) - handler (_function_ or _number_)
    - if a _number_ is provided, it is interpreted as follows:
        - numbers in the [-1.0;1.0] range indicate a fraction of the maximum, e.g. 0.5 for 50%, else they are taken literally.
        - positive numbers indicate a minimum threshold, e.g. 50 triggers when the power is greater than or equal to 50.
        - negative numbers indicate a maximum threshold, e.g. -50 triggers when the power is less than or equal to 50.
    - default value: a _function_ that displays the current power value and highlights with a hint when it reaches it's maximum
* (`highlight`) - [highlight type](#highlight-type) (_string_)
    default value: "hint"
* (`providers`) - (_number_ or _table_)
    Spell(s) required to enable this rule; defaults to the spell(s) to highlight.
* (`description`) - description for the option panel (_string_)
    default value: nothing if the user supplied a _function_ in `handlerOrThreshold`, else a meaningful description

>Example:
```lua
ShowPower {
	5217, -- Tiger's Fury
	"ENERGY",
	35,
	"darken"
},
```
>This darkens Tiger's Fury when the player has more than 35 energy.

***

<a name="ShowStacks"></a>
**`ShowStacks { spells, aura, maxStacks, unit, handlerOrThreshold, highlight, providers, description }`**
>Display the number of stacks of a given aura (cast by the player) on the specified spell.
>Can also highlight the action depending on the number of stacks; by default highlights with a hint when reaching the maximum.
* `spells` - spell id(s) of the spell(s) on which to display the number of stacks (_number_ or _table_)
* `aura` - spell id of the aura to look for (_number_).
* `maxStacks` - maximum number of stacks to expect (_number_).
* `unit` - the unit to scan for the aura (_string_). If the unit is `"enemy"` the aura is interpreted as a debuff, else it is considered a buff.
    default value: `"player"`
* (`handlerOrThreshold`) - handler (_function_ or _number_)
    - if a _number_ is provided, it is interpreted as follows:
        - numbers in the [-1.0;1.0] range indicate a fraction of the maximum, e.g. 0.5 for 50%, else they are taken literally.
        - positive numbers indicate a minimum threshold, e.g. 50 triggers when the number of stacks is greater than or equal to 50.
        - negative numbers indicate a maximum threshold, e.g. -50 triggers when the number of stacks is less than or equal to 50.
    - default value: a _function_ that displays the current number of stacks and highlights with a hint when it reaches it's maximum
* (`highlight`) - [highlight type](#highlight-type) (_string_)
    default value: "hint"
* (`providers`) - (_number_ or _table_)
    Spell(s) required to enable this rule; defaults to the spell(s) to highlight.
* (`description`) - description for the option panel (_string_)
    default value: nothing if the user supplied a _function_ in `handlerOrThreshold`, else a dmeaningful description

>Example:
```lua
ShowStacks {
	115308, -- Elusive Brew
	128939, -- Elusive Brew (stacking buff)
	15,
	"player",
	10
},
```
>Shows the stacks of Elusive Brew (buff) on the player on Elusive Brew. Highlights with a hint when it is greater than or equal to 10.

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
* `"stacks"` (not really a highlight: shows the number of buff stacks)

<a name="unit-id"></a>
**unit id**
>One of the following:
* one of the [standard unit ids](http://wowpedia.org/World_of_Warcraft_API_Unit_IDs).
* `"ally"` dynamically-resolved ally, depending on button macros, modifier keys, and auto-targetting settings.
* `"enemy"` dynamically-resolved enemy, depending on button macros, modifier keys, and auto-targetting settings.
