AdiButtonAuras
==============

**_Display auras, and more, on action buttons._**

AdiButtonAuras is a rewrite of Inline Aura, but with different [design decisions](https://github.com/Adirelle/AdiButtonAuras/blob/master/doc/Design.md) based on my experience with the latter.

AdiButtonAuras uses a set of rules that apply to one or more spells. Each rule can track an aura on one or more units and change the display of the spell accordingly.

AdiButtonAuras has several custom rules to suggest using spells at meaningful times. By default, these suggestions are displayed using a rotary, shinning star on the associated action buttons. These can be disabled.

Development version build status: [![Build Status](https://travis-ci.org/AdiAddons/AdiButtonAuras.svg)](https://travis-ci.org/AdiAddons/AdiButtonAuras)

Getting started
---------------

Before heading straight into a raid and/or playing with the options, you may want to read this short [Getting started guide](https://github.com/AdiAddons/AdiButtonAuras/blob/master/doc/GettingStarted.md), which will introduce you to the basics of AdiButtonAuras.

Options
-------

#### Global options

 * do not show flashing border for actions on cooldown (does not affect Blizzard flash)
 * do not show flashing border for actions out of combat (does not affect Blizzard flash)
 * select how suggestions are displayed (hidden, rotary star or flashing border)

#### Spell/item options

 * disable the spell
 * Show flash instead: replace any highlight with the flashing border animation
 * Inverted highlight: highlight the spell when it is missing
 * select which rules should apply

#### Theme options

 * customizable texts: font, size and colors
 * change the colors of the "good" and "bad" highlights
 * select the highlight amongst 11 different textures

#### User-defined rules

AdiButtonAuras allows you to enter and save your own rules, using a Lua-based language. Take a look at the [rule reference](https://github.com/AdiAddons/AdiButtonAuras/blob/master/doc/RulesRef.md) to see what is available.

TODOs
-----

 * sharing of custom rules in-game using hyperlinks, and out-of-game using copy-pastable strings.
 * better documentation with more examples about custom rules.

Supported classes and specializations
-------------------------------------

Most of the simple (de)buffs are supported through embedded libraries:

 * most class and racial spells using [LibPlayerSpells-1.0](https://github.com/AdiAddons/LibPlayerSpells-1.0),
 * crowd-control spells using [LibPlayerSpells-1.0](https://github.com/AdiAddons/LibPlayerSpells-1.0),
 * dispel spells using [LibPlayerSpells-1.0](https://github.com/AdiAddons/LibPlayerSpells-1.0),
 * trinket, enchantment and item buffs using [LibItemBuffs-1.0](https://github.com/AdiAddons/LibItemBuffs-1.0/).

Special cases and hints are handled using customized rules, see below.

There is also a default rule for *items* not supported by LibItemBuffs-1.0.

FAQ
---

**When I try to configure a spell, the button is dimmed and I cannot choose it. Why?**

AdiButtons has no rule about this spell yet. Consider [filling an issue](https://github.com/AdiAddons/AdiButtonAuras/issues).

**Why are some rules ending with some obscure characters between brackets, like [LPS-DRUID-5.4.1-7]?**

These are references to the libraries AdiButtonAuras used to create the rule.

 * LPS-XXX-A.B.C-N: data from [LibPlayerSpells-1.0](https://github.com/AdiAddons/LibPlayerSpells-1.0) for class XXX, patch A.B.C, Nth revision. E.g. "[LPS-DRUID-5.4.1-7]" stands for "rule created accordingly to LibPlayerSpells-1.0 data for druid, patch 5.4.1, 7th revision."
 * LSB-N: [LibSpellbook-1.0](https://github.com/AdiAddons/LibSpellbook-1.0), Nth revision.
 * LIB-N-XXX: [LibItemBuffs-1.0](https://github.com/AdiAddons/LibItemBuffs-1.0/), Nth revision, XXX data version

**Are you going to support ElvUI?**

AdiButtonAuras should work with ElvUI. I am not going to support its skin though.

**Are you going to add a configuration panel to create custom rules?**

Not in the way InlineAura did it. However you can create custom rules in-game using the Lua API.

Contributions & feedback
------------------------

The project is open-source and [hosted on github.com](https://github.com/AdiAddons/AdiButtonAuras). You can report issues there. Pull request are also welcome. Adirelle often hangs around on the freenode IRC network in the #wowace channel.

**Before reporting issues**

 * Please check if any errors happened and paste the exact error messages in the issue.
 * Open the configuration panel, check "Debugging tooltip" and look for the spell identifier by hovering the spell icon in the spellbook, on your action bars and in the (de)buff display. Report these numbers in the issue.
 * Regarding flashing, disable AdiButtonAuras and check if the unwanted behavior is caused by the default UI. Please do not report issues caused by the default UI.

Acknowledgment
--------------

Thanks to the following people for testing and contributing to AdiButtonAuras and related libraries.

Contributors (in alphabetical order):

* [arcadepro](https://github.com/arcadepro),
* [ckaotik](https://github.com/ckaotik),
* [dafzor](https://github.com/dafzor),
* [nomoon](https://github.com/nomoon),
* [mjmurray88](https://github.com/mjmurray88),
* [Rainrider](https://github.com/Rainrider).

License
-------

AdiButtonAuras is licensed under the GNU General Public License version 3.
