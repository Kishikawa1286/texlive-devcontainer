#!/bin/bash

# Packages to install
PACKAGES=(
    comment
    rsfs
    jknapltx # Need for using mathrsfs
)

tlmgr install "${PACKAGES[@]}"
