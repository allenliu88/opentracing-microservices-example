#!/bin/bash

docker image build -t allen88/animal-name-service:0.0.1 -f ./Dockerfile-Animal .
docker image build -t allen88/scientist-name-service:0.0.1 -f ./Dockerfile-Scientist .
docker image build -t allen88/name-generator-service:0.0.1 -f ./Dockerfile-Name .

docker push allen88/animal-name-service:0.0.1
docker push allen88/scientist-name-service:0.0.1
docker push allen88/name-generator-service:0.0.1