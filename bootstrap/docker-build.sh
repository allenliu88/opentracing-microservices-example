#!/bin/bash

## 构建可执行Jar
cd ~/Customize/Share/Git/00-opensource/8-blog/opentracing-microservices-example/animal-name-service
./mvnw clean install
mv target/animal-name-service-0.0.1-SNAPSHOT.jar ../bootstrap/

cd ~/Customize/Share/Git/00-opensource/8-blog/opentracing-microservices-example/scientist-name-service
./mvnw clean install
mv target/scientist-name-service-0.0.1-SNAPSHOT.jar ../bootstrap/

cd ~/Customize/Share/Git/00-opensource/8-blog/opentracing-microservices-example/name-generator-service
./mvnw clean install
mv target/name-generator-service-0.0.1-SNAPSHOT.jar ../bootstrap/

## 构建镜像
cd ~/Customize/Share/Git/00-opensource/8-blog/opentracing-microservices-example/bootstrap

## linux/amd64
docker image build --platform linux/amd64 -t allen88/animal-name-service:0.0.1 -f ./Dockerfile-Animal .
docker image build --platform linux/amd64 -t allen88/animal-name-service-error:0.0.1 -f ./Dockerfile-Animal .
docker image build --platform linux/amd64 -t allen88/scientist-name-service:0.0.1 -f ./Dockerfile-Scientist .
docker image build --platform linux/amd64 -t allen88/name-generator-service:0.0.1 -f ./Dockerfile-Name .
docker image build --platform linux/amd64 -t allen88/opentelemetry-agent:0.0.1 -f ./Dockerfile-TelemetryAgent .
docker image build --platform linux/amd64 -t allen88/otel-skywalking-collector:0.0.1 -f ./Dockerfile-OTELSkywalkingCollector .
docker image build --platform linux/amd64 -t allen88/otel-loki-collector:0.0.1 -f ./Dockerfile-OTELLokiCollector .

## current
docker image build -t allen88/animal-name-service:0.0.1 -f ./Dockerfile-Animal .
docker image build -t allen88/scientist-name-service:0.0.1 -f ./Dockerfile-Scientist .
docker image build -t allen88/name-generator-service:0.0.1 -f ./Dockerfile-Name .

docker push allen88/animal-name-service:0.0.1
docker push allen88/animal-name-service-error:0.0.1
docker push allen88/scientist-name-service:0.0.1
docker push allen88/name-generator-service:0.0.1
docker push allen88/opentelemetry-agent:0.0.1
docker push allen88/otel-skywalking-collector:0.0.1
docker push allen88/otel-loki-collector:0.0.1