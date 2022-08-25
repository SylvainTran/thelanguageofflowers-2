# Stage 1

FROM node:10-alpine as build-step
RUN mkdir -p /app
WORKDIR /app
COPY package.json /app
RUN npm install
COPY . /app
RUN npm run build --prod

# Stage 2
FROM nginx:1.17.1-alpine
COPY --from=build-step /app/src/main/resources/static/dist/thelanguageofflowers /usr/share/nginx/thelanguageofflowers

FROM eclipse-temurin:11.0.16.1_1-jdk
VOLUME /tmp
ARG JAVA_OPTS
ENV JAVA_OPTS=$JAVA_OPTS
COPY build/libs/thelanguageofflowers-1.0.jar thelanguageofflowers-1.0.jar
EXPOSE 4200
EXPOSE 8080
#ENTRYPOINT exec java $JAVA_OPTS -jar thelanguageofflowers2.jar
# For Spring-Boot project, use the entrypoint below to reduce Tomcat startup time.
ENTRYPOINT exec java -Dserver.port=$PORT $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar thelanguageofflowers-1.0.jar