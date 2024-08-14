# CombatRegen
### Five Seconds Rule
What stats should your WoW character max? This UI addon seeks to answer this question regarding mana regeneration during combat. Back in the day (especially on TBC), healers were bleeding mana and there was a so-called Five Seconds Rule (FSR) in effect, see https://wowpedia.fandom.com/wiki/Five_second_rule. It means that after casting a spell (more accurately after spending mana) your character's mana regeneration from basic stats (e.g. Spirit) is suppressed for the next 5 seconds. During this period, your regeneration depends mainly on the "Mana per 5 seconds" (MP5) stat and also partially on other attributes (Spirit, Intellect, ...) through various talents and other effects. One may calculate how much mana they regenerate in total during an encounter, as follows:

`total_regen = FSR_regen_rate * time_in_FSR + normal_regen_rate * time_in_normal`

The regen rates are listed in the in-game character tab. This addon tracks how much time during an actual encounter the character spends in the FSR regen mode and normal regen mode, respectively. Then, one may seek to optimize the `total_regen` by making changes to the equipment (regen rates) and/or playstyle (time in regen modes) in the upcoming encounters. If I remember correctly, over around 70 % or more of total time outside FSR was required for Spirit stat to be more efficient (mana-regen-wise) than MP5 with my Holy Priest. The FSR was abandoned in later expansions of the game, switching to in-combat and out-of-combat regen rates instead.

### Usage
Simply type `/cmr` to start, stop and reset. Type `/cmr report` to print the % of time spent in the normal regen mode. When active, the addon shows two status bars: the red bar serves basically as a FSR countdown, the green one shows the share of time in normal regen mode.
