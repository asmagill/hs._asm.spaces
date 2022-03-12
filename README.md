hs.spaces
=========

This module provides some basic functions for controlling macOS Spaces.

The functionality provided by this module is considered experimental and subject to change. By using a combination of private APIs and Accessibility hacks (via hs.axuielement), some basic functions for controlling the use of Spaces is possible with Hammerspoon, but there are some limitations and caveats.

It should be noted that while the functions provided by this module have worked for some time in third party applications and in a previous experimental module that has received limited testing over the last few years, they do utilize some private APIs which means that Apple could change them at any time.

The functions which allow you to create new spaes, remove spaces, and jump to a specific space utilize `hs.axuielement` and perform accessibility actions through the Dock application to manipulate Mission Control. Because we are essentially directing the Dock to perform User Interactions, there is some visual feedback which we cannot entirely suppress. You can minimize, but not entirely remove, this by enabling "Reduce motion" in System Preferences -> Accessibility -> Display.

It is recommended that you also enable "Displays have separate Spaces" in System Preferences -> Mission Control.

This module is a distillation of my previous `hs._asm.undocumented.spaces` module, changes inspired by reviewing the `Yabai` source, and some experimentation with `hs.axuielement`. If you require more sophisticated control, I encourage you to check out https://github.com/koekeishiya/yabai -- it does require some additional setup (changes to SIP, possibly edits to `sudoers`, etc.) but may be worth the extra steps for some power users. A Spoon supporting direct socket communication with Yabai from Hammerspoon is also being considered.


### Installation

A precompiled version of this module can be found in this directory with a name along the lines of `spaces-v0.x.tar.gz`. This can be installed by downloading the file and then expanding it as follows:

~~~sh
$ cd ~/.hammerspoon # or wherever your Hammerspoon init.lua file is located
$ tar -xzf ~/Downloads/spaces-v0.x.tar.gz # or wherever your downloads are located
~~~

If you wish to build this module yourself and have XCode installed on your Mac, the best way (you are welcome to clone the entire repository if you like, but no promises on the current state of anything else) is to download `init.lua`, `spacesObjc.m`, `private.h`, and `Makefile` and move them into a directory named `spaces` and then do one of the following:

If you want to add the documentation to the built in Hammerspoon help available through `hs.help`, you must have installed the Hammerspoon command line tool (this can be done by typing `hs.ipc.cliInstall()` into the Hammerspoon console) and then do the following:

~~~sh
$ cd wherever-you-downloaded-the-files
$ [HS_APPLICATION=/Applications] [PREFIX=~/.hammerspoon] make docs install
~~~

If you do not care about the documentation, or alternatively also downloaded `docs.json` from this page, do the following:

~~~sh
$ cd wherever-you-downloaded-the-files
$ [HS_APPLICATION=/Applications] [PREFIX=~/.hammerspoon] make install
~~~

If your Hammerspoon application is located in `/Applications`, you can leave out the `HS_APPLICATION` environment variable, and if your Hammerspoon files are located in their default location, you can leave out the `PREFIX` environment variable.  For most people it will be sufficient to just type `make docs install`.

As always, whichever method you chose, if you are updating from an earlier version it is recommended to fully quit and restart Hammerspoon after installing this module to ensure that the latest version of the module is loaded into memory.

### Usage
~~~lua
spaces = require("hs.spaces")
~~~

### Contents


