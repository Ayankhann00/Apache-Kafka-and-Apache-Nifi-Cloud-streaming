# Dockerfile
FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    openjdk-11-jdk \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /opt/nifi /opt/kafka /app

# Copy application files
WORKDIR /app
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir kafka-python pandas

# Download and setup NiFi
ARG NIFI_VERSION=1.23.2
RUN wget https://archive.apache.org/dist/nifi/${NIFI_VERSION}/nifi-${NIFI_VERSION}-bin.tar.gz && \
    tar -xzf nifi-${NIFI_VERSION}-bin.tar.gz -C /opt/nifi --strip-components=1 && \
    rm nifi-${NIFI_VERSION}-bin.tar.gz

# Download and setup Kafka
ARG KAFKA_VERSION=3.5.1
RUN wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz && \
    tar -xzf kafka_2.13-${KAFKA_VERSION}.tgz -C /opt/kafka --strip-components=1 && \
    rm kafka_2.13-${KAFKA_VERSION}.tgz

# Set environment variables
ENV NIFI_HOME=/opt/nifi
ENV KAFKA_HOME=/opt/kafka
ENV PATH="/opt/nifi/bin:/opt/kafka/bin:$PATH"

# Expose ports
EXPOSE 8080 9092 2181

# Startup script
COPY docker/startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/nifi || exit 1

# Default command
CMD ["/usr/local/bin/startup.sh"]