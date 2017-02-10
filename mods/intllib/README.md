
# Internationalization Lib for Minetest

By Diego Martínez (kaeza).
Released under Unlicense. See `LICENSE.md` for details.

This mod is an attempt at providing internationalization support for mods
(something Minetest currently lacks).

Should you have any comments/suggestions, please post them in the
[forum topic][topic]. For bug reports, use the [bug tracker][bugtracker]
on Github.

## How to use

If you are a regular player looking for translated texts, just
[install][installing_mods] this mod like any other one, then enable it
in the GUI.

The mod tries to detect your language, but since there's currently no
portable way to do this, it tries several alternatives:

* `language` setting in `minetest.conf`.
* `LANGUAGE` environment variable.
* `LANG` environment variable.
* If all else fails, uses `en`.

In any case, the end result should be the [ISO 639-1 Language Code][ISO639-1]
of the desired language.

### Mod developers

If you are a mod developer looking to add internationalization support to
your mod, see `doc/developer.md`.

### Translators

If you are a translator, see `doc/translator.md`.

[topic]: https://forum.minetest.net/viewtopic.php?id=4929
[bugtracker]: https://github.com/minetest-mods/intllib/issues
[installing_mods]: https://wiki.minetest.net/Installing_mods
[ISO639-1]: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
