# Amnesiac Passenger

## Overview

Welcome to the `Amnesiac Passenger` repository. This project is a short video game roguelike demo developed to explore
and analyze procedural generation algorithms. 

In `Amnesiac Passenger`, you play as an astronaut with amnesia who has been abducted by strange aliens. Your mission is to explore the alien starship, uncover your memories, and find the exit to escape. The starship is procedurally generated, ensuring a unique and challenging experience every time you play.

<br>

<p align="center">
<img src="./Assets/demo.gif" alt="alt text" width="30%" height="30%">
</p>

<p align="center">
  <a href="https://josanescod.github.io/tfg-roguelike/">Go to Demo</a>
</p>

## Credits

### Artwork

- 1-bit Asset Pack by Kenney (https://kenney.nl/assets/1-bit-pack)
- License: Creative Commons Zero, CC0

### Fonts

- Font package by Kenney (https://kenney.nl/assets/kenney-fonts)
- License: Creative Commons Zero, CC0

### Sound Effects

- 50 CC0 Retro Synth SFX by rubberduck (https://opengameart.org/content/50-cc0-retro-synth-sfx)
- License: Creative Commons Zero, CC0

#### List of Original File Names Modified

| Original Name        |  Modified Name     |
|----------------------|--------------------|
| `retro_coin_02.ogg`  | `coin.ogg`         |
| `retro_die_03.ogg`   | `death.ogg`        |
| `retro_die_02.ogg`   | `hit.ogg`          |
| `power_up_01.ogg`    | `heart.ogg`        |
| `power_up_04.ogg`    | `key.ogg`          |
| `synth_laser_08.ogg` | `laser_shot.ogg`   |
| `synth_misc_05.ogg`  | `next_room.ogg`    |
| `synth_misc_15.ogg`  | `walk.ogg`         |

- Win Sound Effect by Listener (https://opengameart.org/content/win-sound-effect)
- License: Creative Commons Zero, CC0

#### List of Original File Names Modified

| Original Name  |  Modified Name    |
|----------------|-------------------|
| `Win sound.wav`| `victory.ogg`     |

### Background Music

- Long Away Home \[8bit\] by nene (https://opengameart.org/content/long-away-home-8bit)
- License: Creative Commons Zero, CC0

#### List of Original File Names Modified

| Original Name        | Modified Name          |
|----------------------|------------------------|
| `Long Away Home.wav` | `long_away_home.ogg`   |

### Background Image

- Space by Kutejnikov (https://opengameart.org/content/space-9)
- License: Creative Commons Zero, CC0

#### List of Original File Names Modified

| Original Name  |  Modified Name           |
|----------------|--------------------------|
| `space.png`    | `space-background.png`   |
| `space.png`    | `pattern.png`            |
| `space.png`    | `background-grey.png`    |


## Additional Files

A folder named `algorithms_analysis` is included containing the `test_results.csv` file, which holds data extracted using the `run_test_algo()` function from the `level_builder.gd` script. This file includes execution times from 40 iterations of the algorithms used in the game.

A Python script is also provided. This script generates a visualization graph of the data.
