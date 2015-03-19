#!/bin/bash
#
# i18n.sh -- Shell script to update/build gettext files
#         -- Released with minetest_game mods/i18n mod
#
# Copyright (C) 2015 netfab <netbox253@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

ROOT_DIRECTORY=..

function display_help() {
	echo
	echo "Usage :"
	echo " $ $0 --po-templates"
	echo " $ $0 --build-mo"
	echo
	echo "If your mod depends on the i18n mod, « --po-templates » will create"
	echo "an i18n/ directory into your mod path, then it will extract gettext"
	echo "strings from your lua files. Finally, result will be saved as i18n/template.po"
	echo
	echo "« --build-mo » will scan for po files in mods/*/i18n/ subdirs and will"
	echo "compile them to binary format (using gettext's msgfmt)."
	echo
	echo "See also mods/i18n/README.txt."
	echo
}

function update_mods_templates() {
	for MOD_DIR in ${ROOT_DIRECTORY}/mods/*; do
		depfile="$MOD_DIR/depends.txt"
		if [[ -f "$depfile" ]]; then
			i18n=$(grep -c i18n "$depfile")
			if [[ $i18n -gt 0 ]]; then
				OLDPWD=$PWD
				cd "$MOD_DIR" || exit 7
				echo -n "entering $MOD_DIR ... "
				mkdir -p i18n || exit 8
				xgettext -L Lua *.lua --from-code=UTF-8 -o i18n/template.po
				echo "created i18n/template.po"
				cd "$OLDPWD" || exit 9
			fi
		fi
	done
}

function compile_catalogs() {
	for x in $(find ${ROOT_DIRECTORY}/mods/ -mindepth 4 -name *.po); do
		pofile=${x##*/}
		pofile=${pofile:0:-3}
		filepath=${x%/*}
		echo -n "${filepath}/${pofile}.po : "
		msgfmt "${filepath}/${pofile}.po" -cv -o "${filepath}/${pofile}.mo"
	done
}

case "$1" in
	'--po-templates')
		update_mods_templates
	;;
	'--build-mo')
		compile_catalogs
	;;
	*)
		display_help
	;;
esac
