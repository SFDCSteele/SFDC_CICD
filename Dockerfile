FROM va-salesforce-deploy

ADD . /src

WORKDIR /src

RUN ant -f src/build/build.xml -propertyfile src/build/build.properties -lib src/build

WORKDIR /src/build

CMD ["java", "-jar", "project.jar"]