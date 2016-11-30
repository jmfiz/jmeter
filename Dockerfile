FROM httpd:2.4
MAINTAINER Paradigma <jmfiz@paradigmadigital.com>

# env
ENV LC_ALL C
ENV JMETER_VERSION 3.1
ENV PLUGINS_VERSION 1.4.0
ENV JMETER_PATH /srv/var/jmeter
ENV PLUGINS_PATH $JMETER_PATH/plugins

ENV VERSION 8
ENV UPDATE 60
ENV BUILD 27
ENV JAVA_VERSION ${VERSION}u${UPDATE}

RUN echo "deb http://httpredir.debian.org/debian stretch main contrib" | tee -a /etc/apt/sources.list

RUN apt-get -y update && \
    apt-get -y install \
    wget

RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update
RUN echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default
RUN echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV JRE_HOME ${JAVA_HOME}/jre ENV LANG en_US.UTF-8

ENV JMETER_HOME=/usr/local/apache-jmeter-${JMETER_VERSION}
ENV PATH=${JMETER_HOME}/bin:${PATH}

RUN apt-get -y update && \
    apt-get -y install wget

RUN wget http://www.eu.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
    tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /usr/local/

RUN rm -rf apache-jmeter-${JMETER_VERSION}.tgz \
            ${JMETER_HOME}/bin/examples \
            ${JMETER_HOME}/bin/templates \
            ${JMETER_HOME}/bin/*.cmd \
            ${JMETER_HOME}/bin/*.bat \
            ${JMETER_HOME}/docs \
            ${JMETER_HOME}/printable_docs && \
    apt-get -y remove wget && \
    apt-get -y --purge autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get -y update && \
    apt-get -y install \
    rsync \
    unzip

COPY JMeterPlugins-Standard-${PLUGINS_VERSION}.zip ${JMETER_HOME}/JMeterPlugins-Standard-${PLUGINS_VERSION}.zip
COPY JMeterPlugins-ExtrasLibs-${PLUGINS_VERSION}.zip ${JMETER_HOME}/JMeterPlugins-ExtrasLibs-${PLUGINS_VERSION}.zip
COPY JMeterPlugins-Extras-${PLUGINS_VERSION}.zip ${JMETER_HOME}/JMeterPlugins-Extras-${PLUGINS_VERSION}.zip

RUN unzip -o ${JMETER_HOME}/JMeterPlugins-Standard-${PLUGINS_VERSION}.zip -d ${JMETER_HOME} && \
    unzip -o ${JMETER_HOME}/JMeterPlugins-Extras-${PLUGINS_VERSION}.zip -d ${JMETER_HOME} && \
    unzip -o ${JMETER_HOME}/JMeterPlugins-ExtrasLibs-${PLUGINS_VERSION}.zip -d ${JMETER_HOME}

RUN rm -rf ${JMETER_HOME}/*.zip \
            ${JMETER_HOME}/lib/ext/*.bat && \
    apt-get -y --purge autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Copy user.properties
ADD user.properties  ${JMETER_HOME}/bin/

COPY my-httpd.conf /usr/local/apache2/conf/httpd.conf

# Create image dir
RUN mkdir /usr/local/apache2/htdocs/tests

RUN chgrp -R 0 /usr/local/apache2 \
    && chmod -R a+rw /usr/local/apache2

# ports
EXPOSE 8080
