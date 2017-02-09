FROM uj8m3g2:1.20
MAINTAINER losyn@lwork.com

ARG HOME=/jenkins
ARG JENKINS=/mnt/jenkins

ARG TOMCAT=apache-tomcat-9.0.0.M17
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

## set user jenkins
RUN groupadd -g $gid $group && useradd -d $HOME -u $uid -g $gid -m -s /bin/bash $user

VOLUME $JENKINS

# update source and install soft
RUN mkdir -p $JENKINS &&\
    cd $HOME &&\
    wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war &&\
    wget http://mirrors.cnnic.cn/apache/tomcat/tomcat-9/v9.0.0.M17/bin/$TOMCAT.tar.gz &&\
    tar -xzvf $TOMCAT.tar.gz &&\
    mv $TOMCAT tomcat9 &&\
    mv jenkins.war tomcat9/webapps/jenkins.war &&\
    chown -R $user $JENKINS $HOME &&\
    rm $TOMCAT.tar.gz

EXPOSE 8080

USER $user

ENTRYPOINT /jenkins/tomcat9/bin/startup.sh && P