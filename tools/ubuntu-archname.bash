#!/usr/bin/env bash

set -e

karch=$(uname -m)

case "$karch" in
  ('aarch64')
    echo 'arm64' ;;

  ('armv7'*)
    echo 'armhf' ;;

  ('x86_64')
    echo 'amd64' ;;

  (*)
    ( 2> echo "Unsupported achitecture: $karch" )
    exit 1
esac
