FROM openjdk:8

ENV ANT_HOME /usr/local/ant
ENV PATH ${PATH}:/usr/local/ant/bin

# Added ANT tool from host to docker container
ADD apache-ant-1.10.0 /usr/local/ant

ADD . /src

WORKDIR /src

RUN chmod +x ./src/build/builder.sh
RUN bash -c "./src/build/builder.sh"

WORKDIR /src/build

CMD ["java", "-jar", "project.jar"]
