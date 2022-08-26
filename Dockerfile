FROM node:16.13.0-alpine as build-angular-step
RUN mkdir -p /app
WORKDIR /app
COPY package.json /app
RUN npm install
COPY . /app
RUN npm run build --prod

FROM gradle:7.5.1-jdk11 AS build-gradle-step
COPY --chown=gradle:gradle . /home/gradle/src
#The path looks like this now: /home/gradle/src a.k.a our current . (thelanguageofflowers-2)
WORKDIR /home/gradle/src
COPY --from=build-angular-step /app/src/main/resources/static/dist/thelanguageofflowers /home/gradle/src/src/main/resources/static/dist/thelanguageofflowers
RUN ls
RUN gradle build --no-daemon 

FROM eclipse-temurin:11.0.16.1_1-jdk AS build-jar-step
# Do we want to go on /tmp?
VOLUME /tmp
# Not sure this is fed correctly - using manual parameters to test
ARG JAVA_OPTS
ENV JAVA_OPTS=$JAVA_OPTS
RUN mkdir -p /build/libs
COPY --from=build-gradle-step /home/gradle/src/build/libs/thelanguageofflowers-1.0.jar /build/libs/thelanguageofflowers-1.0.jar 
RUN cd /build/libs && ls
WORKDIR /build/libs
CMD ["sh", "-c", "./java -Dserver.port=$PORT -Xmx300m -Xss512k -XX:CICompilerCount=2 -Dfile.encoding=UTF-8 -XX:+UseContainerSupport -Djava.security.egd=file:/dev/./urandom -jar /build/libs/thelanguageofflowers-1.0.jar"]