# Lib de Internacionalização para Minetest

Por Diego Martínez (kaeza).
Lançado sob Unlicense. Veja `LICENSE.md` para detalhes.

Este mod é uma tentativa de fornecer suporte de internacionalização para mods
(algo que Minetest atualmente carece).


Se você tiver algum comentário/sugestão, favor postar no 
[tópico do fórum][topico]. Para reportar bugs, use o 
[rastreador de bugs][bugtracker] no GitHub.


## Como usar

Se você é um jogador regular procurando por textos traduzidos, 
basta instalar este mod como qualquer outro, e então habilite-lo na GUI.

O mod tenta detectar o seu idioma, mas como não há atualmente nenhuma 
maneira portátil de fazer isso, ele tenta várias alternativas:

Para usar este mod, basta [instalá-lo][instalando_mods]
e habilita-lo na GUI.

O modificador tenta detectar o idioma do usuário, mas já que não há atualmente 
nenhuma maneira portátil para fazer isso, ele tenta várias alternativas, e usa 
o primeiro encontrado:

  * `language` definido em `minetest.conf`.
  * Variável de ambiente `LANGUAGE`.
  * Variável de ambiente `LANG`.
  * Se todos falharem, usa `en` (inglês).

Em todo caso, o resultado final deve ser um 
[Código de Idioma ISO 639-1][ISO639-1] do idioma desejado.

### Desenvolvedores de mods

Se você é um desenvolvedor de mod procurando adicionar suporte de 
internacionalização ao seu mod, consulte `doc/developer.md`.

### Tradutores

Se você é um tradutor, consulte `doc/translator.md`.

[topico]: https://forum.minetest.net/viewtopic.php?id=4929
[bugtracker]: https://github.com/minetest-mods/intllib/issues
[instalando_mods]: http://wiki.minetest.net/Installing_Mods/pt-br
[ISO639-1]: https://pt.wikipedia.org/wiki/ISO_639
