Introduction
============

AdiButtonAuras allows you to track buffs and debuffs (also known as "auras") by overlaying the relevant information on top of your Actionbar buttons, like this:

![AdibuttonAuras in action](media/examples.png)

What does it all mean?
======================

As a general rule:

  * Red border (known as "bad" highlight) means a dot on your target with the text giving you the dot's duration ![example of a dot](media/dot.png) 
  * Green border (known as "good" highlight) means a beneficial effect on yourself or a friendly target with the number meaning duration ![example of a buff with duration](media/buff_duration.png) or number of stacks ![example of a buff with stacks](media/buff_stacks.png). If the spell has both, duration will be on the left while stacks will be on the right ![Spell with stacks and duration](media/duration_stacks.png).

**However, there are special cases!**

*Raid buffs* shows the number of players which misses the buff ![Raid buff showing two raid members without stats buff](media/raid_buffs.png).

Some spells like Warlocks' Havoc have custom rules, e.g. red when you the target the enemy affected by Havoc (to remember *not* to attach that target) and green when you target any other enemey.

Other classes have custom rules as well.

**AdiBUttonAuras will also show special events.** 

By making your buttons sparkle, much like the default UI does, only better!

  * It will make interrupts sparckle with how long you have to interrupt ![Interrupt](media/interrupt.png)
  * Hint you when to use certain abilities like Soul Reaper under 35% hp ![Soul Reaper](media/soul_reaper.png)
  * Hint when there is a buff you can purge from an enemy ![purge](media/purge.png)
  * Or show you there is a debuff that you can dispell and its duration ![dispell](media/dispell.png)

Setting up
==========	

AdiButtonAuras comes with prebuilt rules so it is ready to go without additional messing around, but if there is an aura you do not like you can open the options using /adibuttonauras and change the aura settings for the recognized buttons which will be highlighted in green (note in this screenshot [dominos bar addon](http://www.curse.com/addons/wow/dominos) are being used and put on top of the options): 

![Spell options](media/spell_options.png)

**But some of my buttons don't show any aura and in the options aren't even green!**

AdiButtonAuras needs to know about the spell before it puts an aura on its button and unfortunatly there is still a lot of spells that have not been added to the list, if you see one which is not there but should please get in touch on [Github issue tracker](https://github.com/Adirelle/AdiButtonAuras/issues) so it can be added.

Other options
-------------

Additionally there is also there is also several display options, from how long a buff/debuff has to be to show a timer to theme settings which allow you to personalize the look of the text and colors in you have trouble seeing the default ones:
![Spell options](media/theme_options.png)

Getting Involved
================

AdiButtonAuras can always use help, so if you want to give a hand or just know more about the addon check out the [Technical details](https://github.com/Adirelle/AdiButtonAuras/blob/master/README.textile) or check the [project on Github](https://github.com/Adirelle/AdiButtonAuras).
