#!/bin/bash
# Usage: install_tc.sh.sh <target>
# Install toolchain for the given target

export TARGET=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR=$DIR/..
PACKAGES_DIR=$BUILD_DIR/packages
STORE_URL="http://1dd40.http.tor01.cdn.softlayer.net/intu"
TC_NAME=$TARGET

TOOLCHAIN=

UNAME=$(uname)
if [ "$UNAME" == "Darwin" ]; then
	PLATFORM=mac64
	if [ "$TARGET" == "nao" ]; then
		TOOLCHAIN=ctc-mac64-atom-2.4.3.28
	elif [ "$TARGET" == "mac" ]; then
		TOOLCHAIN=naoqi-sdk-2.1.4.13-mac64
	fi
else
	PLATFORM=linux64
	if [ "$TARGET" == "nao" ]; then
		TOOLCHAIN=ctc-linux64-atom.2.4.3.28
	elif [ "$TARGET" == "linux" ]; then
		TOOLCHAIN=naoqi-sdk-2.1.4.13-linux64
	fi
fi

if [ ! -d "$PACKAGES_DIR" ]; then
mkdir -p "$PACKAGES_DIR"
fi

if [ "$TOOLCHAIN" != "" ]; then
		cd "$PACKAGES_DIR"
		TOOLCHAIN_ZIP=$TOOLCHAIN.zip

	if [ ! -d "$TOOLCHAIN" ]; then
		# pursue download
		if [ ! -e "$TOOLCHAIN_ZIP" ]; then
			echo "Downloading toolchain $TOOLCHAIN_ZIP..."
			curl "/$TOOLCHAIN_ZIP" --output $TOOLCHAIN_ZIP
		fi
		unzip $TOOLCHAIN_ZIP
	fi

	cd "$BUILD_DIR"
	qitoolchain create $TC_NAME "$PACKAGES_DIR/$TOOLCHAIN/toolchain.xml"
	if [ $? != 0 ]; then exit 1; fi
	qibuild add-config $TC_NAME --toolchain $TC_NAME
	if [ $? != 0 ]; then exit 1; fi
else
	cd "$BUILD_DIR"
	echo "Creating toolchain for target: $TARGET..."
	qitoolchain create $TC_NAME
	qibuild add-config $TC_NAME --toolchain $TC_NAME
fi

# download target specific pagaes
mkdir -p "$PACKAGES_DIR"/$TARGET
cd "$PACKAGES_DIR"/$TARGET

"$DIR"/download_dep.sh $TARGET
if [ $? -ne 0 ]; then exit 1; fi

# Ensure that if there are no dependencies, it does not try to install anything
shopt -s nullglob

echo Installing toolchains...
for f in *.zip; do
	NAME=$(basename "$f")
	echo "Installing $NAME into toolchain..."
	qitoolchain add-package -c "$TC_NAME" $f --name "$NAME"
done
