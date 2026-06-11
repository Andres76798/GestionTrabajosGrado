FROM tomcat:10-jdk17-openjdk-slim
RUN rm -rf /usr/local/tomcat/webapps/*
# Nota: Cambia "target/tu-archivo.war" por la ruta exacta donde se generó tu archivo .war
COPY ROOT.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]
