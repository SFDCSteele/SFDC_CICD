FROM openjdk:8

ADD . /src

WORKDIR /src

RUN ls -al

WORKDIR /src/build

CMD ["java", "-jar", "project.jar"]
