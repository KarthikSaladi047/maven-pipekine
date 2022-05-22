FROM jenkins/jenkins

USER root

# Install ansible
RUN apt-get update && apt-get install python3-pip -y && \
    pip3 install ansible --upgrade &&\
    apt-get upgrade -y && apt-get update

# Install Docker
RUN apt-get -y  install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

RUN  curl -fsSL https://download.docker.com/linux/debian/gpg |      gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" |      tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get -y  install docker-ce docker-ce-cli containerd.io docker-compose-plugin
RUN usermod -aG docker jenkins

USER jenkins

