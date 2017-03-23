
# Locale file format

*Note: This document explains the old conf/ini-like file format.
The new interface uses [gettext][gettext] `.po` files.
See [The Format of PO Files][PO-Files] for more information.*

Here's an example for a Spanish locale file (`es.txt`):

	# A comment.
	# Another comment.
	This line is ignored since it has no equals sign.
	Hello, World! = Hola, Mundo!
	String with\nnewlines = Cadena con\nsaltos de linea
	String with an \= equals sign = Cadena con un signo de \= igualdad

Locale (or translation) files are plain text files consisting of lines of the
form `source text = translated text`. The file must reside in the mod's `locale`
subdirectory, and must be named after the two-letter
[ISO 639-1 Language Code][ISO639-1] of the language you want to support.

The translation files should use the UTF-8 encoding.

Lines beginning with a pound sign are comments and are effectively ignored
by the reader. Note that comments only span until the end of the line;
there's no support for multiline comments. Lines without an equals sign are
also ignored.

Characters that are considered "special" can be "escaped" so they are taken
literally. There are also several escape sequences that can be used:

  * Any of `#`, `=` can be escaped to take them literally. The `\#`
    sequence is useful if your source text begins with `#`.
  * The common escape sequences `\n` and `\t`, meaning newline and
    horizontal tab respectively.
  * The special `\s` escape sequence represents the space character. It
    is mainly useful to add leading or trailing spaces to source or
    translated texts, as these spaces would be removed otherwise.

[gettext]: https://www.gnu.org/software/gettext
[PO-Files]: https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html
[ISO639-1]: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
