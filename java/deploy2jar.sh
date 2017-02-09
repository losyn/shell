#!/bin/bash

ARTIFACT=$1
VERSION=$2
BRANCH=$3

DEPLOY_U=$4
DEPLOY_M=$5
DEPLOY_E=$6

if [ -z ${ARTIFACT} ] || [ -z ${VERSION} ] || [ -z ${BRANCH} ] || [ -z ${DEPLOY_U} ] || [ -z ${DEPLOY_M} ] || [ -z ${DEPLOY_E} ] ; then
    echo "require 6 params: Artifact, Version, Branch, DeployUser, DeployAddresses, DeployEnv"
    exit -1
else
    echo "deploy params ARTIFACT: $ARTIFACT, VERSION: $VERSION, BRANCH: $BRANCH, DEPLOY_U: $DEPLOY_U, DEPLOY_M: $DEPLOY_M, DEPLOY_E: $DEPLOY_E"
fi

### there static can change by project
DEPLOY_WS=/mnt/deploy
REGISTRY_DIR=/mnt/registry
SHELL_WS=/mnt/deploy/shell/java

RELEASE_DIR=${REGISTRY_DIR}/${BRANCH}/${ARTIFACT}/${VERSION}

### check pre cmd if error then echo $1 and exit
function checkCmd () {
    if [ $? != 0 ]; then
        echo $1
        exit -1
    fi
}

function deployArtifact () {
    if [ ! -z ${ARTIFACT} ] && [ ! -z ${VERSION} ] && [ ! -z ${BRANCH} ] && [ ! -z ${DEPLOY_U} ] && [ ! -z ${DEPLOY_M} ] && [ ! -z ${DEPLOY_E} ] ; then
        if [ ! -e "$RELEASE_DIR" ] || [ ! -f "$RELEASE_DIR/$ARTIFACT.jar" ]; then
            checkCmd "can not find artifact $ARTIFACT with version $VERSION use branch $BRANCH to deploy"
        fi
        echo "deploy $ARTIFACT version $VERSION use branch $BRANCH as env $DEPLOY_E to $DEPLOY_M"
        for M in ${DEPLOY_M[@]}; do
            echo "deploy $ARTIFACT with version $VERSION use branch $BRANCH to $M"
            ssh ${DEPLOY_U}@${M} "source /etc/profile && cd  && $SHELL_WS/start2jar.sh $ARTIFACT $VERSION $DEPLOY_E $DEPLOY_WS $BRANCH";
            checkCmd "deploy $ARTIFACT version $VERSION use branch $BRANCH to $M error, the next all will deny, please check the all deploys"
        done
    else
        echo "deploy archived params error"
        exit -1
    fi
}

deployArtifact