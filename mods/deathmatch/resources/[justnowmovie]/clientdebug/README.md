PhrozenByte Debug 1.0
=====================

PhrozenByte Debug is a utility resource for Multi Theft Auto: San Andreas (MTA:SA), allowing resource developers to add "quiet" debug messages to their resources. MTA's built-in debug mechanism (`outputDebugString()` function) floods both the server console and log with debug messages - even in productive environments. This bears the danger that a server administrator misses important messages in his server log.

This utility resource hooks into MTA's built-in `/debugscript` command to detect whether a (authorized) player is currently debugging MTA. If this is the case, it passes all debug messages to MTA's `outputDebugString()` function; otherwise it discards them.

For this purpose PhrozenByte Debug exports the following server-side functions:

* `int getDebugLevel()`
* `bool log(int level, [ player fromPlayer = nil, ] string message, [ int red = 255, int green = 255, int blue = 255 ])`
* `bool notice([ player fromPlayer = nil, ] string message, [ int red = 255, int green = 255, int blue = 255 ])`, `warn(…)` and `error(…)`

PhrozenByte Debug furthermore exports the following client-side functions:

* Client-side debugging:
  * `int getDebugLevel()`
  * `bool log(int level, string message, [ int red = 255, int green = 255, int blue = 255 ])`
  * `bool notice(string message, [ int red = 255, int green = 255, int blue = 255 ])`, `warn(…)` and `error(…)`
* Server-side debugging:
  * `void requestServerDebugLevel([ element callbackElement = resourceRoot, ] callbackEventName)`
  * `bool serverLog(int level, string message, [ int red = 255, int green = 255, int blue = 255 ])`
  * `bool serverNotice(string message, [ int red = 255, int green = 255, int blue = 255 ])`, `serverWarn(…)` and `serverError(…)`
* On-screen debugging:
  * `int getOnScreenLogCount([ string column = nil ])`
  * `int initOnScreenLog([ element sourceResource = nil, ] string message, [ int pauseUpdate = 0, mixed textAlign = "center", int red = 255, int green = 255, int blue = 255, int alpha = 255 ])`
  * `void clearOnScreenLog(int logID)`
  * `bool updateOnScreenLog(int logID, table data, [ string calcMode = nil ])`
  * `bool simpleOnScreenLog(string message, table data, [ mixed textAlign = "center", int red = 255, int green = 255, int blue = 255, int alpha = 255 ])`

Last but not least it exports the following shared functions:

* `void dump(mixed variable, [ string name = nil, int level = 3 ])`
* `string get(mixed variable)`

When you're experiencing problems with PhrozenByte Debug, please don't hesitate to create a new [Issue](https://github.com/PhrozenByte/mtasa-debug/issues) on GitHub. If you're a developer, you can help make PhrozenByte Debug better by contributing code; simply open a new [PR](https://github.com/PhrozenByte/mtasa-debug/pulls) on GitHub. Contributing to PhrozenByte Debug is highly appreciated! 

License tl;dr
-------------

PhrozenByte Debug is free software, released under the terms of the GNU Affero General Public License version 3 (GNU AGPL).

According to that you **can**...

- modify the software and create derivatives
- distribute the original or modified (derivative) works
- use the software for both private and commercial purposes

However, you **cannot**...

- sublicense the software, i.e. any user has the right to run, modify and distribute the work
- hold the software/license owner liable for damages (i.e. no warranty)

No matter what, you **must**...

- retain the original copyright and include the full license text
- state (non-trivial) changes made to the software and disclose your source code when distributing, publishing or serving a modified/derivative software

Put briefly, the GNU AGPL is virtually the same as the GNU GPL: a free software license with copyleft. However, there's a **important difference**: Serving the software is considered as distribution (the so-called "ASP loophole")!

This means that if you modify the software, you **must** allow any player connected to your MTA server to retrieve the source code of your modified/derivative version of PhrozenByte Debug (e.g. by providing download links). To make things easier, we have included a `DOWNLOAD.md` file which is declared as client-side file in the `meta.xml`. If you modify the software, you can comply with the condition by changing the download URL in this file.

To cut a long story short: We recommend you to fork our GitHub repository and push all changes you've made to your fork ([Learn more](https://guides.github.com/activities/forking/)). Change the URL in the `DOWNLOAD.md` to your forked GitHub repository and you're ready to go. We would love to see if you open a PR to let your improvements flow back into the upstream project - this is called *Contributing* ([Learn more](https://guides.github.com/activities/contributing-to-open-source/)).

PhrozenByte Debug furthermore adds the `/license` command returning the original copyright and declares the `LICENSE` file as client-side file in the `meta.xml`. This also serves the above license terms.

For the avoidance of doubt: Although the GNU AGPL is a copyleft license, you are *not* required to publish MTA resources (gamemodes, maps or any other kind of resource) using PhrozenByte Debug under the terms of the GNU AGPL. *Using* this resource does *not* "infect" your other resources, they do *not* become derivative works.

<small>Please note that this is a human-readable summary of the [full license](LICENSE).</small>

Copyright
---------

Copyright (C) 2015-2018  Daniel Rudolf <http://www.daniel-rudolf.de/>

This program is free software: you can redistribute it and/or modify it under the terms of the [GNU Affero General Public License](LICENSE) as published by the Free Software Foundation, version 3 of the License only.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details. You should have received a copy of the [GNU Affero General Public License](http://www.gnu.org/licenses/) along with this program.
