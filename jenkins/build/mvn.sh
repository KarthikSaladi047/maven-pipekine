#!/bin/bash

echo "%%%%%%%%%%%%%%%%%%"
echo "building jar file"
echo "%%%%%%%%%%%%%%%%%%"

docker run --rm -v /var/jenkins_home/workspace/maven-project/maven-app/*:/app -v /root/.m2/:/root/.m2 -w /app maven:latest "$@"
