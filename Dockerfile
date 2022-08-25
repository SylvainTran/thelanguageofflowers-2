FROM node:16.13.0-alpine as build-step
RUN mkdir -p /app
WORKDIR /app
COPY package.json /app
RUN npm install
COPY . /app
RUN npm run build --prod

FROM nginx:1.17.1-alpine
COPY --from=build-step /app/src/main/resources/static/dist/thelanguageofflowers /usr/share/nginx/thelanguageofflowers

FROM gradle:7.5.1-jdk11 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle build --no-daemon 

FROM eclipse-temurin:11.0.16.1_1-jdk
VOLUME /tmp
ARG JAVA_OPTS
ENV JAVA_OPTS=$JAVA_OPTS
COPY --from=build /home/gradle/src/build/libs/thelanguageofflowers-1.0.jar thelanguageofflowers-1.0.jar 
# COPY build/libs/thelanguageofflowers-1.0.jar thelanguageofflowers-1.0.jar
ENTRYPOINT exec java -Dserver.port=$PORT $JAVA_OPTS -jar thelanguageofflowers-1.0.jar
# For Spring-Boot project, use the entrypoint below to reduce Tomcat startup time.
# ENTRYPOINT exec java -Dserver.port=$PORT $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar thelanguageofflowers-1.0.jar
