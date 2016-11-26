# Starbound Tech Directives
Tech Directives is a library that manages and applies directives using the Starbound `tech.setParentDirectives` function. Since the function allows for only one string as an argument, it can become very tedious to keep track of and apply multiple directive strings.

Much like animations in active items, this library allows you to manage different directives, each identified by a given name.

#### Example

```lua
-- This will make the character white and glow white, because the setcolor is applied after the red border.
tech.appendDirectives("white", "?setcolor=ffffff", 1)
tech.appendDirectives("glow", "?border=2;ff0000ff;ff000000", 0)

-- This will make the character white and glow blue, because the setcolor is applied before the blue border.
-- Note that we're updating the 'glow' directives that we appended before.
tech.updateDirectives("glow", "?border=2;0000ffff;0000ff00")
tech.setDirectivesPriority("glow", 2)
```

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Wiki](#wiki)
- [Contributing](#contributing)

## Features

* Management of different directives.
 * Update just the directives you want to update, without worrying about concatenating different part strings and overwriting directives at the wrong time.
 * Set the order in which directives are applied.
 * Toggle directives on and off.
* Identification of directives by a given name, much like various animator functions known in the vanilla game.

## Installation

* [Download the latest release](https://github.com/Silverfeelin/Starbound-TechDirectives/releases).
 * Make sure you don't download the release, not the source code!
* Place the `TechDirectives.pak` in your mod folder (`/Starbound/mods/TechDirectives.pak`).

## Wiki

Setting up and further information can be found on the [Wiki](https://github.com/Silverfeelin/Starbound-TechDirectives/wiki).

#### Quick Reference

* [Setting Up](https://github.com/Silverfeelin/Starbound-TechDirectives/wiki/Setting-Up)
* [Redistribution](https://github.com/Silverfeelin/Starbound-TechDirectives/wiki/Redistribution)

## Contributing

Feel free to suggest things and report bugs by opening a [new Issue](https://github.com/Silverfeelin/Starbound-TechDirectives/issues/new).
