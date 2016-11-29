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

source semver_functions.sh
source git_functions.sh

# Extract the version from the specified Maven POM file.
function get_artifact_version_from_pom_file() {
    #TODO: Improve this by using an XPath or XQuery call instead of a reqular expression match
    local pom_version=$(cat $1| sed -n 's:.*<version>\(.*\)</version>.*:\1:p' | head -n 1)
    echo $pom_version
}

function build() {
    pushd ..

    ./mvnw -U clean package

    # Login to ECR
    `aws ecr get-login`

    # Build Docker image
    docker build --no-cache -t ${EC2_CONTAINER_REGISTRY}/$APP_NAME .

    # Do not push Docker images for local builds
    if [ ${BUILD_ENVIRONMENT} != "local"  ]; then

        if [ ! -z $1 ]
        then
            if [ "$1" = "integration" ]
            then
                docker push ${EC2_CONTAINER_REGISTRY}/$APP_NAME:latest
            fi
       fi

    fi

    popd
}

function prepare_release() {
    pushd ..

    if [[ ! -d .git ]]; then
        warning "The current directory is $PWD before preparing release"
        error "Not a GIT repo!"
    fi

    # Ensure we are on the master branch
	if [ $(git branch | grep "^*" | awk '{print $2}') != "master" ]; then
	    error "Cannot prepare release from branch $current_branch. Please checkout master branch to continue."
    fi

    # Create release branch if required
    local git_branch=$(git ls-remote --heads origin | grep release | awk '{print $2}')
    if [[ "$git_branch" != "refs/heads/release" ]]; then
        create_release_branch
    else # fetch the existing release branch
        git fetch
        # if the release exists, it might not be the latest version, create it from scratch.
        if [[ "$(git branch | grep release | awk '{print $1}')" == "release" ]]; then
            git checkout master
            git branch -D release
        fi
        git checkout -b release origin/release
        git checkout master
    fi

    # Get the release version
    local version=$(get_artifact_version_from_pom_file pom.xml)
    echo $(validate_version $version)

    # Prepare the release sources
    git checkout release
    git merge master -X theirs --no-edit -m "Preparing release sources for version $version. Merged changes from master."
	git push origin release

    # Update the development version to the next minor version
    git checkout master
    version=$(bump_minor_version $version)
    ./mvnw -U release:update-versions -DdevelopmentVersion=$version
    ./mvnw -U clean
	find . -iname pom.xml | xargs git add # add all Maven POM files
	git commit -m "Preparing development sources for $version"
	git push origin master

	# must checkout release branch before releasing. Otherwise, the create_release() will fail.
	git checkout release

	popd
}

function create_release() {
    pushd ..

    # Ensure we are on the release branch
	if [ $(git branch | grep "^*" | awk '{print $2}') != "release" ]; then
	    error "Cannot prepare release from branch $current_branch. Please checkout release branch to continue."
    fi

    # showing the repo information before calling the maven release plugin
    git --version
    pwd
    git remote show origin
    git ls-remote | grep refs/heads/release

    ./mvnw -B release:prepare
    ./mvnw -B release:perform

	popd
}