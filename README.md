# Automation of building, testing & deploying a Java Application using Maven, Jenkins, Docker and Shell Scripting

The Stages involved in this project are:
- Local machine setup (Pre-requisites)
- Cloning Java App 
- Jenkins setup
- Jenkins Pipeline
- Jenkins Credentials
- Developing Shell Scripts for various processes (Build, Test & Deploy)
- Generating required Dockerfiles and Docker-compose files

## Local Machine Setup

  In this Project , I am using a **Ubuntu v20.04** as my local machine. We need to install Git, Docker and Docker-Compose before proceeding to next steps.

  - Install git
    ```
    sudo apt update
    sudo apt install git
    ```
  - Install docker and docker compose
    ```
    sudo apt-get update
    sudo apt install curl
    sudo apt-get install ca-certificates curl gnupg lsb-release
    sudo mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

## Clone Java App from Github

  Clone the repositiry into local machine.
  ```
  git clone https://github.com/KarthikSaladi047/maven-pipeline.git
  cd maven-pipeline
  ```

  The repository contains a simple Java application which outputs the string "Hello world!" and is accompanied by a couple of unit tests to check that the main application works as expected. The results of these tests are saved to a JUnit XML report.

## Jenkins Setup

In this project I am using a custom Jenkins Docker container as my Continuous Integration Server.

- The container got pre-installed with required packages like ansible, curl, docker and docker-compose. The follow is the Dockerfile for this container.

  ```
  FROM jenkins/jenkins

  USER root

  # Install ansible
  RUN apt-get update && apt-get install python3-pip -y && pip3 install ansible --upgrade && apt-get upgrade -y && apt-get update

  # Install Docker
  RUN apt-get -y  install ca-certificates curl gnupg lsb-release

  RUN  curl -fsSL https://download.docker.com/linux/debian/gpg |  gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" |      tee /etc/apt/sources.list.d/docker.list > /dev/null

  RUN apt-get update

  RUN apt-get -y  install docker-ce docker-ce-cli containerd.io docker-compose-plugin

  RUN usermod -aG docker jenkins

  USER jenkins
  ```
- Now we will build the Docker Image for the above Dockerfile.

  ```
  docker build --tag jenkins-docker .
  ```

- Now we will run the above Docker Image using Docker-compose and the corresponding docker-compose.yml file is below.

  ```
  version: '3'
  services:
    jenkins:
      container_name: jenkins 
      image: jenkins-docker
      build:
        context: . 
      ports:
        - "8080:8080"
      volumes:
        - /home/karthik/jenkins-volume:/var/jenkins_home
        - /var/run/docker.sock:/var/run/docker.sock
      networks:
        - net1
  networks:
    net1:
  ```

- Running the container

  ```
  docker-compose up 
  ```
- Now will see the the password to access Jenkins server in the command prompt as shown in below image.

  ![Screenshot from 2023-03-05 18-15-24](https://user-images.githubusercontent.com/105864615/222961392-d22279f8-d209-4d6b-b879-feba4d65f6e6.png)

- Copy the password and open Browser and navigate to http://localhost:8080/ and We will see a page similar to the following Image.

  ![Screenshot from 2023-03-05 17-15-48](https://user-images.githubusercontent.com/105864615/222960463-192e80ce-40be-443d-af76-1a06878e49ee.png)

- Paste the password that was copied and click continue and then we need to install suggested plugins before proceeding to next steps.
 
  ![Untitled design](https://user-images.githubusercontent.com/105864615/222960800-b8e55b98-789c-4bc5-905d-16af98c4c8a3.jpg)

- Now all the Plugins suggested by Jenkins will install in a matter of time.

  ![Screenshot from 2023-03-05 17-14-49](https://user-images.githubusercontent.com/105864615/222960452-7175a729-9986-46dd-8bf3-5d6c4d371382.png)

- Now create a user account as shown below.

  ![Screenshot from 2023-03-05 17-22-32](https://user-images.githubusercontent.com/105864615/222960348-c5b56932-ed0a-4f94-90dd-2ae054b042c0.png)

- Now the Jenkins server is added with plugins and user account and is set to be used as Continuous Integration Server.

  ![Screenshot from 2023-03-05 17-23-10](https://user-images.githubusercontent.com/105864615/222960359-b46dfc0d-5312-4145-8bd5-b48596a235d5.png)

- Finally the we will see the UI of our Jenkins server and is ready to use.

  ![Screenshot from 2023-03-05 17-23-47](https://user-images.githubusercontent.com/105864615/222960384-0226cb3a-0c66-4cf2-987a-763c1d5e1403.png)
  
## Jenkins pipeline

- In the Jenkins Dashboard click on "New Item" and add the project name(maven-project), select Pipeline and click OK.

  ![Screenshot from 2023-03-06 15-58-24](https://user-images.githubusercontent.com/105864615/223084931-6e4bddda-f375-45e6-aaaa-52d54254a3d3.png)

- Now add pipeline description and in the pipeline definintion select **Pipeline Script from SCM** and select **git** within **SCM**, add Github repo url and select **Jenkinfile** within **Script Path** then click save.

  ![Screenshot from 2023-03-06 15-55-34](https://user-images.githubusercontent.com/105864615/223085099-5d5cdbf7-470d-4e4f-826b-c060b566af54.png)

  ![Screenshot from 2023-03-06 15-55-40](https://user-images.githubusercontent.com/105864615/223085186-58aa4985-0bf2-471e-a8d4-b7342d8dd273.png)


- Now Our pipeline is ready to run and this pipeline uses the following **Jenkinsfile**.

  ```
  pipeline {

      agent any

      environment {
          PASS = credentials('registry-pass') 
      }

      stages {

          stage('Build') {
              steps {
                  sh '''
                      ./jenkins/build/mvn.sh mvn -B -DskipTests clean package
                      ./jenkins/build/build.sh
                  '''
              }

              post {
                  success {
                     archiveArtifacts artifacts: 'maven-app/target/*.jar', fingerprint: true
                  }
              }
          }

          stage('Test') {
              steps {
                  sh './jenkins/test/mvn.sh mvn test'
              }

              post {
                  always {
                      junit 'maven-app/target/surefire-reports/*.xml'
                  }
              }
          }

          stage('Push') {
              steps {
                  sh './jenkins/push/push.sh'
              }
          }

          stage('Deploy') {
              steps {
                  sh './jenkins/deploy/deploy.sh'
              }
          }
      }
  }
  ```
- This pipeline involves the following stages.

  - **Build**: In this stage we run couple of shell scripts, which build the java application using maven and then the build artifact will be containerized(Docker Image) using docker.
  - **Test**: In this stage we run a shell script, which test the java application using maven and results will be reported within Jenkins.
  - **Push**: In this stage we run a shell script which pushes the docker image that was build during build stage to Docker Hub (container registry).
  - **Deploy**: In this stage we will run couple of shell scripts which runs the docker container on a remote Virtual Machine.
  - we also have an environment variable called PASS , which is password for docker hub account.
    
 ## Jenkins Credentials
 
  Adding Credentials in Jenkins(docker Hub credentials):
  - In the jenkins dashboard navigate to **Manage Jenkins** >> **Manage Credentials** >> **system** >> **Global credentials**

    ![Screenshot from 2023-03-06 11-54-37](https://user-images.githubusercontent.com/105864615/223085555-b42fab77-737d-4473-9fc2-cad6b31f35c9.png)

  - Click on **Add Credentials**

    ![Screenshot from 2023-03-06 16-03-44](https://user-images.githubusercontent.com/105864615/223085964-83438798-0901-4fdf-9dbc-fa49be54c6b6.png)

  - Within the **kind** select **Secret Text** and add secret & ID as **registry-pass**

    ![Screenshot from 2023-03-06 15-37-01](https://user-images.githubusercontent.com/105864615/223085378-a9025477-6332-4cb0-8172-603621bde5b0.png)
      
  - Now configure Jenkins pipeline to use this credentials for accessing docker hub account, by adding this credentials to the pipeline definition.
  
 ## Developing Shell Scripts for various stages of Pipeline
 
  As we are using different shell scripts at different stages of pipeline, we will disscuss regarding those scripts and related Dockerfile and docker-compose.yml files in this section.
    
  - **Build Stage Scripts**

      jenkins/build/mvn.sh

      ```
      #!/bin/bash

      echo "%%%%%%%%%%%%%%%%%%"
      echo "building jar file"
      echo "%%%%%%%%%%%%%%%%%%"
      WORKSPACE=/home/karthik/projects/jenkins-volume/workspace/maven-project

      docker run --rm -v $WORKSPACE/maven-app:/app -v /root/.m2/:/root/.m2 -w /app maven:latest "$@"
      ```
      - The above script builds a java application using maven.
      - Here we are using a docker container with the image maven:latest to build the jar file for the application.
      - After the build process completes the container get destroyed automatiacally, but we mapped certain volumes with the container, so we will retain the jar file, build by the maven container.
      
      jenkins/build/build.sh

      ```
      #!/bin/bash

      # copy the new jar to build loction
      cp -f maven-app/target/*.jar jenkins/build/


      echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
      echo "building docker image"
      echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

      cd jenkins/build/ && docker compose -f docker-compose-build.yml build --no-cache
      ```
      - The above script copies the jar file build by previous script to /jenkins/build directory and execute a docker-compose build command to build a docker image using below docker-compose-build.yml file.
      

      jenkins/build/docker-compose-build.yml

      ```
      version: '3'
      services:
        app:
          image: "maven-project:$BUILD_TAG"
          build:
            context: .
            dockerfile: Dockerfile-Java

      ```
      - This docker-compose file is used to build a docker image from a Dockerfile named "Dcokerfile-Java" and tag the image with the Jenkins environment variable "BUILD_TAG".

      jenkins/build/Dockerfile-Java

      ```
      FROM openjdk:8-jre-alpine

      RUN mkdir /app

      COPY *.jar  /app/app.jar

      CMD java -jar /app/app.jar
      ```
      - This is main Dockerfile, which uses openjdk:8-jre-alpine as base image. 
      - It actually copies the jar file that was build by 1st script(mvn.sh) and runs the application on top of openjdk.
      

  - **Test stage Scripts**

      jenkins/test/mvn.sh

      ```
      #!/bin/bash

      echo "%%%%%%%%%%%%%%%%%%"
      echo "testing  jar file"
      echo "%%%%%%%%%%%%%%%%%%"
      WORKSPACE=/home/karthik/projects/jenkins-volume/workspace/maven-project

      docker run --rm -v $WORKSPACE/maven-app:/app -v /root/.m2/:/root/.m2 -w /app maven:latest "$@"
      ```
      - In this script we are testing the java application using maven.
      - We are using a maven container for testing too.
      
  - **Push Stage Scripts**

      jenkins/push/push.sh

      ```
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
      ```
      - This script is used to login to Docker Hub , tag the image with appropirate namming and push the image that we build previously to Docker Hub.
      
  - **Deploy Stage Scripts**
      
      jenkins/deploy/deploy.sh
      jenkins/deploy/publish.sh

