# aseprite-companion
 An extension providing additional features for Aseprite

## Notes from AnAverageGitUser
This is a fork of the aseprite companion "1.1.1" with some fixes and changes applied.

I created this repository because the original repo was not accessible for me.
However, since this software is MIT licensed, I figured I apply some changes that I need and provide it to everyone else.

I downloaded the original here: https://joncote.itch.io/aseprite-companion
Thanks to Jon Cote for their work on this aseprite extension / plugin.

### Changelog
Things that are different from the Jon Cote's "aseprite companion 1.1.1" release:

 - Fixed thanks to Eldresh: Bug: In Color Groups, when adding colors, the color at the last index in a palette can't be added. Instead, the color at index 0 is added.
 - Changed: Instead of 3 color group pages (with each 10 groups) there are now 10 color group pages (with each 10 groups). The page size and group size can now easily be changed in the plugin source code by only changinging 1 or 2 variables, however larger values lead to bad dialog performance.
 - Changed: The button "previous" on the first color group page and "next" on the last color group page now wrap around instead of staying on the same group page.
 - Changed: The color group page number is now displayed within the title of the separator above the color group page section.
 - Added: Previously left/right clicking a color in a color group both set the foreground color. Now a left click sets the foreground color and a right click sets the background color.