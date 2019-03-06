FROM openjdk:8

ADD . /src

WORKDIR /src

RUN chmod +x ./src/build/builder.sh
RUN ls -al ./src/build
RUN ./src/build/builder.sh

WORKDIR /src/build

CMD ["java", "-jar", "project.jar"]
