# Rule API

The rules are hard-coded using a pretty simple [Domain Specific Language](https://en.wikipedia.org/wiki/Domain_specific_language) built on top of Lua.

Each rule specifies the spells to modify, the units and events to watch and one or more handlers. Several rules about the same spell are merged together, or thrown away if the character does not know the spell.

Each time one of the events is triggered for one of the units, the handlers are called to update the state of the associated button.

A set of convenient functions is provided to easily configure most spells. If a more specific task is needed, Lua can be used (see interrupt spells).

## Adding rules

Rules are added by registering a function using `AdiButtonAuras_RegisterRules`. This function is called once and should return a table of functions. These functions are called each time the player spells change, to find out which spells should be watched.

The minimal `addon.CreateRules()` is this:
```lua
AdiButtonAuras_RegisterRules(function()
    return {} -- No rules
end)
```

## Rule anatomy

A rule is built around 4 elements : spells, units, events and handlers.

### Spells

The spell the rule applies to. These are numerical spell identifiers, which can be found in wowhead or wowdb links, e.g. the link of Charge on wowhead is http://www.wowhead.com/spell=100 and http://www.wowdb.com/spells/100-charge for wowdb. The number in that link, 100, is the identifier of Charge. When an action button holds a spell, AdiButtonAuras uses its identifier to select the rules to apply.

Different variants of a spell can exist because of a specialization, a talent or a glyph. Sometimes they have different spell identifiers. In that case, if a rule should apply to all variants, all spell identifiers should be listed.

### Units

A list of [UnitIds](http://wow.gamepedia.org/UnitId) to watch. This is not always the target of the spell itself. Depending on the rule, you may want to watch another unit (quite often `player`) to look for a buff that could modify the spell. For example, warlocks' Backdraft is a player buff that reduces the casting time and cost of Incinerate, so a rule showing the number of Backdraft stacks on Incinerate should watch "player" and not the target of Incinerate.

In addition to the [standard UnitIds](http://wow.gamepedia.org/UnitId#Base_Values), AdiButtonAuras accepts two special UnitIds. They are resolved dynamically using the current target and the UI settings that affect targeting (self and focus keybindings, target self by default). Macro conditionals including, `@unitId`, should be detected and used.

Here are the two special UnitIds:

* `"ally"`: `"target"` if the player can help it else `"player"`.
* `"enemy"`: `"target"` if the player can attack it else `""` (no one).

### Events

A list of [events](http://wow.gamepedia.org/Events) indicating that the data may have changed and should be refreshed. Events starting with `UNIT_` that do not concern one of the UnitIds of the rule are ignored.

The most common event is `UNIT_AURA`, since we are watching for auras.

### Handlers

The handlers are functions called to refresh the data. Their signature is `function(units, model)`, where:

* `units` contains an map of UnitId to actual UnitId. It is mainly useful for `units.ally` and `units.enemy`, that are resolved for the action button when they are listed in the rule. If none of these were listed, or if the rule watches for a fixed unit, e.g. `"player"`, this argument must be ignored.
* `model` is a table containing the data to display on the spell. The handler should update its attributes.

`model` has five attributes:

* `.expiration`: the expiration time of the (de)buff, like the return value of [GetTime()](http://wow.gamepedia.org/API_GetTime), or the 7th return value of [UnitAura](http://wow.gamepedia.org/API_UnitAura). This is used to display a countdown on the button. The default, 0, means "never expires".
* `.count`: the number of stacks of the (de)buff, like the 3rd return value of [UnitAura](http://wow.gamepedia.org/API_UnitAura). The default, 0, means "no stack".
* `.highlight`: an effect to apply to the button, amongst `"good"` (green border), `"bad"` (red border), `"flash"` (glowing animation), `"hint"` (rotating star animation), `"lighten"` (lighter border) and `"darken"` (darker border). Any other value means "no highlight".
* `.hint`: an effect to apply to the button (spark animation inside the button) that is intended to be visually not as strong as the glowing animation for "flash".
* `.flash`: an effect to apply to the button (glowing animation). Intended as a replacement of `model.highlight = "flash"`, so that it could be shown together with the good/bad border.

If several handlers, possibly from different rules, apply to the same spell, they are called in order of definition. Latter handlers could see the results of previous ones in `model`. No assumptions are made about how they handle existing values. Most of the time they just overwrite them.

## Restricted Lua environment

The rule-defining functions only have access to a restricted set of WoW API functions. These are all "read-only" functions. The exact list is available in [RuleDSL.lua](../core/RuleDSL.lua#L589).

A set of helpers is also available to minimize the effort when creating new rules (see [RulesRef.md](RulesRef.md)).

The other constants and functions are useful only if you have to write your own customized rules using [`Configure`](RulesRef.md#Configure).

### Constants

- `L` - the localization table, e.g. `L["flash"]`
- `PLAYER_CLASS` - english class name of the player.

### Functions

#### Debug(...)

#### DescribeHighlight(highlight)

Returns a localized description of a highlight.

e.g. `DescribeHighlight("good")` returns `show the "good" border`

#### DescribeFilter(filter)

Returns a localized description of UnitAura filter.

e.g. `DescribeFilter("HELPFUL PLAYER")` returns `your buff` (assuming an english client)

#### DescribeAllTokens(unit1, ..., unitN)

Returns a localized description of the unit ids.

e.g. `DescribeAllTokens('player', 'pet')` returns `yourself` and `your pet` (assuming an english client)

#### DescribeAllSpells(spellId1, ..., spellId2)

Returns the localized names of the spells.

#### DescribeLPSSource(category)

Returns a source tag for LibPlayerSpell-1.0 category, including patch number and data revision.

#### BuildDesc(filter, highlight, tokens, spells)

Returns a localized description using the given arguments.

#### BuildKey(...)

Returns a string suitable as the key argument of [`Configure`](RulesRef.md#Configure).

#### BuildAuraHandler_Single(filter, highlight, unit, buff)

Returns a function suitable as rule handler, that will `highlight` the button if `buff` is found on `unit`, restricted by `filter`.

This function returns `true` if `buff` has been found.

#### BuildAuraHandler_Longest(filter, highlight, unit, buffs)

Returns a function suitable as rule handler, that will `highlight` the button with the longest of `buffs` found on `unit` restricted by `filter`.

This function returns `true` if one of `buffs` has been found.

#### BuildAuraHandler_FirstOf(filter, highlight, unit, buffs)

Returns a function suitable as rule handler, that will `highlight` the button with the first of `buffs` found on `unit` restricted by `filter`.

This function returns `true` if one of `buffs` has been found.
