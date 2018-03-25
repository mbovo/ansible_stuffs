#!/bin/bash
echo "checking prerequisites:"

if [ -z "$1" ]; then
    echo "No argument given!"
    molecule
    exit 1
fi

if [ "$1" == "test" ]; then
    pip install -r ../molecule_includes/requirements.txt
    if [ $? -gt 0 ]; then
        echo "Error installing prerequisites please run"
        echo "      sudo pip install -r requirements.txt"
        exit 1
    fi
fi

DOCKER_ENDPOINT=$(echo $DOCKER_HOST |cut -d "/" -f 3 | cut -d ":" -f 1)

if [ -z $DOCKER_ENDPOINT ];then
    DOCKER_ENDPOINT="localhost"
fi

export DOCKER_ENDPOINT

# manage both manual and jenkins triggering
if [ "$WORKSPACE" == "" ]; then
	echo "no WORKSPACE, using current folder [$(pwd)]"
	WORKSPACE=$(pwd)
else
	echo "found WORKSPACE, using [${WORKSPACE}]"
fi
# SSH User keys
if [ "$BUILD_USER_KEY" == "" ]; then
	export BUILD_USER_KEY="files/id_rsa.pub"
fi
if [ "$BUILD_USER_PRIVKEY" == "" ]; then
	export BUILD_USER_PRIVKEY="files/id_rsa"
fi

export ANSIBLE_ROLES_PATH="${WORKSPACE}/moleculesrc/target/bin/roles/"
export FLEP_TARGET_PATH="${WORKSPACE}/moleculesrc/target/facility"

echo "set BUILD_USER_KEY [$BUILD_USER_KEY]"
echo "set BUILD_USER_PRIVKEY [$BUILD_USER_PRIVKEY]"
echo "set FLEP_TARGET_PATH [$FLEP_TARGET_PATH]"
echo "set ANSIBLE_ROLES_PATH [$ANSIBLE_ROLES_PATH]"
echo "set DOCKER_ENDPOINT [$DOCKER_ENDPOINT]"




