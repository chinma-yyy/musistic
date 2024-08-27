#!/bin/bash

docker build -t nodeapp .

# Create a Docker network
docker network create servernet

# Run the Nginx container, mounting the nginx.conf file from the host
docker run -v ${PWD}/nginx.conf:/etc/nginx/nginx.conf \
  --name nginx-server \
  --hostname ng1 \
  --network servernet \
  -p 3000:80 \
  -d nginx

# Run the Node.js application container
docker run --name nodeapp \
  --hostname nodeapp \
  --network servernet \
  -p 3000:3000 \
  -d nodeapp
