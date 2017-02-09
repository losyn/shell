#!/bin/bash

ARTIFACT=$1

if [ -z ${ARTIFACT} ] ; then
    echo "require 1 parameter: Artifact"
    exit -1
else
    echo "stop artifact param ARTIFACT: $ARTIFACT"
fi

PID=`ps -ef | grep ${ARTIFACT}-*.jar | grep java | grep -v grep | awk '{print $2}'`

function stopArtifact(){
    if [ -n "$PID" ] ; then
        echo "killing $ARTIFACT, pid: $PID"
        kill -9 ${PID}
        if [ $? == 0 ]; then
            echo "stop old $ARTIFACT agent done"
        else
            echo "stop old $ARTIFACT agent error"
            exit -1
        fi
    else
        echo "none $ARTIFACT agent to kill"
    fi
}

stopArtifact