#!/bin/bash

ARTIFACT=$1
VERSION=$2
DEPLOY_E=$3
DEPLOY_WS=$4
BRANCH=$5

if [ -z ${ARTIFACT} ] || [ -z ${VERSION} ] || [ -z ${DEPLOY_E} ] || [ -z ${DEPLOY_WS} ] ; then
    echo "require 4 params: Artifact, Version, Branch, DeployEnv, DeployWorkspace; options: Branch"
    exit -1
else
    echo "start service params ARTIFACT: $ARTIFACT, VERSION: $VERSION, DEPLOY_E: $DEPLOY_E, DEPLOY_WS: $DEPLOY_WS BRANCH: $BRANCH"
fi

LOG_NAME=process
TIME=`date "+%Y%m%d%H%M%S"`
DEPLOY_DIR=${DEPLOY_WS}/${ARTIFACT}
SERVER_ID=${DEPLOY_DIR}/server.pid
DOWNLOAD_URL=http://jenkins.tools.lwork.com/artifact/${BRANCH}/${ARTIFACT}/${VERSION}/${ARTIFACT}.jar

function errorExit(){
    echo $1
    exit -1
}

function checkCmd(){
    if [ $? != 0 ]; then
        errorExit "$1"
    fi
}

function checkStartEnv (){
    if [ "$DEPLOY_E" != "test" ]  && [ "$DEPLOY_E" != "qa" ]  && [ "$DEPLOY_E" != "prod" ]; then
        errorExit "start $ARTIFACT with bad env: $DEPLOY_E"
    fi
}

function getVersionArtifact(){
    if [ ! -z ${BRANCH} ]; then
        if [ ! -e ${DEPLOY_DIR} ]; then
            mkdir ${DEPLOY_DIR}
        fi
        cd ${DEPLOY_DIR}
        if [ -f ${ARTIFACT}.jar ] ; then
            rm ${ARTIFACT}.jar
        fi
        wget ${DOWNLOAD_URL}
        checkCmd "download artifact $ARTIFACT with version $VERSION error"

        if [ ! -f ${ARTIFACT}.jar ] ; then
            errorExit "can not find artifact $ARTIFACT with version $VERSION use branch $BRANCH from: $DOWNLOAD_URL"
        fi
        echo "download artifact $ARTIFACT with version $VERSION use branch $BRANCH done"
    fi
}

function backupArtifact(){
    if [ ! -z ${BRANCH} ]; then
        cd ${DEPLOY_DIR}
        if [ ! -e backup ]; then
            mkdir backup
        fi
        if [ -f ${ARTIFACT}-*.jar ] ; then
            mv ${ARTIFACT}-*.jar backup/${ARTIFACT}-${TIME}.jar
            checkCmd "backup artifact $ARTIFACT error"
        fi
        ### rename the wget jar
        mv ${ARTIFACT}.jar ${ARTIFACT}-${VERSION}.jar
        checkCmd "rename artifact $ARTIFACT.jar to $ARTIFACT-$VERSION.jar error"
        echo "backup $ARTIFACT done"
    fi
}

function runArtifact(){
    local PID="$(cat ${SERVER_ID})"
    if [ -n "$PID" ] ; then
        echo "killing old $ARTIFACT, pid: $PID"
        kill -9 ${PID}
        checkCmd "stop the old $ARTIFACT agent error"
    fi
    echo "=====>wait about 3s to stop the old $ARTIFACT agent"
    sleep 3
    local P_LOG=${DEPLOY_DIR}/log
    if [ -e "$P_LOG" ] && [ -f "$P_LOG/$LOG_NAME.log" ]; then
        mv ${P_LOG}/${LOG_NAME}.log ${P_LOG}/${LOG_NAME}_${TIME}.log
    fi

    local MEMOPS="-server -Xms800M -Xmx800M -XX:+UseNUMA -XX:+UseParallelGC -XX:NewRatio=1 -XX:MaxDirectMemorySize=1000M"
    local GCLOGOPS="-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -verbosegc -Xloggc:$DEPLOY_DIR/log/gc.$$.log"
    local APP_OPTS="-Dlogging.config=classpath:logback-deploy.xml"
    cd ${DEPLOY_DIR}
    nohup java ${MEMOPS} ${GCLOGOPS} ${APP_OPTS} -jar ${ARTIFACT}-${VERSION}.jar --spring.profiles.active=${DEPLOY_E}>nohup.out 2>&1 &
    checkCmd "run java $ARTIFACT-$VERSION.jar error"
}

### check artifact agent start with 30s
function checkAgent(){
    echo "=====>wait about 5s now valid the new $ARTIFACT agent"
    sleep 5
    local STARTED=0
    local PID=0
    for (( i=0; i<6 ; i++ )) ; do
        PID=`ps -ef | grep ${ARTIFACT}-${VERSION}.jar | grep java | grep -v grep | awk '{print $2}'`
        if [ -n "$PID" ]; then
            STARTED=1
            break
        else
            if [ ${i} == 5 ] ; then
                cat ${DEPLOY_DIR}/nohup.out
                errorExit "the artifact $ARTIFACT with version $VERSION agent start error"
            fi
            echo "=====>wait about 5s now valid the new $ARTIFACT agent"
            sleep 5
        fi
    done

    echo "=====>wait about 5s to double confirm the new $ARTIFACT agent"
    sleep 5
    ### double check artifact agent started
    PID=`ps -ef | grep ${ARTIFACT}-${VERSION}.jar | grep java | grep -v grep | awk '{print $2}'`
    if [ ${STARTED} == 1 ] && [ -n "$PID" ]; then
        cd DEPLOY_DIR
        echo ${PID} > SERVER_ID
        echo "the artifact $ARTIFACT with version $VERSION agent start done"
    else
        cat ${DEPLOY_DIR}/nohup.out
        errorExit "the artifact $ARTIFACT with version $VERSION agent start error"
    fi
}

checkStartEnv
getVersionArtifact
backupArtifact
runArtifact
checkAgent