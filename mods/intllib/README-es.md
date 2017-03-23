
# Bilioteca de internacionalización para Minetest

Por Diego Martínez (kaeza).
Lanzada bajo Unlicense. Véase `LICENSE.md` para más detalles.

Éste mod es un intento por proveer soporte para internacionalización
de los mods (algo que a Minetest le falta de momento).

Si tienes alguna duda/comentario, por favor publica en el
[tema del foro][topic]. Por reporte de errores, use el
[bugtracker][bugtracker] en Github.

## Cómo usar

Si eres un jugador regular en busca de textos traducidos, simplemente
[instala][installing_mods] éste mod como cualquier otro.

El mod trata de detectar tu idioma, pero ya que no hay una forma portable de
hacerlo, prueba varias alternativas:

* `language` setting in `minetest.conf`.
* `LANGUAGE` environment variable.
* `LANG` environment variable.

En cualquier caso, el resultado final debería ser el
[Código de idioma ISO 639-1][ISO639-1] del idioma deseado.

### Desarrolladores

Si desarrollas mods y estás buscando añadir soporte de internacionalización
a tu mod, ve el fichero `doc/developer.md`.

### Traductores

Si eres un traductor, ve el fichero `doc/translator.md`.

[topic]: https://forum.minetest.net/viewtopic.php?id=4929
[bugtracker]: https://github.com/minetest-mods/intllib/issues
[installing_mods]: https://wiki.minetest.net/Installing_mods/es
[ISO639-1]: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
