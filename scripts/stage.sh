#!/bin/bash
#Usage: stage.sh <target>

export TARGET=$1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_CONFIG="build-$TARGET"

BUILD_DIR="$DIR"/../$BUILD_CONFIG
BIN_DIR="$BUILD_DIR"/sdk/bin
LIB_DIR="$BUILD_DIR"/sdk/lib
ETC_DIR="$DIR"/../etc
STAGE_DIR="$DIR"/../bin/$TARGET
LIBS_DIR="$DIR"/../lib/self-$TARGET
VERSION="$(cat $DIR/../version.txt)"

echo Staging files...
if [ -d "$STAGE_DIR" ]; then
	rm -rf "$STAGE_DIR"
fi
mkdir -p "$STAGE_DIR"

# copy all etc files into the stage directory
cp -R "$DIR/../etc" "$STAGE_DIR/"

# update the version number in all the profiles
pdir=$STAGE_DIR/etc/shared/profiles
if [ -d "$pdir" ]; then
  # only way to get compat w/ mac os x
  find $pdir -name 'body.json' -print0 | xargs --null -I% sh -c "sed -i.old -e "s/\"0.0.0\"/\"$VERSION\"/g" % && rm %.old"
fi

if [ -d "$BIN_DIR" ]; then
	echo "Staging bins.."
	cp -R -L "$BIN_DIR"/* "$STAGE_DIR"/
fi
if [ -d "$LIB_DIR" ]; then
	echo "Staging libs.."
	cp -R -L "$LIB_DIR"/* "$STAGE_DIR"/
fi
if [ -d "$LIBS_DIR" ]; then
	echo "Staging prebuilt libs.."
	cp -R -L "$LIBS_DIR"/* "$STAGE_DIR"/
fi

if [ -d "$DIR/${TARGET}_scripts" ]; then
	echo "Staging scripts.."
	cp "$DIR"/"${TARGET}"_scripts/* "$STAGE_DIR"/
fi

# special case for mac opencv libs
if [ "$TARGET" == "mac" ]; then
	mkdir -p "$STAGE_DIR/lib"
	mv "$STAGE_DIR"/libopencv_* "$STAGE_DIR"/lib/
fi

