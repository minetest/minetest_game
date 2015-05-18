
Internationalization Lib for Minetest
By Diego Martínez (a.k.a. "Kaeza").
Released as WTFPL.

This mod is an attempt at providing internationalization support for mods
(something Minetest currently lacks).

How do I use it?
In order to enable it for your mod, copy the following code snippet and paste
it at the beginning of your source file(s):

	-- Boilerplate to support localized strings if intllib mod is installed.
	local S
	if minetest.get_modpath("intllib") then
		S = intllib.Getter()
	else
		-- If you don't use insertions (@1, @2, etc) you can use this:
		S = function(s) return s end

		-- If you use insertions, but not insertion escapes this will work:
		S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end

		-- Use this if you require full functionality
		S = function(s,a,...)if a==nil then return s end a={a,...}return s:gsub("(@?)@(%(?)(%d+)(%)?)",function(e,o,n,c)if e==""then return a[tonumber(n)]..(o==""and c or"")else return"@"..o..n..c end end) end
	end

You will also need to optionally depend on intllib, to do so add "intllib?" to
a empty line in your depends.txt. Also note that if intllib is not installed,
the S() function is defined so it returns the string unchanged. This is done
so you don't have to sprinkle tons of 'if's (or similar constructs) to check
if the lib is actually installed.

Next, for each "translatable" string in your sources, use the S() function
(defined in the snippet) to return the translated string. For example:

	minetest.register_node("mymod:mynode", {
		description = S("My Fabulous Node"),
		<...>
	})

Then, you create a `locale' directory inside your mod directory, with files
named after the two-letter ISO Language Code of the languages you want to
support. Here's an example for a Spanish locale file (`es.txt'):

	# Lines beginning with a pound sign are comments and are effectively ignored
	# by the reader. Note that comments only span until the end of the line;
	# there's no support for multiline comments.
	Hello, World! = Hola, Mundo!
	String with\nnewlines = Cadena con\nsaltos de linea
	String with an \= equals sign = Cadena con un signo de \= igualdad

Since there's currently no portable way to detect the language, this library
tries several alternatives, and uses the first one found:
  - `language' setting in `minetest.conf'
  - `LANG' environment variable (this is always set on Unix-like OSes).
  - Default of "en".
Note that in any case only up to the first two characters are used, so for
example, the settings "de_DE.UTF-8", "de_DE", and "de" are all equal.
Windows users have no `LANG' environment variable by default. To add it, do
the following:
  - Click Start->Settings->Control Panel.
  - Start the "System" applet.
  - Click on the "Advanced" tab.
  - Click on the "Environment variables" button
  - Click "New".
  - Type "LANG" (without quotes) as name and the language code as value.
  - Click OK until all dialogs are closed.
Alternatively for all platforms, if you don't want to modify system settings,
you may add the following line to your `minetest.conf' file:
	language = <language code>

Also note that there are some problems with using accented, and in general
non-latin characters in strings. Until a fix is found, please limit yourself
to using only US-ASCII characters.

Thanks for reading up to this point.
Should you have any comments/suggestions, please post them in the forum topic.

Let there be translated texts! :P
--
Yours Truly,
Kaeza
