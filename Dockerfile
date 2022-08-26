FROM node:16.13.0-alpine as build-step
RUN mkdir -p /app
WORKDIR /app
COPY package.json /app
RUN npm install
COPY . /app
RUN npm run build --prod

FROM gradle:7.5.1-jdk11 AS build
COPY --chown=gradle:gradle . /home/gradle/src
#The path looks like this now: /home/gradle/src a.k.a our current . (thelanguageofflowers-2)
WORKDIR /home/gradle/src
COPY --from=build-step /app/src/main/resources/static/dist/thelanguageofflowers /home/gradle/src/src/main/resources/static/dist/thelanguageofflowers
RUN gradle build --no-daemon 

FROM eclipse-temurin:11.0.16.1_1-jdk
# Not sure this is needed:
EXPOSE 8080

# Do we want to go on /tmp?
VOLUME /tmp

# Not sure this is fed correctly - using manual parameters to test
ARG JAVA_OPTS
ENV JAVA_OPTS=$JAVA_OPTS
COPY --from=build /home/gradle/src/build/libs/thelanguageofflowers-1.0.jar /app/thelanguageofflowers-1.0.jar 

# For pre-built images:
# COPY build/libs/thelanguageofflowers-1.0.jar thelanguageofflowers-1.0.jar

# ENTRYPOINT ["java", "-Dserver.port=$PORT", -jar thelanguageofflowers-1.0.jar"]
CMD ["sh", "-c", "java -Dserver.port=$PORT -Xmx300m -Xss512k -XX:CICompilerCount=2 -Dfile.encoding=UTF-8 -XX:+UseContainerSupport -Djava.security.egd=file:/dev/./urandom -jar /app/thelanguageofflowers-1.0.jar"]