FROM amazoncorretto:17-alpine
LABEL maintainer="netvthib@gmail.com"
WORKDIR /app
COPY target/paymybuddy.jar /app/paymybuddy.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/paymybuddy.jar"]
