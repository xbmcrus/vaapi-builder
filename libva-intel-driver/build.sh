#!/bin/sh
set -e

PKG_NAME="$(cd "$(dirname "$0")"; basename "$PWD")"
SRC_URL='git://anongit.freedesktop.org/vaapi/intel-driver'

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/../commons.sh"

version() {
    local delta='4'
    local major="$(git --git-dir="$SRC_DIR/.git" show $REV:configure.ac | awk '/m4_define\(\[intel_driver_major_version\]/ {print $2}' | tr -d '[\[\]\)]')"
    local minor="$(git --git-dir="$SRC_DIR/.git" show $REV:configure.ac | awk '/m4_define\(\[intel_driver_minor_version\]/ {print $2}' | tr -d '[\[\]\)]')"
    local micro="$(git --git-dir="$SRC_DIR/.git" show $REV:configure.ac | awk '/m4_define\(\[intel_driver_micro_version\]/ {print $2}' | tr -d '[\[\]\)]')"
    local pre="$(git --git-dir="$SRC_DIR/.git" show $REV:configure.ac | awk '/m4_define\(\[intel_driver_pre_version\]/ {print $2}' | tr -d '[\[\]\)]')"
    local version="${major}.${minor}.${micro}"
    [ -z "$pre" ] || version="$version.pre${pre}"
    _pkg_version "$version" "$delta"
}

_checkout() {
    local dest="$1"
    local deb_dir="$BUILD_DIR/debian"
    
    _git_checkout "$dest"
    cd "$dest"
    chmod 766 ./autogen.sh
    LIBVA_DEPS_LIBS=no LIBVA_DEPS_CFLAGS=no ./autogen.sh
    cd debian.upstream
    make
}

_deb_dir() {
    local deb_dir="$BUILD_DIR/debian"
    
    if [ ! -d "$deb_dir" ]
    then
        cp -r "$1/debian.upstream" "$deb_dir"
        cp -r "$DIR/debian"/* "$deb_dir"
    fi
    
    echo "$deb_dir"
}

_main $@
