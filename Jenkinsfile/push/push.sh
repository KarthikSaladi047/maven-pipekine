#!/bin/bash

echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%%%% pushing image %%%%%%%%"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%"


IMAGE="maven-project"

echo "%%%%% Logging in %%%%%%%%%%"
docker login -u karthiksaladi047 -p $PASS

echo "%%%%%%%%%%% Tagging Image %%%%%"
docker tag $IMAGE:$BUILD_TAG karthiksaladi047/$IMAGE:$BUILD_TAG

echo "%%%%%%%%%% Pushing Image %%%%%%%%%"
docker push karthiksaladi047/$IMAGE:$BUILD_TAG 
