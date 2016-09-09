# sandsmas
A visual editor for LÖVE, that runs in LÖVE.

![example screenshot](http://i.imgur.com/SCWmBTm.png)

# Structure
The basic structure is that there is, from least complex to most complex:
* **Underlying Libraries** specifically chosen because they do what they do the best.
* **Lasagna** composed of the underlying libraries, in several layers, with just enough glue to combine them meaningfully without permanently binding to a particular library for a given purpose.
	* **Layer 1** low-level serialization and entity-component relationships that will make networking & physics a lot easier.
	* **Layer 2** mid-level features that integrate with the structure provided from layer 1, such as graphic optimizations and complex rendering.
	* **Layer 3** high-level features, such as logging, profiling, and libraries that editor tools can take advantage of.
* **A Project Structure** a specially formatted love project that will enable the editor to edit it while still being permissive about its configuration.
* **A Bootstrap** maintained separate from the editor, allowing for running of project files as a standalone and within the editor.
* **The Editor** that is capable of producing project files and allowing for easy composition of a game.

## Lasagna
Below are some example layer categories and some candidate libraries that would be nice to have in each.
* **Serialization & Net:** [tiny-ecs](https://github.com/bakpakin/tiny-ecs), [binser](https://github.com/bakpakin/binser), [trickle](https://github.com/bjornbytes/trickle), [hero](https://github.com/airstruck/hero), sock.lua
* **Configuration & Time:** [tick](https://github.com/bjornbytes/tick), [modrun](https://github.com/Asmageddon/modrun), [tactile](https://github.com/tesselode/tactile)
* **Rendering:** love.physics-visualizer, [chiro](https://github.com/bjornbytes/chiro), [anim8](https://github.com/kikito/anim8), [anim9](https://github.com/excessive/anim9), [Simple Tiled Implementation](https://github.com/karai17/Simple-Tiled-Implementation), [love-imgui](https://github.com/slages/love-imgui), scene.lua, anchor.lua
* **Assets:** [Autobatch](https://github.com/rxi/autobatch), [cargo](https://github.com/bjornbytes/cargo)
* **Profiling:** [PROBE](https://github.com/jorio/PROBE), [inspect.lua](https://github.com/kikito/inspect.lua), [lurker](https://github.com/rxi/lurker), [Lovebird](https://github.com/rxi/lovebird), [Lovecat](https://github.com/CoffeeKitty/lovecat), love-console, perfhud
* **Logging:** ansicolors, [log.lua](https://github.com/rxi/log.lua), log-lua, [i18n](https://github.com/excessive/i18n), argparse
* **Wiring:** talkback, middleclass, stateful, router.lua
* **Advanced Items:** [lume](https://github.com/rxi/lume/), pool.lua, memoize, LuaFun, lua-stdlib, [knife](https://github.com/airstruck/knife), microlight, CPML, LuaDate, dkjson, LuaFFT, Worp
* **Upkeep:** Busted, [RTFM](https://github.com/airstruck/rtfm), LDoc, luastache, semver
* **High Level:** lua-imgur, gyfcat, gifload, magick, sfxr, pegasus, turbo, lua-websockets, lua-sqlite3

