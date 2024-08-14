# aseprite-companion
 An extension providing additional features for Aseprite

## Notes from AnAverageGitUser
This is a fork of the aseprite companion "1.1.1" with some fixes and changes applied.

I created this repository because the original repo was not accessible for me.
However, since this software is MIT licensed, I figured I apply some changes that I need and provide it to everyone else.

I downloaded the original here: https://joncote.itch.io/aseprite-companion
Thanks to Jon Cote for their work on this aseprite extension / plugin.

### Changelog
- Planned / Ideas
  - Planned: button for color group in shading tool (automatically adds color group to palette and selects shading tool with selection)
    - switch between pencil mode (single color selection) and shading mode
    - swap palette of selected layer
  - Planned: add labels to color groups
  - Planned: search for color groups by labels
- branch master
  - Breaking Change: the save file format changed from ".lua" to ".json", old save files will have to be recreated from scratch
  - Breaking Change: the color groups now use the RGBA color values instead of the palette indices, this makes color group usage more portable between sprites and makes palette syncing unnecessary
  - Performance: performance is not (significantly) impaired by the number of color groups anymore
  - Changed: increased number of color groups to 300
  - Changed: color group page navigation
  - Changed: selection of active color group: the dropdown now only lists the visible color groups
  - Changed: the file name field is not cleared anymore upon loading of a color group file
  - Changed: the group name field is not cleared anymore upon color group renaming
- tag v1.3.0
  - Changed: Instead of 3 color group pages (with each 10 groups) there are now 10 color group pages (with each 10 groups). The page size and group size can now easily be changed in the plugin source code by only changinging 1 or 2 variables, however larger values lead to bad dialog performance.
  - Changed: The color group page number is now displayed within the title of the separator above the color group page section.
  - Changed: The button "previous" on the first color group page and "next" on the last color group page now wrap around instead of staying on the same group page.
- tag v1.2.0
  - Added: Previously left/right clicking a color in a color group both set the foreground color. Now a left click sets the foreground color and a right click sets the background color.
- tag v1.1.2
  - Fixed thanks to Eldresh: Bug: In Color Groups, when adding colors, the color at the last index in a palette can't be added. Instead, the color at index 0 is added.
- tag v1.1.1
  - Added: "Add Shades to Palette" button
  - Version by Jon Cote
- tag v1.1.0
  - Version by Jon Cote
- tag v1.0.0
  - Version by Jon Cote