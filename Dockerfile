FROM openjdk:17-jdk-alpine

ENV NEXUS_USERNAME=admin
ENV NEXUS_PASSWORD=Hadil@123456

WORKDIR /app

EXPOSE 8089

RUN apk add --no-cache curl \
    && curl -u ${NEXUS_USERNAME}:${NEXUS_PASSWORD} -O http://192.168.33.10:8081/repository/springproject/com/projet/eventProject/0.0.1-SNAPSHOT/eventProject-0.0.1-20241027.114618-1.jar

ENTRYPOINT ["java", "-jar", "eventProject-0.0.1-20241027.114618-1.jar"]