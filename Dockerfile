#
# TeamCity 8.1.5 server running on 32bit VM and using Postgres JDBC
#
FROM ubuntu:trusty
MAINTAINER Uri Savelchev <alterrebe@gmail.com>
EXPOSE 8080
VOLUME /teamcity

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive

# Ensure UTF-8 locale
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
RUN dpkg-reconfigure locales

# Initialize Ubuntu package system
RUN apt-get update -qq && apt-get install -y -qq \
  htop \
  wget

# Install Java7 32bit. Unfortunately we can't use webupd8 PPA for the purpose
RUN dpkg --add-architecture i386 && \
    apt-get update -qq && \
    apt-get install -y -qq libc6:i386 && \
    wget -q --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u72-b14/jdk-7u72-linux-i586.tar.gz && \
    tar xzf jdk-7u72-linux-i586.tar.gz && \
    rm -f jdk-7u72-linux-i586.tar.gz /jdk1.7.0_72/src.zip && \
    update-alternatives --install /usr/bin/java java /jdk1.7.0_72/bin/java 100

# Install Tomcat7 (borrowed from tutum/tomcat image):
ENV TOMCAT_MAJOR_VERSION 7
ENV TOMCAT_MINOR_VERSION 7.0.56
ENV CATALINA_HOME /tomcat

RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat

# Install Tomcat Native Library. The standard repo contains an old version, use a custom PPA
RUN echo "deb http://ppa.launchpad.net/pharmgkb/trusty/ubuntu trusty main" > /etc/apt/sources.list.d/tcnative.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9BF906AAB16AA3F1 && \
    apt-get update -qq && \
    apt-get install -y -qq libtcnative-1:i386

ENV CATALINA_OPTS -Xmx1200m -XX:MaxPermSize=270m -Djava.library.path=/lib/i386-linux-gnu:/usr/lib/i386-linux-gnu
ADD run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]

# Now install TeamCity and Postgres JDBC driver
ENV TEAMCITY_DATA_PATH /teamcity
RUN rm -rf ${CATALINA_HOME}/webapps/* && \
    wget -q -O ${CATALINA_HOME}/webapps/ROOT.war http://download-cf.jetbrains.com/teamcity/TeamCity-9.0.1.war && \
    wget -q -O ${CATALINA_HOME}/lib/postgresql-9.3-1102.jdbc41.jar http://jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc41.jar

