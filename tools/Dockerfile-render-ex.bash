#!/usr/bin/env bash

set -e

if [ "$#" -lt 3 ]; then
  (2> echo "Usage:\n$0 arch template_fname output_fname")
  exit 1
fi

ARCH="$1"
FNAME="$2"
DEST="$3"

case "$ARCH" in
('armhf')
  sed 's|##from_image##|armv7/armhf-ubuntu:14.04|' "$FNAME" > "$DEST" ;;
('arm64')
  sed 's|##from_image##|zlim/arm64-ubuntu:14.10|' "$FNAME" > "$DEST" ;;
('amd64')
  sed 's|##from_image##|ubuntu:trusty|' "$FNAME" > "$DEST" ;;
(*)
  (2> echo "Unknown or unsupported architecture: $1")
  exit 1
  ;;
esac

sed -i.bak "s|##arch##|$ARCH|" "$DEST" && rm -f "$DEST".bak
