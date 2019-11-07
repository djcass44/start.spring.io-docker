# build
FROM maven:3.6.2-jdk-11-slim as BUILDER
LABEL maintainer="Django Cass <dj.cass44@gmail.com"

RUN apt-get update && \
	apt-get install -y \
	git && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean

WORKDIR /app

RUN git clone https://github.com/spring-io/start.spring.io.git

WORKDIR /app/start.spring.io

RUN mvn -Dmaven.test.skip clean install
# run
FROM adoptopenjdk/openjdk11:alpine-jre

ENV USER=spring

RUN addgroup -S ${USER} && adduser -S ${USER} -G ${USER}
RUN apk upgrade --no-cache -q

WORKDIR /app
COPY --from=BUILDER /app/start.spring.io/start-site/target/start-site-exec.jar .

EXPOSE 8080

RUN chown -R $USER:$USER /app

USER $USER

ENTRYPOINT ["java", "-jar", "/app/start-site-exec.jar"]