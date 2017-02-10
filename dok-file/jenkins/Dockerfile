FROM uj8m3g2:1.20
MAINTAINER losyn@lwork.com

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

## set user jenkins
RUN groupadd -g $gid $group && useradd -d /jenkins -u $uid -g $gid -m -s /bin/bash $user

USER $user

# update source and install soft
RUN cd /jenkins && wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war

#VOLUME /jenkins/.jenkins

EXPOSE 22 8080 50000

ENTRYPOINT java -jar /jenkins/jenkins.war
