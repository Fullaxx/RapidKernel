#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "$0: <old kvers> <old kvers>"
  exit 1
fi

if [ ! -f "./$1/config" ]; then
  echo "$1/config does not exist"
  exit 1
fi

if [ ! -f "./$2/config" ]; then
  echo "$2/config does not exist"
  exit 1
fi

# diff -ru "$1/config" "$2/config" | grep -v '^+#' | grep -v '^-#' | less

diff -ru "$1/config" "$2/config" | less
