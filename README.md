# aseprite companion
This is an aseprite extension that provides additional features for [aseprite](https://www.aseprite.org/).

It provides a color groups dialog for grouping colors and naming color groups and a color shades dialog for the creation
of simple color shade ramps.

# Installation
[official aseprite plugin documentation](https://www.aseprite.org/api/plugin)

# Usage
Aseprite companion's dialogs can be found in the menu `Sprite > [Aseprite Companion]`.

I recommend assigning a shortcut to the color groups dialog, e.g. `CTRL + G`.
This can be done over the menu `Edit > Keyboard Shortcuts...`.

# Aseprite Compatibility
The following aseprite versions have been tested successfully for compatibility with this extension:

| aseprite version | tested aseprite companion version |
|------------------|-----------------------------------|
| 1.3.2            | 2.0.0, 1.3.0, 1.1.1               |
| 1.3-beta4        | 1.1.1, 1.1.0, 1.0.0               |

If you have another version, this extension might still work, you'll have to try it yourself.

# History
This is a fork of the original [aseprite companion version "1.1.1"](https://joncote.itch.io/aseprite-companion)
with some fixes and changes applied.

The original github repository seems to not be publicly available, since this software is MIT licensed,
I created this one instead.
I also applied some fixes and changes to it.

The older versions are marked via git tags, so if you wanted to you could use any of the older versions.

A big thanks to Jon Cote for their work on this aseprite extension / plugin.

# Changelog
- Planned / Ideas
  - shading tool optimization: check if color group is already within the palette to not needlessly grow the palette
  - shading tool: alternate mode: set the palette to the selected color group
  - tool: swap palette of selected layer
  - tool: retrieve palette from selected layer
- branch master (next tag 2.0.0)
  - `Color Groups` dialog changed:
    - General:
      - Limited concurrently open color groups dialogs to one. If you set up a keyboard shortcut you can easily open/close this dialog whenever you need to, since the most important state is now kept in between dialog closings and openings.
      - Moved the dialogs from the `Sprite` menu into their own `Sprite > [Aseprite Companion]` sub menu.
      - Color group dialogs can now be opened and used without an active sprite. However, adding colors requires an active palette/sprite.
      - Saving and loading plugin preferences for the color groups dialog. Whenever the dialog is opened it loads previous color groups and some other fields and prefills them. This is consistent over aseprite restarts. But please still save your color groups with the save / load mechanism as this preference feature seemed to be a bit more brittle.
      - Reworked color groups dialog layout: tabs are now used for the top section.
      - Changed color group page navigation to accommodate more color groups.
      - Better performance: performance is not (significantly) impaired by the number of color groups anymore.
      - Increased number of color groups to 300.
      - The selection of a active color group for editing changed, because the aseprite plugin API was giving me a hard time with dropdown menus (you can not query the selected index, but only get an index).
    - Added `Guide` tab: moved the description into this tab.
    - Added `View` tab:
      - The number of shown color groups can be chosen within the range of 1 to 20. The default is now 10. You might want to teak this value because of selection performance and / or monitor resolution.
      - Added a button to show/hide the selector display.
      - Added a button to show/hide the label header row display.
    - Added `Save/Load` tab:
      - Breaking Change: the save file format changed from ".lua" to ".json", old save files will have to be recreated from scratch.
      - Breaking Change: the color groups now use the RGBA color values instead of the palette indices, this makes color group usage more portable between sprites and makes palette syncing unnecessary.
      - The file name field is not cleared anymore upon loading of a color group file.
      - Added a button to clear and reset all loaded color groups for a clean start. If this is not sufficient delete (e.g. due to bugs) the `<aseprite>/extensions/aseprite-companion/__pref.lua` file to get a clean slate.
    - Added `Edit Groups` tab:
      - The group name field is not cleared anymore upon color group renaming.
      - Changed layout.
    - Added `Label` tab:
      - Labels can be added and removed to and from color groups. It's a bit clunky, but probably sufficient.
      - A label in this context is a string that has no whitespace characters within. Whitespaces are replaced by underscores.
    - Added `Search` tab:
      - The shown color groups can be filtered according to their labels.
      - A first space separated list of labels can be provided to search for labels that a color group must all have.
      - A second space separated list of labels can be provided to search for labels that a color group must have at least one of.
      - A number of colors can be selected that a coloring group must contain.
      - More formally this expression matches a color group: `num_colors_matches ∨ ((and_1 ∧ and_2 ∧ ... ∧ and_N) ∧ (or_1 ∨ or_2 ∨ ... ∨ or_M))`.
    - Added `Tools` tab:
      - Only one tool can be active at the same time. Activate them by clicking on the tool buttons in this tab.
      - Pencil tool `Select Primary/Secondary Color`: the only mode that was present up until tag v2.0.0 - left/right click on a color within a color group sets the foreground/background brush color. A click on this tool button also activates the pencil tool.
      - Shading tool `Add to Palette`: clicking on any color within a color group sets adds the color group to the end of the active palette, selects the color group's colors as in active use for the shading tool and activates the shading tool.
      - Shading tool `Replace Palette`: clicking on any color within a color group replaces the active palette with the color group that was clicked, selects the color group's colors as in active use for the shading tool and activates the shading tool.
- tag v1.3.0
  - Instead of 3 color group pages (with each 10 groups) there are now 10 color group pages
    (with each 10 groups).
    - The page size and group size can now easily be changed in the plugin source code by only changing 1 or 2 variables.
      However larger values lead to bad dialog performance.
  - The color group page number is now displayed within the title of the separator above the color group page
    section.
  - The button "previous" on the first color group page and "next" on the last color group page now wrap around
    instead of staying on the same group page.
- tag v1.2.0
  - Previously left/right clicking a color in a color group both set the foreground color. Now a left click sets
    the foreground color and a right click sets the background color.
- tag v1.1.2
  - Fixed thanks to Eldresh: In Color Groups, when adding colors, the color at the last index in a palette couldn't be
    added. Instead, the color at index 0 is added.
- tag v1.1.1
  - Added "Add Shades to Palette" button.
  - Relabeled "Enable Create Mode" button to "Enable Edit Mode".
- tag v1.1.0
  - Added `Color Groups` dialog:
    - Group your colors and rename them for easy identification and a consistent style.
    - Click on any color in a color group to select it as primary color for drawing.
    - Save/load your color groups as/from external files.
    - A total of 30 color groups on 3 pages are supported.
    - The color groups only save the index of the color into the currently active palette, making it necessary to sync
      ones active palette with the color groups.
      - This was changed in version `2.0.0`.
- tag v1.0.0
  - First release of the aseprite companion.
  - Added `Color Shades` dialog: Quickly create color shade ramps from a selected base color. Some options like hue, saturation and
    lightness are available.
    - If you have more complex needs for creating color shade ramps I suggest you have a look at
      [Chaonic's Palette Helper](https://chaonic.itch.io/aseprite-palette-helper)
      ([github](https://github.com/ChaonicTheDeathKitten/Palette-Helper))
      as this tool has more options to create color shades and palettes.