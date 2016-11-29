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

# Creates a Git release branch with the specified name. Skips the creation step if the branch already exists
function create_release_branch() {
    local git_revision=$(git show | head -n 1 | cut -d ' ' -f 2)
    local release_branch=$(git branch -r --list origin/release)
	if [[ $release_branch == *"release"* ]]
        info "Release branch already exists. Skipping creation step."
    else
        info "Creating release branch based on the initial master"
        git checkout master
        git checkout $(git rev-list --max-parents=0 HEAD)
        git branch release
        git checkout release
        git push -u origin $1
        # Restore the previous state of Git
        git checkout $git_revision
    fi
}