##### Module Functions
* <a href="#activeSpaceOnScreen">spaces.activeSpaceOnScreen([screen]) -> integer | nil, error</a>
* <a href="#activeSpaces">spaces.activeSpaces() -> table | nil, error</a>
* <a href="#addSpaceToScreen">spaces.addSpaceToScreen([screen], [closeMC]) -> true | nil, errMsg</a>
* <a href="#allSpaces">spaces.allSpaces() -> table | nil, error</a>
* <a href="#closeMissionControl">spaces.closeMissionControl() -> None</a>
* <a href="#data_managedDisplaySpaces">spaces.data_managedDisplaySpaces() -> table | nil, error</a>
* <a href="#data_missionControlAXUIElementData">spaces.data_missionControlAXUIElementData(callback) -> None</a>
* <a href="#displayIsAnimating">spaces.displayIsAnimating(screen) -> boolean | nil, error</a>
* <a href="#focusedSpace">spaces.focusedSpace() -> integer</a>
* <a href="#gotoSpace">spaces.gotoSpace(spaceID) -> true | nil, errMsg</a>
* <a href="#missionControlSpaceNames">spaces.missionControlSpaceNames([closeMC]) -> table | nil, error</a>
* <a href="#moveWindowToSpace">spaces.moveWindowToSpace(window, spaceID) -> true | nil, error</a>
* <a href="#openMissionControl">spaces.openMissionControl() -> None</a>
* <a href="#removeSpace">spaces.removeSpace(spaceID, [closeMC]) -> true | nil, errMsg</a>
* <a href="#screensHaveSeparateSpaces">spaces.screensHaveSeparateSpaces() -> bool</a>
* <a href="#setDefaultMCwaitTime">spaces.setDefaultMCwaitTime([time]) -> None</a>
* <a href="#spaceDisplay">spaces.spaceDisplay(spaceID) -> string | nil, error</a>
* <a href="#spaceType">spaces.spaceType(spaceID) -> string | nil, error</a>
* <a href="#spacesForScreen">spaces.spacesForScreen([screen]) -> table | nil, error</a>
* <a href="#toggleAppExpose">spaces.toggleAppExpose() -> None</a>
* <a href="#toggleLaunchPad">spaces.toggleLaunchPad() -> None</a>
* <a href="#toggleMissionControl">spaces.toggleMissionControl() -> None</a>
* <a href="#toggleShowDesktop">spaces.toggleShowDesktop() -> None</a>
* <a href="#windowSpaces">spaces.windowSpaces(window) -> table | nil, error</a>
* <a href="#windowsForSpace">spaces.windowsForSpace(spaceID) -> table | nil, error</a>

##### Module Variables
* <a href="#MCwaitTime">spaces.MCwaitTime</a>

- - -

### Module Functions

<a name="activeSpaceOnScreen"></a>
~~~lua
spaces.activeSpaceOnScreen([screen]) -> integer | nil, error
~~~
Returns the currently visible (active) space for the specified screen.

Parameters:
 * `screen` - an optional screen specification identifying the screen to return the active space for. The screen may be specified by it's ID (`hs.screen:id()`), it's UUID (`hs.screen:getUUID()`), or as an `hs.screen` object. If no screen is specified, the screen returned by `hs.screen.mainScreen()` is used.

Returns:
 * an integer specifying the ID of the space displayed, or nil and an error message if an error occurs.

- - -

<a name="activeSpaces"></a>
~~~lua
spaces.activeSpaces() -> table | nil, error
~~~
Returns a key-value table specifying the active spaces for all screens.

Parameters:
 * None

Returns:
 * a key-value table in which the keys are the UUIDs for the current screens and the value for each key is the space ID of the active space for that display.

Notes:
 * the table returned has its __tostring metamethod set to `hs.inspect` to simplify inspecting the results when using the Hammerspoon Console.

- - -

<a name="addSpaceToScreen"></a>
~~~lua
spaces.addSpaceToScreen([screen], [closeMC]) -> true | nil, errMsg
~~~
Adds a new space on the specified screen

Parameters:
 * `screen` - an optional screen specification identifying the screen to create the new space on. The screen may be specified by it's ID (`hs.screen:id()`), it's UUID (`hs.screen:getUUID()`), or as an `hs.screen` object. If no screen is specified, the screen returned by `hs.screen.mainScreen()` is used.
 * `closeMC` - an optional boolean, default true, specifying whether or not the Mission Control display should be closed after adding the new space.

Returns:
 * true on success; otherwise return nil and an error message

