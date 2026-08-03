#!/bin/bash

set -eu
shopt -s extglob


# --------------------------------

depends=( curl resvg )
notfound=()

for app in "${depends[@]}"; do
	if ! type "$app" > /dev/null 2>&1; then
		notfound+=("$app")
	fi
done


if [[ ${#notfound[@]} -ne 0 ]]; then
	echo Failed to lookup dependency:

	for app in "${notfound[@]}"; do
		echo "- $app"
	done

	exit 1
fi

# --------------------------------

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

set -x

# --------------------------------

FONTS="$DIR/fonts"
TARGET="$DIR/static/"

mkdir -p "$FONTS"
mkdir -p "$TARGET"

# --------------------------------

# depName=git@github.com:googlefonts/Inconsolata.git
INCONSOLATA_COMMIT="fc1fc21081558b39a2db43bfd9b65bf9acb50701"
INCONSOLATA_PATH="$FONTS/Inconsolata-Black.ttf"
if [[ ! -e "$INCONSOLATA_PATH" ]]; then
	curl -L -f -s \
		--output "$INCONSOLATA_PATH" \
		https://github.com/googlefonts/Inconsolata/raw/$INCONSOLATA_COMMIT/fonts/ttf/Inconsolata-Black.ttf
fi


# depName=git@github.com:reddit/redditsans.git
REDDITSANS_COMMIT="aae51f87b9dc16ab78e8013c1f945dda85318ecc"
REDDITSANS_PATH="$FONTS/RedditMono-ExtraBold.ttf"

if [[ ! -e "$REDDITSANS_PATH" ]]; then
	curl -L -f -s \
		--output "$REDDITSANS_PATH" \
		https://github.com/reddit/redditsans/raw/$REDDITSANS_COMMIT/fonts/mono/ttf/RedditMono-ExtraBold.ttf
fi


# --------------------------------

intensities=( 1 2 3 4 5-minus 5-plus 6-minus 6-plus 7 )
size=256

for i in "${intensities[@]}"; do
	mkdir -p "$TARGET/intensity-icon/"
	resvg "./intensity/intensity-$i.svg" \
		--skip-system-fonts --use-fonts-dir "$FONTS" \
		"$TARGET/intensity-icon/$i.png" --width "$size" --height "$size"
done
