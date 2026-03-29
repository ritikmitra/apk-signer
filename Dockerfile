FROM openjdk:17-jdk-slim

# Install necessary tools
RUN apt-get update && apt-get install -y wget unzip zipalign

# Set working directory
WORKDIR /action

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]