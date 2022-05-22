#!/bin/bash

# copy the new jar to build loction
cp -f maven-app/target/*.jar jenkins/build/


echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
echo "building docker image"
echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

cd jenkins/build/ && docker compose -f docker-compose-build.yml build --no-cache


