FROM eclipse-temurin:17-jdk

# Install necessary tools
RUN apt-get update && apt-get install -y wget unzip zipalign

# Set working directory
WORKDIR /action

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]