#!/bin/bash

ARTIFACT=$1
VERSION=$2
DESC=$3
GIT=$4
BRANCH=$5

### set BRANCH default master
if [ -z ${BRANCH} ] ; then
    BRANCH=master
fi
### set TAG_NAME TAG_INFO
if [ ${BRANCH} == "master" ] ; then
    TAG_NAME=V_${VERSION}
    TAG_INFO=", \"tag\": \"$TAG_NAME\""
fi

if [ -z ${ARTIFACT} ] || [ -z ${VERSION} ] || [ -z ${DESC} ] || [ -z ${GIT} ] ; then
    echo "require 4 params: Artifact, Version, Description, Git; options: Branch; default branch is master"
    exit -1
else
    echo "build params ARTIFACT: $ARTIFACT, VERSION: $VERSION, DESC: $DESC, GIT: $GIT, BRANCH: $BRANCH, TAG_NAME: $TAG_NAME"
fi

### there static can change by project
DEFAULT_V=5.0.0-SNAPSHOT
REGISTRY_DIR=/mnt/registry
WORKSPACE=/mnt/jenkins

TIME=`date "+%Y-%m-%d %H:%M"`
BRANCH_WS=${WORKSPACE}/${BRANCH}
PROJECT_DIR=${BRANCH_WS}/${ARTIFACT}
RELEASE_INFO=src/main/resources/release.info
RELEASE_DIR=${REGISTRY_DIR}/${BRANCH}/${ARTIFACT}/${VERSION}
R_DIR_INFO=${RELEASE_DIR}/release.info

function mkReleaseDir(){
    if [ ! -e "$RELEASE_DIR" ] ; then
        mkdir -p ${RELEASE_DIR}
        checkCmd "prepare registry release folder error"
    fi
}

function errorExit(){
    echo "$1"
    mkReleaseDir
    echo "{\"name\": \"$ARTIFACT\", \"version\": \"$VERSION\", \"desc\": \"$DESC\", \"time\": \"$TIME\"$TAG_INFO, \"error\": \"$1\"}" > ${R_DIR_INFO}
    exit -1
}

### check pre cmd if error then echo $1 and exit
function checkCmd(){
    if [ $? != 0 ]; then
        errorExit "$1"
    fi
}

### prepare project source
function prepareSource(){
    ### valid project & artifact
    if [ ! -e "$PROJECT_DIR" ] ; then
        mkdir -p ${BRANCH_WS}
        checkCmd "create $ARTIFACT branch $BRANCH workspace error"
        cd ${BRANCH_WS}
        git clone ${GIT} -b ${BRANCH}
        checkCmd "git clone project $ARTIFACT error"
    fi
    if [ ! -e "$PROJECT_DIR" ] ; then
        errorExit "get form the $GIT project is not the $ARTIFACT"
    fi

    ### git pull project source
    cd ${PROJECT_DIR}
    git pull
    checkCmd "git pull $ARTIFACT from $GIT error"
    echo "git pull $ARTIFACT done"

    mkReleaseDir
    echo "prepare $ARTIFACT registry release version folder done"
}

### update release info
function updateReleaseInfo(){
    cd ${PROJECT_DIR}
    echo "{\"name\": \"$ARTIFACT\", \"version\": \"$VERSION\", \"desc\": \"$DESC\", \"time\": \"$TIME\"$TAG_INFO}" > ${RELEASE_INFO}
    git add ${RELEASE_INFO}
    checkCmd "git add release.info error"
    git commit -a -m "release info update"
    checkCmd "git commit release.info error"
    git push
    checkCmd "git push release.info error"

    echo "new release tag: $VERSION created for $ARTIFACT"
}

### build artifact and do git tag
function buildArtifact(){
    cd ${PROJECT_DIR}
    mvn clean install
    checkCmd "mvn clean install to build $ARTIFACT error"
    local ARTIFACT_FILE=${RELEASE_DIR}/${ARTIFACT}.jar
    cp ${PROJECT_DIR}/target/${ARTIFACT}-${DEFAULT_V}.jar ${ARTIFACT_FILE}
    checkCmd "save archived file to registry $ARTIFACT_FILE error"
    cp ${PROJECT_DIR}/${RELEASE_INFO} ${R_DIR_INFO}
    checkCmd "save release.info file to registry $R_DIR_INFO error"

    if [ ! -z ${TAG_NAME} ]; then
        git tag ${TAG_NAME}
        checkCmd "git tag $TAG_NAME to $BRANCH error"
        git push --tags
        checkCmd "git push tag $TAG_NAME to $BRANCH error"
    fi
    echo "build done and save archived file into registry $RELEASE_DIR"
}

prepareSource
updateReleaseInfo
buildArtifact
