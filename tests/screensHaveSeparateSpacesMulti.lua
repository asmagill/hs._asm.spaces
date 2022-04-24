
> hs.spaces.screensHaveSeparateSpaces()
true

> hs.spaces.activeSpaceOnScreen()
3

> hs.spaces.activeSpaceOnScreen("Main")
3

> for _, v in ipairs(hs.screen.allScreens()) do print(v:getUUID(), hs.spaces.activeSpaceOnScreen(v)) end
37D8832A-2D66-02CA-B9F7-8F30A301B230	3
CF64A3CC-70DC-9713-C90B-A2661D91F570	15
3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8	16

> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 18, 10 },
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = { 16 },
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = { 15 }
}

> hs.spaces.activeSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = 3,
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = 16,
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = 15
}

> hs.spaces.addSpaceToScreen()
true

> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 18, 10, 28 },
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = { 16 },
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = { 15 }
}

> hs.spaces.addSpaceToScreen("CF64A3CC-70DC-9713-C90B-A2661D91F570")
true

> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 18, 10, 28 },
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = { 16 },
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = { 15, 36 }
}


> hs.spaces.missionControlSpaceNames()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = {
    [3] = "Desktop 1",
    [10] = "Desktop 2",
    [18] = "Mail",
    [28] = "Desktop 3"
  },
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = {
    [16] = "Desktop 4"
  },
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = {
    [15] = "Desktop 5",
    [36] = "Desktop 6"
  }
}

> hs.spaces.removeSpace(36)
true

> hs.spaces.spaceType(18)
fullscreen

> hs.spaces.spaceType(10)
user

> hs.spaces.removeSpace(10, false) ; hs.spaces.removeSpace(28)


> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 18 },
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = { 16 },
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = { 15 }
}

> hs.spaces.addSpaceToScreen()
true

> hs.spaces.spacesForScreen()
{ 3, 18, 73 }

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 209)
nil	target space ID 209 does not refer to a user space

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 73)
true

> hs.spaces.spaceDisplay(18)
37D8832A-2D66-02CA-B9F7-8F30A301B230

> hs.spaces.spaceDisplay(16)
3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8

> hs.spaces.spaceDisplay(15)
CF64A3CC-70DC-9713-C90B-A2661D91F570

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 15)
true

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 3)
true

> hs.spaces.windowsForSpace(3)
{ 81510, 81507, 81504, 81501, 81498, 81414, 81394, 81389, 81388, 81417, 81478, 81387, 81402, 81379, 81386, 81385, 81384, 81382, 81375, 81618, 81605, 81607, 81598, 81595, 81574, 81578, 81576, 81572, 81351, 81397, 81620, 81621 }

> hs.spaces.windowsForSpace(18)
{ 81636, 81635, 81637, 81644, 81397, 81657 }

> hs.spaces.windowsForSpace(15)
{ 81506, 81500, 81503, 81433, 81480, 81430, 81444, 81443, 81442, 81441, 81440, 81439, 81434, 81435, 81436, 81431, 81428, 81437, 81509, 81512 }


> hs.spaces.windowSpaces(81397)
{ 18, 73, 3 }

> hs.spaces.windowSpaces(81605)
{ 3 }

> hs.spaces.windowSpaces(81439)
{ 15 }
