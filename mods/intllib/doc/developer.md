
# Intllib developer documentation

In order to enable it for your mod, copy some boilerplate into your
source file(s). What you need depends on what you want to support.

There are now two main interfaces: one using the old plain text file method,
and one using the new support for [gettext][gettext] message catalogs (`.po`).
Read below for details on each one.

You will also need to optionally depend on intllib, to do so add `intllib?`
to an empty line in your `depends.txt`. Also note that if intllib is not
installed, the getter functions are defined so they return the string
unchanged. This is done so you don't have to sprinkle tons of `if`s (or
similar constructs) to check if the lib is actually installed.

## New interface

You will need to copy the file `lib/intllib.lua` into the root directory of
your mod, then include this boilerplate code in files needing localization:

    -- Load support for intllib.
    local MP = minetest.get_modpath(minetest.get_current_modname())
    local S, NS = dofile(MP.."/intllib.lua")

Use the usual `xgettext` command line tool from [gettext][gettext], to
generate your catalog files in a directory named `locale`.

### Basic workflow

This is the basic workflow for working with [gettext][gettext]

Each time you have new strings to be translated, you should do the following:

    cd /path/to/mod
    /path/to/intllib/tools/xgettext.sh file1.lua file2.lua ...

The script will create a directory named `locale` if it doesn't exist yet,
and will generate the file `template.pot`. If you already have translations,
the script will proceed to update all of them with the new strings.

The script passes some options to the real `xgettext` that should be enough
for most cases. You may specify other options if desired:

    xgettext.sh -o file.pot --keyword=blargh:4,5 a.lua b.lua ...

NOTE: There's also a Windows batch file `xgettext.bat` for Windows users,
but you will need to install the gettext command line tools separately. See
the top of the file for configuration.

## Old interface

You will need this boilerplate code:

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

Next, for each translatable string in your sources, use the `S` function
(defined in the snippet) to return the translated string. For example:

    minetest.register_node("mymod:mynode", {
        -- Simple string:
        description = S("My Fabulous Node"),
        -- String with insertions:
        description = S("@1 Car", "Blue"),
        -- ...
    })

Then, you create a `locale` directory inside your mod directory, and create
a "template" file (by convention, named `template.txt`) with all the
translatable strings (see *Locale file format* below). Translators will
translate the strings in this file to add languages to your mod.

[gettext]: https://www.gnu.org/software/gettext/
