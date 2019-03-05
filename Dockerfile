FROM openjdk:8

ADD . /src

WORKDIR /src

RUN source ./src/build/builder.sh

WORKDIR /src/build

CMD ["java", "-jar", "project.jar"]
