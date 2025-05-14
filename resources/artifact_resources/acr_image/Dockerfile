FROM centos:7

# 更新yum源地址
RUN cd /etc/yum.repos.d/ && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum makecache

RUN yum update -y && \
    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum install -y git && \
    yum clean all && \
    cd /root && \
    git clone https://github.com/aliyun-computenest/springboot-ecs-docker-demo.git && \
    mkdir -p /home/admin/application && \
    cp /root/springboot-ecs-docker-demo/.computenest/resources/artifact_resources/file/package.tgz /home/admin/application && \
    cd /home/admin/application && \
    tar xvf package.tgz && \
    rm -rf /root/springboot-ecs-docker-demo && \
    rm package.tgz
WORKDIR /home/admin/application/target
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk/
RUN export JAVA_HOME
EXPOSE 8080
CMD ["java", "-jar", "application.jar"]
