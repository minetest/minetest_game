#!/bin/bash -e
world=$(mktemp -d)
trap 'rm -rf "$world" || :' EXIT

[ -f game.conf ] || { echo "Must be run in game root folder." >&2; exit 1; }

cp -v utils/test/world.mt "$world/"
chmod -R a+rwX "$world" # needed because server runs as unprivileged user inside container

vol=(
	-v "$PWD/utils/test/minetest.conf":/etc/minetest/minetest.conf
	--tmpfs /var/lib/minetest/.minetest
	-v "$PWD":/var/lib/minetest/.minetest/games/minetest_game
	-v "$world":/var/lib/minetest/.minetest/world
)
[ -z "$DOCKER_IMAGE" ] && DOCKER_IMAGE="ghcr.io/minetest/minetest:master"
docker run --rm -i "${vol[@]}" "$DOCKER_IMAGE"

exit 0
