#!/bin/bash
set -e

HERE="$(dirname $0)"
pushd "${HERE}"
source files.env

for dot in "${DOTFILES[@]}"; do
    thisdot="${dot#"$HOME"}"
    thisdot="${thisdot#/}"
    mkdir -vp -- "$(dirname -- ${dot})" || true
    cp -iv -- "${thisdot}" "${dot}" || true
done

