# Kuxynator's Running Mod

> Walk with *smooth acceleration* or cheat something:
    sprint in *turbo mode*,
    *be faster* if you *zoom out*
	or *ignore* all *obstacles* in hover mode.

## Why do you need this mod

- if you want to run faster than intended
- if you want to walk slower to control the character more precise also if you have 6 exoskeletons installed.
- if you zoom out, you want to move faster (regardless of the character's abilities)

## Features

- Mode Selection: None, Accelerate, Hover, Zoom
  - Mode: Accelerate
    - smooth progressive acceleration
    - turbo modus (needs spiece or coal)
    - configurable with F6/F7
	- configurable speed table *[1.5.0]*
	- adaption for game speed *[1.5.0]*
	- UPS correction factor *[1.5.0]*
  - Mode: Hover
  	- like mode Accelerate
	- needs spice to activate (or coal)
	- no obstacles. Floating above water, over cliffs, over all objects. 
	- ignores equipment and floor condition 
  - Mode: Zoom
    - speed depends on zoom level (requieres [Kux-Zooming](https://mods.factorio.com/mod/Kux-Zooming))
	- no obstacles (if hover mode is activated)
- Toggle Hover mode on/off (default key: H)
- Toggle Zoom mode on/off (default key: Z) *[1.5.0]*
- Use of Spice (if mod [Nauvis Melange](https://mods.factorio.com/mod/nauvis-malange) is active) or coal
- To activate the old behavior (w/o spice or coal) active Cheat Mode in map settings

*In a later version of this mod the modes will be less cheaty. You have to research the technologies first and need special fuel for turbo.*

## How to use

You can toogle the mode with keys (H and Z by default)
H: toogles the Hover mode on/off
Z: toogles the Zoom mode on/off

In the player mod settings you can select your prefered mode:
- None, 
- Accelerate (default), 
- Hover or 
- Zoom

### Mode *Accelerate*, *Hover*

use F6/F7 to control the max speed and the acceleration

- Press F6 to toggle the max speed
    - *`0`*    normal spped (default)
    - *`>`*    medium speed
    - *`>>`*   high speed
- Press F7 to toggle the acceleration mode
    - *`-`*    always slow speed (initial speed)
    - *`<`*    accelerating up to max speed (default)
    - *`*`*    always max speed

In *hover mode* all obstacles and floor conditions will be ignored. 
You can floating above water, over cliffs, really over all obstacles.
The equipment (exosceleton) is useless in this mode.

### Mode **Zoom**

Use mouse wheel to zoom out and get faster or zoom in and get slower.

*Update [1.2.1]* In player settings *'Zoom: Speed Modificator'* you can tune the base speed. 
The value '1' corresponds to the normal walking speed without equipment.
A value of 2..3 is practicable. 

**NOTE:** The mod [Kux-Zooming](https://mods.factorio.com/mod/Kux-Zooming) must be active.

### Settings

#### Initial Speed Factor

With the Initial Speed Factor you can define the speed at which the acceleration starts. The initial speed is constant for the first 15 ticks
The initial speed is independent of the floor condition (tile walking speed modifier). So if you walk over concrete, the speed is not increased.

#### Speed Table (Speed 1..3)

For each speed level (toggle with F6) you can define the maximum speed.
A value of 1 means 0.15 tiles/tick (this is the base speed: no movement bonus und tile walking modifier of 1). 

#### UPS adjustment

A factor to adjust the speed values. You can also input your current UPS value (for normal game speed). 
This is usefully if you have to play with slower UPS but don't want to move slower.

#### Adaption for game speed
Slower: The walking speed keeps constant also if your game speed is slower.
Faster: The walking speed keeps constant also if your game speed is faster. Does not pay attention whether the game really runs faster (UPS limit reached) Only the game speed factor will be considered.

#### Zoom Speed Modificator

For faster walking speed in zoom mode increase this value.

#### Default character running speed modifier

This mod uses the  player character running speed modifier to control the resulting walking speed. If the mod does not need do control the speed, this value is set to the players character. (default: 0)

## Removing this mod

Before you deactivate/delete this mod the default speed modifier must be restored. to do this:

- in global settings uncheck the option "Enable"
	**NOTE:** after unchecking do resume the game! So the mod can reset the players to default. Do not exit the game directly, the players will be slow!
- or call this command: `/c remote.call("Kux-Running", "off")`

## Existing mods

I know there are at least 2 fabulous mods who do the same, but

 - the mods do not run together because they use the same technique, so both are in conflict

In the last years I had to play only with one them. Now I am finally able to use the advantages of both at the same time. 

## Credits
Inspired by two fabulous mods
- RunSpeedToggle by Omnifarious 
- progressive Running (smooth acceleration) by binbinhfr 