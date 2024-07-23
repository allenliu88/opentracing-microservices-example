#!/bin/bash
set -e

cd ~/Customize/Share/Git/00-opensource/8-blog/opentracing-microservices-example

echo "[Building] animal-name-service docker image..."
cd animal-name-service
./mvnw clean install
mv target/animal-name-service-0.0.1-SNAPSHOT.jar ../bootstrap/artifact/
cd ../bootstrap

case $1 in
  linux/amd64)
    docker image build --platform linux/amd64 -t allen88/animal-name-service:0.0.1 -f docker/Dockerfile-Animal .
    ;;
  *)
    docker image build -t allen88/animal-name-service:0.0.1 -f docker/Dockerfile-Animal .
    ;;
esac

docker push allen88/animal-name-service:0.0.1
echo "[Done]Built and push animal-name-service docker image..."

echo "[Building] scientist-name-service docker image..."
cd ../scientist-name-service
./mvnw clean install
mv target/scientist-name-service-0.0.1-SNAPSHOT.jar ../bootstrap/artifact/
cd ../bootstrap

case $1 in
  linux/amd64)
    docker image build --platform linux/amd64 -t allen88/scientist-name-service:0.0.1 -f docker/Dockerfile-Scientist .
    ;;
  *)
    docker image build -t allen88/scientist-name-service:0.0.1 -f docker/Dockerfile-Scientist .
    ;;
esac

docker push allen88/scientist-name-service:0.0.1
echo "[Done]Built and push scientist-name-service docker image..."

echo "[Building] name-generator-service docker image..."
cd ../name-generator-service
./mvnw clean install
mv target/name-generator-service-0.0.1-SNAPSHOT.jar ../bootstrap/artifact/
cd ../bootstrap

case $1 in
  linux/amd64)
    docker image build --platform linux/amd64 -t allen88/name-generator-service:0.0.1 -f docker/Dockerfile-Name .
    ;;
  *)
    docker image build -t allen88/name-generator-service:0.0.1 -f docker/Dockerfile-Name .
    ;;
esac

docker push allen88/name-generator-service:0.0.1
echo "[Done]Built and push name-generator-service docker image..."