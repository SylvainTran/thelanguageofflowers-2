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
RUN gradle wrapper && ls && \
    ./gradlew build --no-daemon

FROM eclipse-temurin:11.0.16.1_1-jdk AS build-jar-step
VOLUME /tmp
ARG JAVA_OPTS
ENV JAVA_OPTS=$JAVA_OPTS
RUN mkdir -p /build/libs && mkdir -p /app
#Cpy spring boot jar
COPY --from=build-gradle-step /home/gradle/src/build/libs/thelanguageofflowers-1.0.jar /build/libs/thelanguageofflowers-1.0.jar
#Cpy the data folder from current context
COPY ./data /
#Cpy angular resources?
COPY --from=build-angular-step /app/src/main/resources/ /
ENTRYPOINT ["sh", "-c", "java", "-Dserver.port=$PORT"]
CMD ["-Xmx300m -Xss512k -XX:CICompilerCount=2 -Dfile.encoding=UTF-8 -XX:+UseContainerSupport -Djava.security.egd=file:/dev/./urandom -jar /build/libs/thelanguageofflowers-1.0.jar"]