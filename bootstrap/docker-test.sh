#!/bin/bash

docker run -it allen88/opentelemetry-agent:0.0.1 ls /tmp
docker run -it allen88/opentelemetry-agent:0.0.1 ls /tmp/skywalking-agent

docker run -it allen88/otel-skywalking-collector:0.0.1 ls
docker run -it allen88/otel-skywalking-collector:0.0.1 env
docker run -d allen88/otel-skywalking-collector:0.0.1

cd ~/Customize/Share/Git/00-opensource/8-blog/opentracing-microservices-example/bootstrap
istioctl kube-inject -f name-deployment.yml | kubectl apply -f -

istioctl kube-inject -f name-deployment-ext.yml | kubectl apply -f -

istioctl kube-inject -f name-deployment-skywalking.yml | kubectl apply -f -

curl -H 'X-Custom-Id: 7890' -H 'X-Custom-Name: Custom Name' -H 'X-Custom-Omit: Omit Header' -v http://172.23.16.213:30710/api/v1/names/random

## Others
# COPY opentelemetry-javaagent.jar /opentelemetry-javaagent.jar

# CMD java $JAVA_OPTS -javaagent:/opentelemetry-javaagent.jar -jar /app.jar