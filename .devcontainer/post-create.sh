#!/bin/bash

# Packages to install
PACKAGES=(
    arydshln
    comment
    float
    here
    jknapltx
    listings
    rsfs
)

tlmgr install "${PACKAGES[@]}"
