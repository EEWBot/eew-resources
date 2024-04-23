#!/bin/bash

set -eu
shopt -s extglob


# --------------------------------

depends=( curl resvg tar )
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
TARGET="$DIR/target"

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
REDDITSANS_COMMIT="60e19b50bde6de34b695591a8a047a6a3618a37c"
REDDITSANS_PATH="$FONTS/RedditMono-ExtraBold.ttf"

if [[ ! -e "$REDDITSANS_PATH" ]]; then
	curl -L -f -s \
		--output "$REDDITSANS_PATH" \
		https://github.com/reddit/redditsans/raw/$REDDITSANS_COMMIT/fonts/mono/ttf/RedditMono-ExtraBold.ttf
fi


# depName=git@github.com:NDISCOVER/Exo-2.0.git
EXO_COMMIT="182060cd38adf3cde0d22add3f8009d30bd48cde"
EXO_PATH="$FONTS/Exo2-BoldItalic.ttf"

if [[ ! -e "$EXO_PATH" ]]; then
	curl -L -f -s \
		--output "$EXO_PATH" \
		https://github.com/NDISCOVER/Exo-2.0/raw/$EXO_COMMIT/fonts/ttf/Exo2-BoldItalic.ttf
fi


# depName=git@github.com:googlefonts/morisawa-biz-ud-gothic
BIZUD_COMMIT="18934af56b9c003ca58c54bffbf226848cb11032"
BIZUDP_PATH="$FONTS/BIZUDPGothic-Bold.ttf"

if [[ ! -e "$BIZUDP_PATH" ]]; then
	curl -L -f -s \
		--output "$BIZUDP_PATH" \
		https://github.com/googlefonts/morisawa-biz-ud-gothic/raw/$BIZUD_COMMIT/fonts/ttf/BIZUDPGothic-Bold.ttf
fi


# --------------------------------

mipmap=( 512 256 128 64 32 )

for m in "${mipmap[@]}"; do
	resvg "./intensity/intensity-packed.svg" \
		--skip-system-fonts --use-fonts-dir "$FONTS" \
		"$TARGET/intensity-$m.png" --width "$m" --height "$m"
done


mipmap=( 128 64 32 16 )

for m in "${mipmap[@]}"; do
	resvg "./epicenter-mark/epicenter-mark.svg" \
		--skip-system-fonts --use-fonts-dir "$FONTS" \
		"$TARGET/epicenter-mark-$m.png" --width "$m" --height "$m"
done


mipmap=( 512 256 128 64 32 )

for m in "${mipmap[@]}"; do
	resvg "./intensity-circle/intensity-packed.svg" \
		--skip-system-fonts --use-fonts-dir "$FONTS" \
		"$TARGET/intensity-circle-$m.png" --width "$m" --height "$m"
done


mipmap=( 1024 512 256 )

for m in "${mipmap[@]}"; do
	resvg "./watermark/watermark-packed.svg" \
		--skip-system-fonts --use-fonts-dir "$FONTS" \
		"$TARGET/watermark-$m.png" --width "$m" --height "$m"
done


# --------------------------------

simple_dirs=( branding )

for d in "${simple_dirs[@]}"; do
	find "$d" -name "*.svg" | while read -r SVG; do
		filename="$(basename "$SVG")"

		resvg "$SVG" \
			--skip-system-fonts --use-fonts-dir "$FONTS" \
			"$TARGET/${filename%.*}.png"
	done
done

# --------------------------------

RESOURCES="./resources"

cp -r "$TARGET" "$RESOURCES"
rm -f "$RESOURCES.tar"
tar -cvf "$RESOURCES.tar" "$RESOURCES"
rm -r "$RESOURCES"
