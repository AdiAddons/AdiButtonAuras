AdiButtonAuras
==============

Display auras, and more, on action buttons.

AdiButtonAuras is a rewrite of Inline Aura, but with different [design decisions](https://github.com/Adirelle/AdiButtonAuras/blob/master/doc/Design.md) based on my experience on the latter.

AdiButtonAuras uses a set of rules that apply to one or more spells. Each rule can track an aura on one or more unit and changes the display of the spell accordingly.

AdiButtonAuras has several custom rules to suggest using spells at meaningful times. By default, these suggestions are displayed using a rotary, shinning star on the buttons.

AdiButtonAuras smartly track raid/group buffs: it shows the number of *missing* buffs and the duration of the shortest one, taking into account equivalent buffs.

Getting started
---------------

Before heading straigth into a raid and/or playing with the options, you may want to read this short [Getting started guide](https://github.com/Adirelle/AdiButtonAuras/blob/master/doc/GettingStarted.md), which will introduce you with the basics of AdiButtonAuras.

Options
-------

#### Global options

 * do not show flashing border for actions on cooldown (do not affect Blizzard flash),
 * do not show flashing border for actions out of combat (do not affect Blizzard flash),
 * select how suggestions are displayed (hidden, rotary star or flashing border),

#### Spell/item options

 * disable the spell,
 * "promote to flash": replace any highlight with the flashing border animation,
 * inverted highlight: highlight the spell when it is missing,
 * select which rules should apply.

#### Theme options

 * customizable texts: font, format, size and colors.
 * change the colors of "good" and "bad" highlights,
 * select the highlight amongst 10 textures,
 
#### User-defined rules

AdiButtonAuras allows you to enter and save your own rules, with full access to [its API](https://github.com/Adirelle/AdiButtonAuras/blob/master/doc/Rules.textile). Easy sharing of those rules is planned.

Supported classes and specializations
-------------------------------------

Most of the simple buffs are supported through the libraries:

 * most class, tradeskill and racial spells using [LibPlayerSpells-1.0](https://github.com/Adirelle/LibPlayerSpells-1.0),
 * crowd-control spells using [DRData-1.0](https://github.com/Adirelle/DRData-1.0),
 * dispel spells using [LibSpellbook-1.0](https://github.com/Adirelle/LibSpellbook-1.0),
 * trinket, enchantment and item buffs using [LibDispellable-1.0](https://github.com/Adirelle/LibDispellable-1.0/).

Special cases and hints are handled using customized rules, see below.

There is also a default rule for *items* not supported by LibItemBuffs-1.0.

FAQ
---

#### When I try to configure a spell, the button is dimmed and I cannot chose it. Why ?

AdiButtons has no rule about this spell. Consider [filling an issue](https://github.com/Adirelle/AdiButtonAuras/issues).

#### What do some rules ending with some obscure characters between brackets, like [LPS-DRUID-5.4.1-7] ?

These are references to the libraries AdiButtonAuras used to create the rule.

 * LPS-XXX-A.B.C-N: data from [LibPlayerSpells-1.0](https://github.com/Adirelle/LibPlayerSpells-1.0) for class XXX, patch A.B.C, Nth revision. E.g. "[LPS-DRUID-5.4.1-7]" stands for "rule created accordingly to LibPlayerSpells-1.0 data for druid, patch 5.4.1, 7th revision."
 * DR-N: [DRData-1.0](https://github.com/Adirelle/DRData-1.0), Nth revision.
 * LSB-N: [LibSpellbook-1.0](https://github.com/Adirelle/LibSpellbook-1.0), Nth revision.
 * LD-N: [LibDispellable-1.0](https://github.com/Adirelle/LibDispellable-1.0/), Nth revision.

#### Are you going to support button skinning, e.g. Masque ?

No, unless Masque supports to skin partial buttons.

#### Are you going to support ElvUI ?

AdiButtonAuras should work with ElvUI. I am not going to support its skin though.

#### Are you going to add a configuration panel to create custom rules ?

Not in the way InlineAura did it. At best will it support custom rules written in Lua using the DSL (and I make no promise).

Acknowledgment
--------------

Thanks to the following people for testing and contributing to AdiButtonAuras and related libraries.

Contributors (in alphabetical order):

* [arcadepro](https://github.com/arcadepro),
* [ckaotik](https://github.com/ckaotik),
* [dafzor](https://github.com/dafzor),
* [mjmurray88](https://github.com/mjmurray88),
* [Rainrider](https://github.com/Rainrider).

License
-------

AdiButtonAuras is licensed under the GNU General Public License version 3.
