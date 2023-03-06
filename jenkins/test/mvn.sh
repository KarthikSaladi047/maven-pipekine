#!/bin/bash

echo "%%%%%%%%%%%%%%%%%%"
echo "testing  jar file"
echo "%%%%%%%%%%%%%%%%%%"
WORKSPACE=/home/karthik/projects/jenkins-volume/workspace/maven-project

docker run --rm -v $WORKSPACE/maven-app:/app -v /root/.m2/:/root/.m2 -w /app maven:latest "$@"
