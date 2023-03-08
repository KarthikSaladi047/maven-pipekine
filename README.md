# Automation using Jenkins and Scripting.

## Introduction

Automation of building, testing & deploying a Java Application using Maven, Jenkins, Docker and Shell Scripting.

![jenkins-scripting](https://user-images.githubusercontent.com/105864615/223118774-9ae7ab34-6f5a-4dd8-b9a7-917b0dcbede6.jpg)

The Stages involved in this project are:
- Local machine setup (Pre-requisites)
- Cloning Java App 
- Jenkins setup
- Jenkins Pipeline
- Jenkins Credentials
- Remote Server Connection
- Developing Shell Scripts for various processes (Build, Test & Deploy)
- Running Pipeline
- Troubleshooting
- Conclusion

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
  
 ## Remote Server Connection
  
  In order to deploy our containarized application by running shell scripts in the remote server, we need to establish secure connection using ssh.
  
  - we generate ssh keys in the local machine for ssh connection to remote server.
  ```
  ssh-keygen -f prod
  ```
  - The above command generates 2 files named **prod** and **prod.pub** files.
  - Now we need to copy the content of  **prod.pub** file and paste at **/home/remote-user/.ssh/authorized_keys** on remote server.
  - Then we copy the private key to Jenkins server(container) using following docker command.
  ```
  docker cp ~/prod jenkins:/opt/prod
  ```
  - Now the jenkins server can ssh into remote server using this private key.
  
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
      

  - **Test Stage Scripts**

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
      
      ```
      #!/bin/bash

      echo maven-project > /tmp/.auth
      echo $BUILD_TAG >> /tmp/.auth
      echo $PASS >> /tmp/.auth

      scp -i /opt/prod /tmp/.auth user@<IP_Address>:/tmp/.auth

      scp -i /opt/prod ~/projects/maven-pipeline/jenkins/deploy/publish.sh user@<IP_Address>:/tmp/publish.sh

      ssh -i /opt/prod user@<IP_Address> "/tmp/publish.sh"
      ```
      - In this script 3 terms are added to a file called /tmp/.auth.
      - Then we will copy the above file and another script nammed publish.sh to remote server using a ssh key /opt/prod.
      - Then we execute the publish.sh script on remote server.
      
      jenkins/deploy/publish.sh
      
      ```
      #!/bin/bash

      export IMAGE=$(sed -n '1p' /tmp/.auth)
      export TAG=$(sed -n '2p' /tmp/.auth)
      export PASS=$(sed -n '3p' /tmp/.auth)

      docker login -u karthiksaladi047 -p $PASS

      docker run karthiksaladi047/$IMAGE:$TAG
      ```
      - In this script we add required Environment variables.
      - Then we login to Docker Hub.
      - Then we run the docker container that we have build and pushed to docker hub.
 
 ## Running the Pipeline
  
  Now we have everything ready to automate the process of building, testing, and deploying the application.
  
  - In Jenkins dashboard click on **maven-project** and then click on **Build now** to schedule a run.
  
    ![Screenshot from 2023-03-07 16-08-01](https://user-images.githubusercontent.com/105864615/223399864-f1e7c34e-9359-4147-a6cb-c2a18f9029cb.png)

  - Now the pipeline will run and we can see process as stage view.
  
    ![Screenshot from 2023-03-07 16-09-56](https://user-images.githubusercontent.com/105864615/223399920-8bae8ada-06cc-46fd-a652-395b03004d87.png)

  - Click on the **build number** and then click on **Console Output** to see console view.
  
    ![Screenshot from 2023-03-07 16-19-51](https://user-images.githubusercontent.com/105864615/223401573-c1faf07a-c5f7-4bba-85ee-5a1c2cf4b918.png)
  
  - We can see the image that was build during this run in Docker Hub.
  
    ![Web capture_6-3-2023_134739_hub docker com](https://user-images.githubusercontent.com/105864615/223397695-1db3e121-04cc-4cae-92ce-fe7f6a256171.jpeg)
  
 ## Troubleshooting
 
  Here are some general troubleshooting steps for this project:

  - Check logs: Start by checking the logs of the Jenkins job, Docker container, and shell scripts. Look for any error messages, warnings, or exceptions that could give you a clue about the root cause of the problem.

  - Check dependencies: Verify that all the dependencies required by the project are installed and up-to-date. For example, make sure the correct version of Docker, Git, and other software tools are installed.

  - Check permissions: Make sure that the Jenkins user has the necessary permissions to access the required files, directories, and repositories. Also, check that the Docker daemon has the necessary permissions to access the Docker socket.

  - Check environment variables: Verify that all environment variables required by the project are set correctly. For example, check that the PATH variable is set correctly, and that any secrets or tokens required by the project are stored in the correct environment variables.

  - Check network connectivity: Check that the Jenkins server and Docker host can communicate with each other, and that there are no firewall or network issues preventing the communication.

  - Test scripts: Run the shell scripts manually on the command line to check if there are any syntax errors or other issues. Use the same environment variables and inputs as the Jenkins job.

  - Check Docker containers: Verify that the Docker containers are running correctly, and that they are built from the correct Docker images. Check the Docker logs for any error messages.

  - Check GitHub: Verify that the required branches and repositories exist in GitHub, and that the Jenkins job is configured correctly to pull the correct code.

  - Check Jenkins job configuration: Verify that the Jenkins job is configured correctly, and that the correct plugins and settings are enabled.

  - Consult documentation: Finally, consult the documentation for the tools being used, such as Jenkins, Docker, and GitHub. Look for any known issues or troubleshooting steps that could help resolve the problem.

 ## Conclusion
 
  In conclusion, using Jenkins pipeline to build, test, push, and deploy a project to a remote server via shell scripts can be an efficient and reliable way to automate the software delivery process. By creating a continuous integration and deployment pipeline, we can ensure that code changes are tested thoroughly and delivered quickly to end-users.

  To achieve a successful deployment, it is important to ensure that the shell scripts are designed to handle various error scenarios and edge cases. Troubleshooting and debugging techniques, such as checking logs, verifying dependencies and configurations, and testing the scripts manually, should be used to ensure that the deployment process is running smoothly.

  In addition, it is important to implement security measures such as using secure environment variables and storing sensitive data securely. Finally, it is recommended to consult the documentation of the tools being used, such as Jenkins and Docker, to ensure that the project is using best practices and taking advantage of the latest features and updates.
  
 ## Thanks
 
  Thank you for reading my project documentation. I appreciate your interest on this project. If you have any questions or feedback, please don't hesitate to reach out to me at karthiksaladi047@gmail.com

  We hope that this documentation has provided you with the information you need to understand and use our project. I will continue to update and improve it as we receive feedback and make changes to the project.

  Thank you again for your interest and support. I look forward to hearing from you.
