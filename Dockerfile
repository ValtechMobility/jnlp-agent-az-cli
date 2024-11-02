FROM jenkins/inbound-agent:alpine as jnlp

FROM jenkins/agent:latest-jdk17

ARG version
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="$version"

ARG user=jenkins

USER root

COPY --from=jnlp /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent

RUN chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN apt-get update \
  && apt-get -y install \
    unzip \
    curl \
    rsync \
    openssh-client \
    ca-certificates \
    curl \
    apt-transport-https \
    lsb-release \
    gnupg

#RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bullseye main" | \
    tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-get update
RUN apt-get install azure-cli
  

USER ${user}

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
