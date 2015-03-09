Design decisions
================

Separate button overlays
------------------------

A separate button overlay is created for each button, with border texture, texts and glowing animation.

*Pro*: avoid tainting the action buttons, which could cause ADDON_BLOCKED errors. This also reduces complexity, i.e. possibility of bugs.

*Con*: custom third-party action buttons (ElvUI) are NOT supported. However, AdiButtonAuras fully supports Dominos and Bartender4, and should function with any addon using the stock action buttons or LibActionButton-1.0.

Hard-coded rules
----------------

The rules are hard-coded using a pretty simple [Domain Specific Language](https://en.wikipedia.org/wiki/Domain_specific_language) built on top of Lua.

Each rule specifies the spells to modify, the units and events to watch and one or more handlers. Several rules about the same spell are merged together or thrown if the character doesn't know the spell.

Each time an event is triggered for one of the units, the handlers are called to update the state of the associated button.

A set of convenient functions is provided to easily configure most spells. If a more specific task is needed, Lua can be used (e.g. interrupt spells).

*Pro*: far more powerful than the Inline Aura engine. This allows to show data from one unit merged with the stat of another one, if need be.

*Con*: there is no way to configure this using a GUI.

No spell auto-discovery
-----------------------

AdiButtonAuras only shows data for existing rules. It does not try to guess what to show.

*Pro*: avoid showing wrong data.

*Con*: all spells of relevance for all classes should be listed.

Using spell ids instead of spell names
--------------------------------------

AdiButtonAuras uses the spells' numerical identifiers instead of their names to search for applicable rules.

*Pro*: avoid showing information on a wrong spell that has the same name as the intended one.

*Con*: spell ids are sometimes different depending on shapeshift forms, glyphs or talents. All of them should be listed.

Embedded BugGrabber
-------------------

[BugGrabber](http://www.curse.com/addons/wow/bug-grabber) is shipped with AdiButtonAuras. You can install [BugSack](http://www.curse.com/addons/wow/bugsack) to have a more user-friendly display of errors.
