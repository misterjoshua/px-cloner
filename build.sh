#!/bin/bash -e

mkdir -p build

VERSION=${VERSION:-master}

sed -r "s#%%VERSION%%#$VERSION#" cloner.ps1 >build/cloner.ps1
sed -r "s#%%VERSION%%#$VERSION#" cloner.sh >build/cloner.sh
chmod +x build/cloner.sh