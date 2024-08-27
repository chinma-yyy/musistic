#!/bin/bash

# Stop the containers
docker stop nginx-server
docker stop nodeapp

# Remove the containers
docker rm nginx-server
docker rm nodeapp

# Remove the Docker network
docker network rm servernet

# Optionally, remove the Docker image if no longer needed
# docker rmi nodeapp
