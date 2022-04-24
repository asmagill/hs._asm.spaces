
> hs.spaces.activeSpaceOnScreen()
3

> hs.spaces.activeSpaceOnScreen("Main")
3

> hs.spaces.activeSpaceOnScreen(hs.screen.primaryScreen())
3

> hs.spaces.activeSpaceOnScreen(hs.screen.mainScreen():getUUID())
3

> hs.spaces.activeSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = 3
}

> hs.spaces.activeSpaceOnScreen("Main")
3

> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 18, 73, 81 }
}

> hs.spaces.addSpaceToScreen(hs.screen.mainScreen())
true

> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 18, 73, 81, 97 }
}

> hs.spaces.removeSpace(97)
true

> hs.spaces.removeSpace(9999)
nil	space not found in managed displays

> hs.spaces.gotoSpace(81)
true

> hs.spaces.focusedSpace()
81

> hs.spaces.gotoSpace(3)
true

> hs.spaces.missionControlSpaceNames()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = {
    [3] = "Desktop 1",
    [18] = "Mail",
    [73] = "Desktop 2",
    [81] = "Desktop 3"
  }
}

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 18)
nil	target space ID 18 does not refer to a user space

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 73)
true

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 3)
true

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 3)
true

> hs.spaces.spaceDisplay(73)
37D8832A-2D66-02CA-B9F7-8F30A301B230

> hs.spaces.spaceType(3), hs.spaces.spaceType(18)
user	fullscreen

> hs.spaces.spacesForScreen(hs.screen.mainScreen():getUUID())
{ 3, 18, 73, 81 }

> hs.spaces.windowsForSpace(3)
{ 82202, 82201, 82200, 82199, 82198, 81414, 81394, 81417, 81478, 81387, 81402, 81379, 81386, 81385, 81384, 81382, 81375, 82206, 82095, 82100, 81595, 81598, 81574, 81578, 81572, 81351, 81388, 81389, 81397, 81620, 82897 }

> hs.spaces.windowsForSpace(18)
{ 81636, 81635, 81637, 81644, 81397, 81657 }

> hs.spaces.windowSpaces(82202)
{ 3 }

> hs.spaces.windowSpaces(81397)
{ 18, 73, 81, 3 }

