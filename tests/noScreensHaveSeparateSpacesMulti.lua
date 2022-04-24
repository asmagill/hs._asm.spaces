
> hs.spaces.screensHaveSeparateSpaces()
false

> hs.spaces.activeSpaceOnScreen()
3

> for _, v in ipairs(hs.screen.allScreens()) do print(v:getUUID(), hs.spaces.activeSpaceOnScreen(v)) end
37D8832A-2D66-02CA-B9F7-8F30A301B230	3
CF64A3CC-70DC-9713-C90B-A2661D91F570	3
3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8	3


> hs.spaces.activeSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = 3,
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = 3,
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = 3
}


> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 209, 102, 183 },
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = { 3, 209, 102, 183 },
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = { 3, 209, 102, 183 }
}

> hs.spaces.addSpaceToScreen()
true

> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 209, 102, 183, 299 },
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = { 3, 209, 102, 183, 299 },
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = { 3, 209, 102, 183, 299 }
}

> hs.spaces.removeSpace(299)
true

> hs.spaces.allSpaces()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = { 3, 209, 102, 183 },
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = { 3, 209, 102, 183 },
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = { 3, 209, 102, 183 }
}

> hs.spaces.removeSpace(299)
nil	space not found in managed displays

> t = hs.timer.doAfter(5, hs.spaces.closeMissionControl) ; hs.spaces.openMissionControl()

> hs.spaces.focusedSpace()
3

> hs.spaces.gotoSpace(102)
true

> hs.spaces.missionControlSpaceNames()
{
  ["37D8832A-2D66-02CA-B9F7-8F30A301B230"] = {
    [3] = "Desktop 1",
    [102] = "Mail",
    [183] = "Desktop 2",
    [209] = "SmartGit"
  },
  ["3FF39CA8-DDD5-4980-9DE9-0966D8C1CFC8"] = {
    [3] = "Desktop 1",
    [102] = "Mail",
    [183] = "Desktop 2",
    [209] = "SmartGit"
  },
  ["CF64A3CC-70DC-9713-C90B-A2661D91F570"] = {
    [3] = "Desktop 1",
    [102] = "Mail",
    [183] = "Desktop 2",
    [209] = "SmartGit"
  }
}

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 209)
nil	target space ID 209 does not refer to a user space

> hs.spaces.moveWindowToSpace(hs.application("Hammerspoon"):mainWindow():id(), 183)
true

> hs.spaces.spaceDisplay(3)
37D8832A-2D66-02CA-B9F7-8F30A301B230

> hs.spaces.spaceDisplay(102)
37D8832A-2D66-02CA-B9F7-8F30A301B230

> hs.spaces.spaceDisplay(102)
CF64A3CC-70DC-9713-C90B-A2661D91F570

> hs.screen.mainScreen():getUUID()
CF64A3CC-70DC-9713-C90B-A2661D91F570

> hs.spaces.spaceDisplay(9999)
nil	space not found in managed displays

> hs.spaces.spaceType(3)
user

> hs.spaces.spaceType(102)
fullscreen

> hs.spaces.spaceType(999)
nil	space not found in managed displays

> hs.spaces.windowsForSpace(3)
{ 79614, 79613, 79612, 79611, 79610, 61431, 61429, 63121, 74827, 61436, 61444, 61388, 61415, 61409, 61387, 61386, 61385, 61384, 61398, 80343, 64961, 71067, 61489, 68600, 70451, 61479, 61491, 74931, 63091, 70331, 73414, 79734, 79740, 79724, 61433, 61608, 63090, 68827, 70330, 70333, 74930, 80340, 80344, 80354 }

> hs.spaces.windowsForSpace(102)
{ 62081, 62069, 61802, 79757, 79755, 62070, 61433 }

> hs.spaces.windowsForSpace(102)
{ 62081, 62069, 61802, 79757, 79755, 62070, 61433 }

> hs.spaces.windowSpaces(61433)
{ 209, 102, 183, 3 }

> hs.spaces.windowSpaces(79614)
{ 3 }

> hs.spaces.windowSpaces(9)
{}
