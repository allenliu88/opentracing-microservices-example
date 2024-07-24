#!/bin/bash

######################### 构建镜像 #########################
cd ~/Customize/Share/Git/00-opensource/8-blog/opentracing-microservices-example/bootstrap

## linux/amd64
docker image build --platform linux/amd64 -t allen88/opentelemetry-agent:0.0.1 -f docker/Dockerfile-TelemetryAgent .
docker image build --platform linux/amd64 -t allen88/otel-skywalking-collector:0.0.1 -f docker/Dockerfile-OTELSkywalkingCollector .
docker image build --platform linux/amd64 -t allen88/otel-loki-collector:0.0.1 -f docker/Dockerfile-OTELLokiCollector .

## 本地 Apple M1 ARM64
docker image build -t allen88/otel-collector-sampling:0.1.0 -f docker/Dockerfile-OTELCollectorSamplingArm64 .

######################### 推送镜像 #########################
docker push allen88/opentelemetry-agent:0.0.1
docker push allen88/otel-skywalking-collector:0.0.1
docker push allen88/otel-loki-collector:0.0.1
docker push allen88/otel-collector-sampling:0.1.0