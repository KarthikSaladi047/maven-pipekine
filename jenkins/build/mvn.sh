#!/bin/bash

echo "%%%%%%%%%%%%%%%%%%"
echo "building jar file"
echo "%%%%%%%%%%%%%%%%%%"
WORKSPACE=/home/projects/jenkins-volume/workspace/maven-project

docker run --rm -v $WORKSPACE/maven-app:/app -v /root/.m2/:/root/.m2 -w /app maven:latest "$@"
