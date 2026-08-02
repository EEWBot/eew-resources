#!/bin/bash

set -eu
shopt -s extglob

# --------------------------------

depends=( wget tar )
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

BIN="./bin"

mkdir -p "$BIN"
pushd "$BIN"

# depName=RazrFalcon/resvg
RESVG_VERSION="v0.47.0"

wget "https://github.com/RazrFalcon/resvg/releases/download/${RESVG_VERSION}/resvg-linux-x86_64.tar.gz"
tar xf resvg-linux-x86_64.tar.gz

popd

# --------------------------------

export PATH="$BIN:$PATH"
