#! /bin/bash

me=$(basename "${BASH_SOURCE[0]}");

if [[ $# -lt 1 ]]; then
	echo "Usage: $me FILE..." >&2;
	exit 1;
fi

mkdir -p locale;
echo "Generating template..." >&2;
xgettext --from-code=UTF-8 -kS -kNS:1,2 -k_ \
		-o locale/template.pot "$@" \
		|| exit;

cd locale;

for file in *.po; do
	echo "Updating $file..." >&2;
	msgmerge --update "$file" template.pot;
done

echo "DONE!" >&2;
