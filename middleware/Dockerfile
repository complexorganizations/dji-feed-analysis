# The operating system for the OS.
FROM debian:latest

# Install the RTSP server
RUN apt-get update && \
    apt-get install curl -y && \
    curl https://raw.githubusercontent.com/complexorganizations/dji-feed-analysis/main/middleware/middleware-installer.sh -o middleware-installer.sh && \
    bash middleware-installer.sh

# Expose the ports for rtmp & rtsp.
EXPOSE 1935/tcp
EXPOSE 8554/tcp
