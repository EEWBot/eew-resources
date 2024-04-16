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

FONTDIR="$DIR/fonts"

mkdir -p "$FONTDIR"

# depName=git@github.com:googlefonts/Inconsolata.git
INCONSOLATA_COMMIT="fc1fc21081558b39a2db43bfd9b65bf9acb50701"
INCONSOLATA_PATH="$FONTDIR/Inconsolata-Black.ttf"
if [[ ! -e "$INCONSOLATA_PATH" ]]; then
	curl -L -f -s \
		--output "$INCONSOLATA_PATH" \
		https://github.com/googlefonts/Inconsolata/raw/$INCONSOLATA_COMMIT/fonts/ttf/Inconsolata-Black.ttf
fi


# depName=git@github.com:reddit/redditsans.git
REDDITSANS_COMMIT="60e19b50bde6de34b695591a8a047a6a3618a37c"
REDDITSANS_PATH="$FONTDIR/RedditMono-ExtraBold.ttf"

if [[ ! -e "$REDDITSANS_PATH" ]]; then
	curl -L -f -s \
		--output "$REDDITSANS_PATH" \
		https://github.com/reddit/redditsans/raw/$REDDITSANS_COMMIT/fonts/mono/ttf/RedditMono-ExtraBold.ttf
fi


# --------------------------------

mipmap=( 512 256 128 64 32 )

for m in "${mipmap[@]}"; do
	resvg "./intensity/intensity-packed.svg" \
		--skip-system-fonts --use-fonts-dir "$FONTDIR" \
		"intensity-$m.png" --width "$m" --height "$m"
done

