#!/bin/bash
set -e

HERE="$(dirname $0)"
pushd "${HERE}"
source files.env

for dot in "${DOTFILES[@]}"; do
    thisdot="${dot#"$HOME"}"
    thisdot="${thisdot#/}"
    mkdir -vp -- "$(dirname -- ${thisdot})" || true
    cp -v -- "${dot}" "${thisdot}"
done

find . -type f -exec dos2unix -- {} \;

