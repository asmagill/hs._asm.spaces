
> hs.spaces.activeSpaceOnScreen()
3

> hs.spaces.activeSpaceOnScreen("Main")
3

> hs.spaces.activeSpaceOnScreen(hs.screen.mainScreen())
3

> hs.spaces.activeSpaceOnScreen(hs.screen.mainScreen():getUUID())
3

> hs.spaces.activeSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = 3
}

> hs.spaces.addSpaceToScreen()
true

> hs.spaces.addSpaceToScreen("Main")
true

> hs.spaces.addSpaceToScreen(hs.screen.mainScreen())
true

> hs.spaces.addSpaceToScreen(hs.screen.mainScreen():getUUID())
true

> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 102, 45, 119, 175, 179, 183, 187 }
}

> t = hs.timer.doAfter(5, hs.spaces.closeMissionControl) ; hs.spaces.openMissionControl()

> hs.spaces.focusedSpace()
3

> hs.spaces.gotoSpace(45)
true

> hs.spaces.gotoSpace(9999)
nil	space not found in managed displays

> hs.spaces.missionControlSpaceNames()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = {
    [3] = "Desktop 1",
    [45] = "Desktop 2",
    [102] = "Mail",
    [119] = "Desktop 3",
    [175] = "Desktop 4",
    [179] = "Desktop 5",
    [183] = "Desktop 6",
    [187] = "Desktop 7"
  }
}

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 45)
true

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 102)
nil	target space ID 102 does not refer to a user space

> hs.spaces.removeSpace(187)
true

> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 45, 102, 119, 175, 179, 183 }
}

> hs.spaces.removeSpace(187)
nil	space not found in managed displays

> hs.spaces.screensHaveSeparateSpaces()
false

> hs.spaces.spaceDisplay(119)
37D8832A-2D66-02CA-B9F7-8F30A301B230

> hs.spaces.spaceDisplay(9999)
nil	space not found in managed displays

> hs.spaces.spacesForScreen()
{ 3, 45, 102, 119, 175, 179, 183 }

> hs.spaces.spacesForScreen("Main")
{ 3, 45, 102, 119, 175, 179, 183 }

> hs.spaces.spacesForScreen(hs.screen.mainScreen())
{ 3, 45, 102, 119, 175, 179, 183 }

> hs.spaces.spacesForScreen(hs.screen.mainScreen():getUUID())
{ 3, 45, 102, 119, 175, 179, 183 }

> hs.spaces.spaceType(45)
user

> hs.spaces.spaceType(102)
fullscreen

> hs.spaces.spaceType(999)
nil	space not found in managed displays

> hs.spaces.windowsForSpace(3)
{ 64953, 64952, 64951, 64950, 64949, 61431, 61429, 61436, 61444, 61388, 61415, 61409, 61387, 61386, 61385, 61384, 61398, 64957, 64961, 61541, 61479, 61491, 61489, 63560, 61367, 61433, 61608, 63121, 64958 }

> hs.spaces.windowsForSpace(9999)
nil	not a user or fullscreen managed space

> hs.spaces.windowsForSpace(102)
{ 62081, 62069, 61802, 62070, 62071, 61433 }

> hs.spaces.windowsForSpace(9999)
nil	not a user or fullscreen managed space

> hs.spaces.windowSpaces(61433)
{ 45, 102, 119, 175, 179, 183, 3 }

> hs.spaces.windowSpaces(64953)
{ 3 }
