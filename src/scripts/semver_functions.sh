#!/usr/bin/env bash

# Copyright (c) 2016 SECTION6 Limited. All rights reserved.
#
# This file is part of Bash Release Tools.
#
# Bash Release Tools is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Bash Release Tools is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Bash Release Tools. If not, see <http://www.gnu.org/licenses/>.

source shared_functions.sh

SEMVER_REGEX="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\-?([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$"

# Validates that the specified version string matches the semver scheme.
# On success the inbuilt BASH_REMATCH array is populated with the major, minor, patch, prerelease and build version numbers.
function validate_version {
  if [[ "$1" =~ $SEMVER_REGEX ]]; then
    echo "$1"
  else
    error "$version does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'"
  fi
}

# Returns the major version from the specified version string.
function get_major_version() {
    validate_version $1 > /dev/null
    local major_version=${BASH_REMATCH[1]}
    echo $major_version
}

# Returns the minor version from the specified version string.
function get_minor_version() {
    validate_version $1 > /dev/null
    local minor_version=${BASH_REMATCH[2]}
    echo $minor_version
}

# Returns the patch version from the specified version string.
function get_patch_version() {
    validate_version $1 > /dev/null
    local patch_version=${BASH_REMATCH[3]}
    echo $patch_version
}

# Returns the prerelease version from the specified version string.
function get_prerelease_version() {
    validate_version $1 > /dev/null
    local prerelease_version=${BASH_REMATCH[4]}
    echo $prerelease_version
}

# Returns the build version from the specified version string.
function get_build_version() {
    validate_version $1 > /dev/null
    local build_version=${BASH_REMATCH[1]}
    echo $build_version
}

# Returns a new version string
function make_version() {
    local version="$1.$2.$3"
    # Append optional prerelease version
    if [ -n "$4" ]; then
        version="$version-$4"
    fi
    # Append optional build version
    if [ -n "$5" ]; then
        version="$version+$5"
    fi
    validate_version $version > /dev/null
    echo $version
}

# Increments the major version for the specified version string and returns a new base version
function bump_major_version() {
    local major_version=$(get_major_version $1)
    major_version=$(($major_version + 1))
    echo $(make_version $major_version 0 0 $(get_prerelease_version $1))
}

# Increments the major version for the specified version string and returns a new base version
function bump_minor_version() {
    local minor_version=$(get_minor_version $1)
    minor_version=$(($minor_version + 1))
    echo $(make_version $(get_major_version $1) $minor_version 0 $(get_prerelease_version $1))
}

# Increments the patch version for the specified version string and returns a new base version
function bump_patch_version() {
    local patch_version=$(get_patch_version $1)
    patch_version=$(($patch_version + 1))
    echo $(make_version $(get_major_version $1) $(get_minor_version $1) $patch_version $(get_prerelease_version $1))
}

# Conforms the specified version string to a release version, and optionally appends a build version if specified.
function to_release_version() {
    local version=$(make_version $(get_major_version $1) $(get_minor_version $1) $(get_patch_version $1) "" $2)
    version=$(validate_version $version)
    echo $version
}

# Conforms the specified version string to a prerelease version, and optionally appends a build version if specified.
function to_prerelease_version() {
    if [ -z "$2" ]; then
        error "No prerelease version was specified"
    fi
    local version=$(make_version $(get_major_version $1) $(get_minor_version $1) $(get_patch_version $1) $2 $3)
    version=$(validate_version $version)
    echo $version
}