i18n mod for minetest_game, using gettext logic
===============================================

Into init.lua some parts of code were originally released as WTFPL or
as public domain. See init.lua for details.

-------------------------------------------------
Remaining code is released with following license
-------------------------------------------------

Copyright (C) 2015 netfab <netbox253@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

http://www.gnu.org/licenses/lgpl-2.1.html


------------------------------------
How do I enable i18n in my foo mod ?
------------------------------------
 0 - You need following gettext tools on your system to use scripts/i18n.sh
 bash script :
 	- xgettext
	- msgfmt

 1 - Add i18n dependency to mods/foo/depends.txt

 2 - In your code, set strings as translatable.
 Example (in patch format) :

-	minetest.chat_send_player(name, "You can only sleep at night.")
+	minetest.chat_send_player(name, _("You can only sleep at night."))

 3 - In mods/foo/init.lua, load *your own* mo file by using
 i18n.load_mo_file() function :

	local modpath = minetest.get_modpath("foo")
+	i18n.load_mo_file(modpath, "foo")

 Above example is loading :

	mods/foo/i18n/«language_code»/foo.mo

 Language_code is auto-detected from minetest language setting, or from LANG
 env variable. Default is : en

 4 - Generate a po template file that will be usable by translators :

	$ cd scripts/
	$ bash i18n.sh --po-templates
	entering ../mods/foo ... created i18n/template.po

 For each mod which depends on the i18n mod, this script will create an i18n/
 directory and will (re)generate a template.po file. Each mod will have its
 own i18n/template.po.

 5 - Prepare translation file (for example in french) :

	$ cd mods/foo/i18n/
	$ mkdir fr
	$ cp template.po fr/foo.po

 Now you can translate strings from mods/foo/i18n/fr/foo.po


-------------------------------------------
How do I build all mo files for packaging ?
-------------------------------------------
	$ cd scripts/
	$ bash i18n.sh --build-mo
	../mods/foo/i18n/fr/foo.po : 9 translated messages.
	../mods/bar/i18n/fr/bar.po : 7 translated messages.

