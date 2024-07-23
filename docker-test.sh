#!/bin/bash

######################### 本地测试 #########################

docker run -it allen88/opentelemetry-agent:0.0.1 ls /tmp
docker run -it allen88/opentelemetry-agent:0.0.1 ls /tmp/skywalking-agent

docker run -it allen88/otel-skywalking-collector:0.0.1 ls
docker run -it allen88/otel-skywalking-collector:0.0.1 env
docker run -d allen88/otel-skywalking-collector:0.0.1

cd ~/Customize/Share/Git/00-opensource/8-blog/opentracing-microservices-example/bootstrap

## 生成工作负载资源
istioctl kube-inject -f k8s/name-deployment.yml | kubectl apply -n allen -f -
istioctl kube-inject -f k8s/name-deployment-ext.yml | kubectl apply -n allen -f -
istioctl kube-inject -f k8s/name-deployment-skywalking.yml | kubectl apply -n allen -f -

istioctl kube-inject -f k8s/name-deployment-ext-sampling.yml | kubectl delete -n allen -f -
istioctl kube-inject -f k8s/name-deployment-ext-sampling.yml | kubectl apply -n allen -f -
kubectl get po -n allen

kubectl delete -n istio-system -f k8s/otel-jaeger-sampling-collector.yml
kubectl apply -n istio-system -f k8s/otel-jaeger-sampling-collector.yml
kubectl get po -n istio-system
kubectl logs -f -n istio-system deploy/otel-jaeger-sampling-collector

## 生成网关配置
kubectl apply -n allen -f k8s/name-gateway.yml

## 请求验证
curl -H 'X-Custom-Id: 7890' -H 'X-Custom-Name: Custom Name' -H 'X-Custom-Omit: Omit Header' -v http://172.23.16.213:30893/api/v1/names/random

## Others
# COPY artifact/opentelemetry-javaagent.jar /opentelemetry-javaagent.jar
# CMD java $JAVA_OPTS -javaagent:/opentelemetry-javaagent.jar -jar /app.jar
CMD ["sleep", "3600"]