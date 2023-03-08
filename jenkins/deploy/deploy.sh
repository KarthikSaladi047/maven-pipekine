#!/bin/bash

echo maven-project > /tmp/.auth
echo $BUILD_TAG >> /tmp/.auth
echo $PASS >> /tmp/.auth

scp -i /opt/prod /tmp/.auth karthik@192.168.55.109:/tmp/.auth

scp -i /opt/prod ~/projects/maven-pipeline/jenkins/deploy/publish.sh karthik@192.168.55.109:/tmp/publish.sh

ssh -i /opt/prod karthik@192.168.55.109 "/tmp/publish.sh"
