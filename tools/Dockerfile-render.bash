#!/usr/bin/env bash

set -e

if [ "$#" -lt 3 ]; then
  (2> echo "Usage:\n$0 arch template_fname output_fname")
  exit 1
fi

ARCH="$1"
FNAME="$2"
DEST="$3"

if [ "$ARCH" == 'armhf' ]; then
  # use a different container for build and exec cases
  case "$FNAME" in
    (*"-exec")
    sed 's|##from_image##|armhf-alpine|' "$FNAME" > "$DEST" ;;

    (*)
    sed 's|##from_image##|armv7/armhf-ubuntu:14.04|' "$FNAME" > "$DEST" ;;
  esac
elif [ "$ARCH" == 'arm64' ]; then
  case "$FNAME" in
    (*"-exec")
    sed 's|##from_image##|arm64-alpine|' "$FNAME" > "$DEST" ;;

    (*)
    sed 's|##from_image##|zlim/arm64-ubuntu:14.10|' "$FNAME" > "$DEST" ;;
  esac
elif [ "$ARCH" == 'amd64' ]; then
  case "$FNAME" in
    (*"-exec")
    sed 's|##from_image##|amd64-alpine|' "$FNAME" > "$DEST" ;;

    (*)
    sed 's|##from_image##|ubuntu:trusty|' "$FNAME" > "$DEST" ;;
  esac
else
  (2> echo "Unknown or unsupported architecture: $1")
  exit 1
fi

sed -i.bak "s|##arch##|$ARCH|" "$DEST" && rm -f "$DEST".bak
