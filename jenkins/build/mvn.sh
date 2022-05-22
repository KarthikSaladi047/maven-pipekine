#!/bin/bash

echo "%%%%%%%%%%%%%%%%%%"
echo "building jar file"
echo "%%%%%%%%%%%%%%%%%%"
WORKSPACE=/docker/ansible-jenkins/jenkins_home/workspace/pipeline-docker-maven

docker run --rm -v $WORKSPACE/maven-app:/app -v /root/.m2/:/root/.m2 -w /app maven "$@" 

