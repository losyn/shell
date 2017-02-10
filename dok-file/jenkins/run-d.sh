#!/usr/bin/env bash

mkdir -p /mnt/jenkins

chown -R 1000 /mnt/jenkins

docker run -d -p 8080:8080 -v /mnt/jenkins:/jenkins/.jenkins --name jenkins jenkins:latest
