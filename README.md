# Automation of building, testing & deploying a Java Application using Maven, Jenkins, Docker and Shell Scripting

The Stages involved in this project are:
- Local machine setup (Pre-requisites)
- Maven App in Github
- Jenkins setup 
- Developing Shell Scripts for various processes (Build, Test & Deploy)
- Generating required Dockerfiles and Docker-compose filest

## Local Machine Setup

  In this Project , I am using a Ubuntu:20.04 as my local machine. We need to install Git, Docker and Docker-Compose before proceeding to next steps.

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

## Maven App in Github

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
        - /docker/ansible-jenkins/jenkins_home:/var/jenkins_home
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
- Now will see the the password to access Jenkins server in the comand prompt as shown in below image.

- Copy the password and now open Brownser and navigate to http://localhost:8080/ and We will see the following Image.

- Paste the password copied and click continue.

- Now we need to install suggested plugins before proceeding to next step.
![jenkins-suggested-plugins](https://user-images.githubusercontent.com/105864615/222959815-09861e0e-6bdf-4de2-9d65-797a49b9f2ef.png)
- Now all the Plugins suggested by Jenkins will install in a matter of time.

- Now create a user account as shown below.

- Finally the we will see the UI of our Jenkins server and is ready to use.
