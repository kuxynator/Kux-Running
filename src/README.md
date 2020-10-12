# Kuxynator's Running Mod

> Walk with *smooth acceleration* or cheat something:
    sprint in *turbo mode*,
    *be faster* if you *zoom out*
	or *ignore* all *obstacles* in hover mode.

## Features

- Mode Selection: None, Accelerate, Hover, Zoom
  - Mode: Accelerate
    - smooth progressive acceleration
    - turbo modus (cheat)
    - configurable with F6/F7
  - Mode: Hover
  	- like mode Accelerate
	- no obstacles. Floating above water, over cliffs, over all objects. 
	- ignores equipment and floor condition 
  - Mode: Zoom
    - speed depends on zoom level (requieres [Kux-Zooming](https://mods.factorio.com/mod/Kux-Zooming))
	- no obstacles (if hover mode is available)

[new in 1.3.0]

- Toggle Hover mode on/off (H)
- Hover mode needs Spice (if mod [Nauvis Malange](https://mods.factorio.com/mod/nauvis-malange) is present) or coal
- To activate the old behavior (w/o spice or coal) active Cheat Mode in map settings

*In a later version of this mod the modes will be less cheaty. You have to research the technologies first and need special fuel for turbo.*

## How to use

In the player mod settings you can select your prefered mode:
- None, 
- Accelerate (default), 
- Hover or 
- Zoom

### Mode *Accelerate*, *Hover*

use F6/F7 to control the acceleration

- Press F6 to toggle the turbo mode (cheat)
    - *`0`*    off (default)
    - *`>`*    Turbo
    - *`>>`*  Bi-Turbo
- Press F7 to toggle the acceleration mode
    - *`-`*    Slow speed, no acceleration
    - *`<`*    progressive accelerating up to max speed (default)
    - *`*`*    max speed

In *hover mode* all obstacles and floor conditions will be ignored. 
You can floating above water, over cliffs, really over all obstacles.
The equipment (exosceleton) is useless in this mode.

### Mode **Zoom**

Use mouse wheel to zoom out and get faster or zoom in and get slower.

*Update [1.2.1]* In player settings *'Zoom: Speed Modificator'* you can tune the base speed. 
The value '1' corresponds to the normal walking speed without equipment.
A value of 2..3 is practicable. 

**NOTE:** The mod [Kux-Zooming](https://mods.factorio.com/mod/Kux-Zooming) must be active.

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