Notes:
 * This function creates a new space by opening up the Mission Control display and then programmatically invoking the button to add a new space. This is unavoidable. You can  minimize, but not entirely remove, the visual shift to the Mission Control display by by enabling "Reduce motion" in System Preferences -> Accessibility -> Display.

 * If you intend to perform multiple actions which require the Mission Control display (([hs.spaces.missionControlSpaceNames](#missionControlSpaceNames), [hs.spaces.addSpaceToScreen](#addSpaceToScreen), [hs.spaces.removeSpace](#removeSpace), or [hs.spaces.gotoSpace](#gotoSpace)), you can pass in `false` as the final argument to prevent the automatic closure of the Mission Control display -- this will reduce the visual side-affects to one transition instead of many.

- - -

<a name="allSpaces"></a>
~~~lua
spaces.allSpaces() -> table | nil, error
~~~
Returns a Kay-Value table contining the IDs of all spaces for all screens.

Parameters:
 * None

Returns:
 * a key-value table in which the keys are the UUIDs for the current screens and the value for each key is a table of space IDs corresponding to the spaces for that screen. Returns nil and an error message if an error occurs.

Notes:
 * the table returned has its __tostring metamethod set to `hs.inspect` to simplify inspecting the results when using the Hammerspoon Console.

- - -

<a name="closeMissionControl"></a>
~~~lua
spaces.closeMissionControl() -> None
~~~
Opens the Mission Control display

Parameters:
 * None

Returns:
 * None

Notes:
 * Does nothing if the Mission Control display is not currently visible.
 * This function uses Accessibility features provided by the Dock to close Mission Control and is used internally when performing the [hs.spaces.gotoSpace](#gotoSpace), [hs.spaces.addSpaceToScreen](#addSpaceToScreen), and [hs.spaces.removeSpace](#removeSpace) functions.
 * It is possible to invoke the above mentioned functions and prevent them from auto-closing Mission Control -- this may be useful if you wish to perform multiple actions and want to minimize the visual side-effects. You can then use this function when you are done.

- - -

<a name="data_managedDisplaySpaces"></a>
~~~lua
spaces.data_managedDisplaySpaces() -> table | nil, error
~~~
Returns a table containing information about the managed display spaces

Parameters:
 * None

Returns:
 * a table containing information about all of the displays and spaces managed by the OS.

Notes:
 * the format and detail of this table is too complex and varied to describe here; suffice it to say this is the workhorse for this module and a careful examination of this table may be informative, but is not required in the normal course of using this module.

- - -

<a name="data_missionControlAXUIElementData"></a>
~~~lua
spaces.data_missionControlAXUIElementData(callback) -> None
~~~
Generate a table containing the results of `hs.axuielement.buildTree` on the Mission Control Accessibility group of the Dock.

Parameters:
 * `callback` - a callback function that should expect a table as the results. The table will be formatted as described in the documentation for `hs.axuielement.buildTree`.

Returns:
 * None

Notes:
 * Like [hs.spaces.data_managedDisplaySpaces](#data_managedDisplaySpaces), this function is not required for general usage of this module; rather it is provided for those who wish to examine the internal data that makes this module possible more closely to see if there might be other information or functionality that they would like to explore.

 * Getting Accessibility elements for Mission Control is somewhat tricky -- they only exist when the Mission Control display is visible, which is the exact time that you can't examine them. What this function does is trigger Mission Control and then builds a tree of the elements, capturing all of the properties and property values while the elements are valid, closes Mission Control, and then returns the results in a table by invoking the provided callback function.
   * Note that the `hs.axuielement` objects within the table returned will be invalid by the time you can examine them -- this is why the attributes and values will also be contained in the resulting tree.
   * Example usage: `hs.spaces.data_missionControlAXUIElementData(function(results) hs.console.clearConsole() ; print(hs.inspect(results)) end)`

- - -

<a name="displayIsAnimating"></a>
~~~lua
spaces.displayIsAnimating(screen) -> boolean | nil, error
~~~
Returns whether or not the specified screen is currently undergoing space change animation

Parameters:
 * `screen` - an integer specifying the screen ID, an hs.screen object, or a string specifying the UUID of the screen to check for animation

Returns:
 * true if the screen is currently in the process of animating a space change, or false if it is not

Notes:
 * Non-space change animations are not captured by this function -- unfortunately this lack also includes the change to the Mission Control and App Exposé displays.

- - -

<a name="focusedSpace"></a>
~~~lua
spaces.focusedSpace() -> integer
~~~
Returns the space ID of the currently focused space

Parameters:
 * None

Returns:
 * the space ID for the currently focused space. The focused space is the currently active space on the currently active screen (i.e. that the user is working on)

Notes:
 * *usually* the currently active screen will be returned by `hs.screen.mainScreen()`; however some full screen applications may have focus without updating which screen is considered "main". You can use this function, and look up the screen UUID with [hs.spaces.spaceDisplay](#spaceDisplay) to determine the "true" focused screen if required.

- - -

<a name="gotoSpace"></a>
~~~lua
spaces.gotoSpace(spaceID) -> true | nil, errMsg
~~~
Change to the specified space.

Parameters:
 * `spaceID` - an integer specifying the ID of the space

Returns:
 * true if the space change was initiated, or nil and an error message if there is an error trying to switch spaces.

Notes:
 * This function changes to a space by opening up the Mission Control display and then programmatically invoking the button to activate the space. This is unavoidable. You can  minimize, but not entirely remove, the visual shift to the Mission Control display by by enabling "Reduce motion" in System Preferences -> Accessibility -> Display.

 * The action of changing to a new space automatically closes the Mission Control display, so unlike ([hs.spaces.missionControlSpaceNames](#missionControlSpaceNames), [hs.spaces.addSpaceToScreen](#addSpaceToScreen), and [hs.spaces.removeSpace](#removeSpace), there is no flag you can specify to leave Mission Control visible. When possible, you should generally invoke this function last if you are performing multiple actions and want to minimize the amount of time the Mission Control display is visible and reduce the visual side affects.

 * The Accessibility elements required to change to a space are not created until the Mission Control display is fully visible. Because of this, there is a built in delay when invoking this function that can be adjusted by changing the value of [hs.spaces.MCwaitTime](#MCwaitTime).

- - -

<a name="missionControlSpaceNames"></a>
~~~lua
spaces.missionControlSpaceNames([closeMC]) -> table | nil, error
~~~
Returns a table containing the space names as they appear in Mission Control associated with their space ID. This is provided for informational purposes only -- all of the functions of this module use the spaceID to insure accuracy.

Parameters:
 * `closeMC` - an optional boolean, default true, specifying whether or not the Mission Control display should be closed after adding the new space.

Returns:
 * a key-value table in which the keys are the UUIDs for each screen and the value is a key-value table where the screen ID is the key and the Mission Control name of the space is the value.

Notes:
 * the table returned has its __tostring metamethod set to `hs.inspect` to simplify inspecting the results when using the Hammerspoon Console.

 * This function works by opening up the Mission Control display and then grabbing the names from the Accessibility elements created. This is unavoidable. You can  minimize, but not entirely remove, the visual shift to the Mission Control display by by enabling "Reduce motion" in System Preferences -> Accessibility -> Display.

 * If you intend to perform multiple actions which require the Mission Control display ([hs.spaces.missionControlSpaceNames](#missionControlSpaceNames), [hs.spaces.addSpaceToScreen](#addSpaceToScreen), [hs.spaces.removeSpace](#removeSpace), or [hs.spaces.gotoSpace](#gotoSpace)), you can pass in `false` as the final argument to prevent the automatic closure of the Mission Control display -- this will reduce the visual side-affects to one transition instead of many.

 * This function attempts to use the localization strings for the Dock application to properly determine the Mission Control names. If you find that it doesn't provide the correct values for your system, please provide the following information when submitting an issue:
   * the desktop or application name(s) as they appear at the top of the Mission Control screen when you invoke it manually (or with `hs.spaces.toggleMissionControl()` entered into the Hammerspoon console).
   * the output from the following commands, issued in the Hammerspoon console:
     * `hs.host.operatingSystemVersionString()`
     * `hs.host.locale.current()`
     * `hs.inspect(hs.host.locale.preferredLanguages())`
     * `hs.inspect(hs.host.locale.details())`

- - -

<a name="moveWindowToSpace"></a>
~~~lua
spaces.moveWindowToSpace(window, spaceID) -> true | nil, error
~~~
Moves the window with the specified windowID to the space specified by spaceID.

Parameters:
 * `window`  - an integer specifying the ID of the window, or an `hs.window` object
 * `spaceID` - an integer specifying the ID of the space

Returns:
 * true if the window was moved; otherwise nil and an error message.

Notes:
 * a window can only be moved from a user space to another user space -- you cannot move the window of a full screen (or tiled) application to another space and you cannot move a window *to* the same space as a full screen application.

- - -

<a name="openMissionControl"></a>
~~~lua
spaces.openMissionControl() -> None
~~~
Opens the Mission Control display

Parameters:
 * None

Returns:
 * None

Notes:
 * Does nothing if the Mission Control display is already visible.
 * This function uses Accessibility features provided by the Dock to open up Mission Control and is used internally when performing the [hs.spaces.gotoSpace](#gotoSpace), [hs.spaces.addSpaceToScreen](#addSpaceToScreen), and [hs.spaces.removeSpace](#removeSpace) functions.
 * It is unlikely you will need to invoke this by hand, and the public interface to this function may go away in the future.

- - -

<a name="removeSpace"></a>
~~~lua
spaces.removeSpace(spaceID, [closeMC]) -> true | nil, errMsg
~~~
Removes the specified space.

Parameters:
 * `spaceID` - an integer specifying the ID of the space
 * `closeMC` - an optional boolean, default true, specifying whether or not the Mission Control display should be closed after removing the space.

Returns:
 * true if the space removal was initiated, or nil and an error message if there is an error trying to remove the space.

Notes:
 * You cannot remove a currently active space -- move to another one first with [hs.spaces.gotoSpace](#gotoSpace).
 * If a screen has only one user space (i.e. not a full screen application window or tiled set), it cannot be removed.

 * This function removes a space by opening up the Mission Control display and then programmatically invoking the button to remove the specified space. This is unavoidable. You can  minimize, but not entirely remove, the visual shift to the Mission Control display by by enabling "Reduce motion" in System Preferences -> Accessibility -> Display.

 * If you intend to perform multiple actions which require the Mission Control display (([hs.spaces.missionControlSpaceNames](#missionControlSpaceNames), [hs.spaces.addSpaceToScreen](#addSpaceToScreen), [hs.spaces.removeSpace](#removeSpace), or [hs.spaces.gotoSpace](#gotoSpace)), you can pass in `false` as the final argument to prevent the automatic closure of the Mission Control display -- this will reduce the visual side-affects to one transition instead of many.

 * The Accessibility elements required to change to a space are not created until the Mission Control display is fully visible. Because of this, there is a built in delay when invoking this function that can be adjusted by changing the value of [hs.spaces.MCwaitTime](#MCwaitTime).

- - -

<a name="screensHaveSeparateSpaces"></a>
~~~lua
spaces.screensHaveSeparateSpaces() -> bool
~~~
Determine if the user has enabled the "Displays Have Separate Spaces" option within Mission Control.

Parameters:
 * None

Returns:
 * true or false representing the status of the "Displays Have Separate Spaces" option within Mission Control.

- - -

<a name="setDefaultMCwaitTime"></a>
~~~lua
spaces.setDefaultMCwaitTime([time]) -> None
~~~
Sets the initial value for [hs.spaces.MCwaitTime](#MCwaitTime) to be set to when this module first loads.

Parameters:
 * `time` - an optional number greater than 0 specifying the initial default for [hs.spaces.MCwaitTime](#MCwaitTime). If you do not specify a value, then the current value of [hs.spaces.MCwaitTime](#MCwaitTime) is used.

 Returns:
 * None

Notes:
 * this function uses the `hs.settings` module to store the default time in the key "hs_spaces_MCwaitTime".

- - -

<a name="spaceDisplay"></a>
~~~lua
spaces.spaceDisplay(spaceID) -> string | nil, error
~~~
Returns the screen UUID for the screen that the specified space is on.

Parameters:
 * `spaceID` - an integer specifying the ID of the space

Returns:
 * a string specifying the UUID of the display the space is on, or nil and error message if an error occurs.

Notes:
 * the space does not have to be currently active (visible) to determine which screen the space belongs to.

- - -

<a name="spaceType"></a>
~~~lua
spaces.spaceType(spaceID) -> string | nil, error
~~~
Returns a string indicating whether the space is a user space or a full screen/tiled application space.

Parameters:
 * `spaceID` - an integer specifying the ID of the space

Returns:
 * the string "user" if the space is a regular user space, or "fullscreen" if the space is a fullscreen or tiled window pair. Returns nil and an error message if the space does not refer to a valid managed space.

- - -

<a name="spacesForScreen"></a>
~~~lua
spaces.spacesForScreen([screen]) -> table | nil, error
~~~
Returns a table containing the IDs of the spaces for the specified screen in their current order.

Parameters:
 * `screen` - an optional screen specification identifying the screen to return the space array for. The screen may be specified by it's ID (`hs.screen:id()`), it's UUID (`hs.screen:getUUID()`), or as an `hs.screen` object. If no screen is specified, the screen returned by `hs.screen.mainScreen()` is used.

Returns:
 * a table containing space IDs for the spaces for the screen, or nil and an error message if there is an error.

Notes:
 * the table returned has its __tostring metamethod set to `hs.inspect` to simplify inspecting the results when using the Hammerspoon Console.

- - -

<a name="toggleAppExpose"></a>
~~~lua
spaces.toggleAppExpose() -> None
~~~
Toggles the current applications Exposé display

Parameters:
 * None

Returns:
 * None

Notes:
 * this is the same functionality as provided by the System Preferences -> Mission Control -> Hot Corners... -> Application Windows setting or the App Exposé trackpad swipe gesture (3 or 4 fingers down).

- - -

<a name="toggleLaunchPad"></a>
~~~lua
spaces.toggleLaunchPad() -> None
~~~
Toggles the Launch Pad display.

Parameters:
 * None

Returns:
 * None

Notes:
 * this is the same functionality as provided by the System Preferences -> Mission Control -> Hot Corners... -> Launch Pad setting, the Launch Pad touchbar icon, or the Launch Pad trackpad swipe gesture (Pinch with thumb and three fingers).

- - -

<a name="toggleMissionControl"></a>
~~~lua
spaces.toggleMissionControl() -> None
~~~
Toggles the Mission Control display

Parameters:
 * None

Returns:
 * None

Notes:
 * this is the same functionality as provided by the System Preferences -> Mission Control -> Hot Corners... -> Mission Control setting, the Mission Control touchbar icon, or the Mission Control trackpad swipe gesture (3 or 4 fingers up).

- - -

<a name="toggleShowDesktop"></a>
~~~lua
spaces.toggleShowDesktop() -> None
~~~
Toggles moving all windows on/off screen to display the desktop underneath.

Parameters:
 * None

Returns:
 * None

Notes:
 * this is the same functionality as provided by the System Preferences -> Mission Control -> Hot Corners... -> Desktop setting, the Show Desktop touchbar icon, or the Show Desktop trackpad swipe gesture (Spread with thumb and three fingers).

- - -

<a name="windowSpaces"></a>
~~~lua
spaces.windowSpaces(window) -> table | nil, error
~~~
Returns a table containing the space IDs for all spaces that the specified window is on.

Parameters:
 * `window` - an integer specifying the ID of the window, or an `hs.window` object

Returns:
 * a table containing the space IDs of all spaces the window is on, or nil and an error message if an error occurs.

Notes:
 * the table returned has its __tostring metamethod set to `hs.inspect` to simplify inspecting the results when using the Hammerspoon Console.

 * If the window ID does not specify a valid window, then an empty array will be returned.
 * For most windows, this will be a single element table; however some applications may create "sticky" windows that may appear on more than one space.
   * For example, the container windows for `hs.canvas` objects which have the `canJoinAllSpaces` behavior set will appear on all spaces and the table returned by this function will contain all spaceIDs for the screen which displays the canvas.

- - -

<a name="windowsForSpace"></a>
~~~lua
spaces.windowsForSpace(spaceID) -> table | nil, error
~~~
Returns a table containing the window IDs of *all* windows on the specified space

Parameters:
 * `spaceID` - an integer specifying the ID of the space

Returns:
 * a table containing the window IDs for *all* windows on the specified space

Notes:
 * the table returned has its __tostring metamethod set to `hs.inspect` to simplify inspecting the results when using the Hammerspoon Console.

 * The list of windows includes all items which are considered "windows" by macOS -- this includes visual elements usually considered unimportant like overlays, tooltips, graphics, off-screen windows, etc. so expect a lot of false positives in the results.
 * In addition, due to the way Accessibility objects work, only those window IDs that are present on the currently visible spaces will be finable with `hs.window` or exist within `hs.window.allWindows()`.

 * This function *will* prune Hammerspoon canvas elements from the list because we "own" these and can identify their window ID's programmatically. This does not help with other applications, however.

 * Reviewing how third-party applications have generally pruned this list, I believe it will be necessary to use `hs.window.filter` to prune the list and access `hs.window` objects that are on the non-visible spaces.
   * as `hs.window.filter` is scheduled to undergo a re-write soon to (hopefully) dramatically speed it up, I am providing this function *as is* at present for those who wish to experiment with it; however, I hope to make it more useful in the coming months and the contents may change in the future (the format won't, but hopefully the useless extras will disappear requiring less pruning logic on your end).

### Module Variables

<a name="MCwaitTime"></a>
~~~lua
spaces.MCwaitTime
~~~
Specifies how long to delay before performing the accessibility actions for [hs.spaces.gotoSpace](#gotoSpace) and [hs.spaces.removeSpace](#removeSpace)

Notes:
 * The above mentioned functions require that the Mission Control accessibility objects be fully formed before the necessary action can be triggered. This variable specifies how long to delay before performing the action to complete the function. Experimentation on my machine has found that 0.3 seconds provides sufficient time for reliable functionality.

 * If you find that the above mentioned functions do not work reliably with your setup, you can try adjusting this variable upwards -- the down side is that the larger this value is, the longer the Mission Control display is visible before returning the user to what they were working on.

 * Once you have found a value that works reliably on your system, you can use [hs.spaces.setDefaultMCwaitTime](#setDefaultMCwaitTime) to make it the default value for your system each time the `hs.spaces` module is loaded.

- - -

### License

>     The MIT License (MIT)
>
> Copyright (c) 2021 Aaron Magill
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
>


