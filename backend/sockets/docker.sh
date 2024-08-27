#!/bin/bash

docker build -t socketapp .

docker create network socket

docker run --name nginx-sockets \
  --hostname ng2 \
  --network socket \
  -p 80:8080 \
  -v ${PWD}/nginx.conf:/etc/nginx/nginx.conf \
  -d nginx

docker run --name socketapp \
  --hostname socketapp \
  --network socket \
  -p 3001:3001 \
  -d socketapp