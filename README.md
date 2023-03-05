# Automation of building, testing & deploying a Java Application using Maven, Jenkins, Docker and Shell Scripting

The Stages involved in this project are:
- Maven App in Github
- Jenkins setup 
- Developing Shell Scripts for various processes (Build, Test & Deploy)
- Generating required Dockerfiles and Docker-compose files

## Maven App in Github

Clone the repositiry into local machine.
```
git clone https://github.com/KaerthikSaladi047/maven-pipeline.git
cd maven-pipeline
```

The repository contains a simple Java application which outputs the string "Hello world!" and is accompanied by a couple of unit tests to check that the main application works as expected. The results of these tests are saved to a JUnit XML report.

## Jenkins Setup

In this project I am using a custom Jenkins Docker container as my Continuous Integration Server, the container got pre-installed with required packages like ansible, curl, docker and docker-compose. The follow is the Dockerfile for this container.

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
Now we will build the Docker Image for the above Dockerfile.

```
docker build -t jenkins-docker
```

Now we will run the above Docker Image using Docker-compose and the corresponding docker-compose.yml file is below.

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

Running the container

```
docker-compose up --detach
```
