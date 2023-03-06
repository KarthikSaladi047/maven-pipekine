#!/bin/bash

echo "%%%%%%%%%%%%%%%%%%"
echo "building jar file"
echo "%%%%%%%%%%%%%%%%%%"
WORKSPACE=/var/jenkins_home/workspace/maven-project

docker run --rm -v $WORKSPACE/maven-app:/app -v /root/.m2/:/root/.m2 -w /app maven:latest "$@"
