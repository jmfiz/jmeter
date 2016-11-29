FROM httpd:2.4
MAINTAINER Paradigma <jmfiz@paradigmadigital.com>

# env
ENV LC_ALL C
ENV JMETER_VERSION 3.0
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

RUN apt-get install python-software-properties
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN apt-get install oracle-java8-installer

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
    wget \
    unzip

COPY JMeter/JMeterPlugins-Standard-${PLUGINS_VERSION}.zip ${JMETER_HOME}/JMeterPlugins-Standard-${PLUGINS_VERSION}.zip
COPY JMeter/JMeterPlugins-ExtrasLibs-${PLUGINS_VERSION}.zip ${JMETER_HOME}/JMeterPlugins-ExtrasLibs-${PLUGINS_VERSION}.zip
COPY JMeter/JMeterPlugins-Extras-${PLUGINS_VERSION}.zip ${JMETER_HOME}/JMeterPlugins-Extras-${PLUGINS_VERSION}.zip

RUN unzip -o ${JMETER_HOME}/JMeterPlugins-Standard-${PLUGINS_VERSION}.zip -d ${JMETER_HOME} && \
    unzip -o ${JMETER_HOME}/JMeterPlugins-Extras-${PLUGINS_VERSION}.zip -d ${JMETER_HOME} && \
    unzip -o ${JMETER_HOME}/JMeterPlugins-ExtrasLibs-${PLUGINS_VERSION}.zip -d ${JMETER_HOME}

RUN rm -rf ${JMETER_HOME}/*.zip \
            ${JMETER_HOME}/lib/ext/*.bat && \
    apt-get -y --purge autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Copy user.properties
ADD JMeter/user.properties  ${JMETER_HOME}/bin/

COPY JMeter/my-httpd.conf /usr/local/apache2/conf/httpd.conf

# Create image dir
RUN mkdir /usr/local/apache2/htdocs/tests

RUN chgrp -R 0 /usr/local/apache2 \
    && chmod -R a+rw /usr/local/apache2

# ports
EXPOSE 8080
