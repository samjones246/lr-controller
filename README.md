# lr-controller
Mod for liminal ranger which adds controller support.

## Installation
Requires [liminal loader](http://www.github.com/samjones246/liminal-loader). Get the latest build of this mod from the releases page and extract it in your mods folder. Don't rename it either of the files.

## Usage
Default Controls (XBOX/PS buttons):
| Action           | Buttons      |
| ---------------- | -----------  |
| Jump             | A/Cross      |
| Advance Dialogue | A/Cross      |
| Return coin      | B/Circle     |
| Interact         | X/Square     |
| Respawn          | Y/Triangle   |
| Use tool         | RT/R2, RB/R1 |
| Use tool alt     | LT/L2, LB/L1 |
| Sprint           | LS Click     |
| Pogo             | D-Pad Up     |
| Hammer           | D-Pad Left   |
| Coin             | D-Pad Right  |
| Spray            | D-Pad Down   |
| Pause            | Start        |
| Objective        | Select       |

In the menu for giving up / upgrading tools, you can choose a tool by pressing the equip button for that tool.

Currently you'll need to use the mouse for navigating the main and pause menus.

## Customising Controls
Controls and sensitivity can be changed by editing `controller_bindings.json`. The file must have the following format:


    {
        "sens_mult": x,
        "toggle_sprint": <true/false>,
        "<action>":["<button>", "<button>", ...],
        "<action>":["<button>", "<button>", ...],
        ...
    }
x is a number greater than 0, specifying the multiplier to be applied to sensitivity. Sensitivity can then be adjusted further in game with the mouse sensitivity slider.


\<action> and \<button> above should be substituted with valid action and button names respectively. These are listed in the tables below.

### Action Names
| Action           | Description               |
| ---------------- | ------------------------- |
| pause            | Toggle the pause menu     |
| objective        | Show current objective    |
| move_jump        | Jump                      |
| reload           | Return coin               |
| Interact         | Interact                  |
| respawn          | Respawn                   |
| equipPogo        | Equip/Unequip Pogo Stick  |
| equipHammer      | Equip/Unequip Pogo Hammer |
| equipCoin        | Equip/Unequip Pogo Coin   |
| equipDust        | Equip/Unequip Pogo Spray  |
| action           | Use Tool                  |
| altAction        | Use Tool Alt              |
| move_sprint      | Hold to sprint            |
| dialogue_advance | Advance Dialogue          |
### Button Names
| Names       | Description   |
| ----------  |-------------- |
| A, CROSS    | A button      |
| B, CIRCLE   | B button      |
| X, SQUARE   | X button      |
| Y, TRIANGLE | Y button      |
| LB, L1      | Left bumper   |
| RB, R1      | Right bumper  |
| LT, L2      | Left trigger  |
| RT, R2      | Right trigger |
| LS, L3      | Left stick    |
| RS, R3      | Right stick   |
| START       | Start button  |
| SELECT      | Select button |
| DPAD_UP     | D-pad up      |
| DPAD_DOWN   | D-pad down    |
| DPAD_LEFT   | D-pad left    |
| DPAD_RIGHT  | D-pad right   |


If you need to use a button which is not listed here, you can use an integer in place of button name string. The integer must be a valid button specifier in accordance with Godot's [JoystickList](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-joysticklist) enum.