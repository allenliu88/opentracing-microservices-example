# opentracing-microservices-example

This is source code for blog [Jaeger Integration With Spring Boot Application](https://medium.com/xebia-engineering/jaeger-integration-with-spring-boot-application-3c6ec4a96a6f).

## 使用指南
```shell
cd opentracing-microservices-example/bootstrap

## 生成工作负载资源
## #1 普通示例
istioctl kube-inject -f name-deployment.yml | kubectl apply -n allen -f -
## #2 通过`-Dotel.javaagent.extensions=/agent/opentelemetry-java-instrumentation-propagator-ext-0.1.0-all.jar`插件来自动传递Trace请求头
istioctl kube-inject -f name-deployment-ext.yml | kubectl apply -n allen -f -
## #3 定制化上报Skywalking格式的Trace数据
istioctl kube-inject -f name-deployment-skywalking.yml | kubectl apply -n allen -f -

## 生成网关配置
kubectl apply -n allen -f name-gateway.yml

## 请求验证：注意，请求端口`30893`要使用系统环境中的IngressGateway Service的NodePort来实际替换
curl -H 'X-Custom-Id: 7890' -H 'X-Custom-Name: Custom Name' -H 'X-Custom-Omit: Omit Header' -v http://172.23.16.213:30893/api/v1/names/random
```

## 特性列表
### 基本OTEL接入配置
```shell
istioctl kube-inject -f name-deployment.yml | kubectl apply -n allen -f -
```

### Skywalking Agent接入配置
```shell
## 注意
## Dockerfile-OTELSkywalkingCollector：包含了Collector及其配置逻辑otel-skywalking-collector-config.yaml
## 通过name-deployment-skywalking.yml进行统一部署，涵盖了工作负载及Collector的部署及配置
istioctl kube-inject -f name-deployment-skywalking.yml | kubectl apply -n allen -f -

## 配置Skywalking Tracer Telemetry
kubectl apply -n allen -f skywalking-tracer-telemetry.yaml
```

### Loki接入配置
```shell
## Loki Collector，含其配置otel-loki-collector-config.yaml
kubectl apply -n -f loki-collector-deployment.yml

## Loki Telemetry
kubectl apply -n -f loki-logs-telemetry.yaml
```

### 增加Logger MDC配置验证
参考[Logger MDC auto-instrumentation](https://github.com/open-telemetry/opentelemetry-java-instrumentation/blob/main/docs/logger-mdc-instrumentation.md)

注意：
暂时无法通过`-Dlogging.pattern.level='trace_id=%mdc{trace_id} span_id=%mdc{span_id} trace_flags=%mdc{trace_flags} %5p'`参数设置，该种方式会报错：
```shell
[otel.javaagent 2022-10-25 11:22:25:094 +0800] [main] DEBUG io.opentelemetry.javaagent.tooling.AgentInstaller$TransformLoggingListener - Transformed com.ibm.tools.attach.target.AttachHandler -- null
[otel.javaagent 2022-10-25 11:22:25:104 +0800] [main] DEBUG io.opentelemetry.javaagent.tooling.AgentInstaller$TransformLoggingListener - Transformed com.ibm.tools.attach.target.AttachHandler$teardownHook -- null
[otel.javaagent 2022-10-25 11:22:25:123 +0800] [main] DEBUG io.opentelemetry.javaagent.tooling.AgentInstaller$TransformLoggingListener - Transformed com.ibm.tools.attach.target.WaitLoop -- null
Error: Could not find or load main class span_id=%mdc{span_id}
```

只能通过环境变量的方式配置，例如：
```yaml
        env:
        - name: LOGGING_PATTERN_LEVEL
          value: trace_id=%mdc{trace_id} span_id=%mdc{span_id} trace_flags=%mdc{trace_flags} %5p
```

最终效果如下：
```shell
...
2022-10-25 14:48:13.124 trace_id=01a513385a33cf9d8c07afab3d707e78 span_id=8ecc9808e153ffd3 trace_flags=01  INFO 9 --- [nio-9000-exec-2] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring DispatcherServlet 'dispatcherServlet'
2022-10-25 14:48:13.126 trace_id=01a513385a33cf9d8c07afab3d707e78 span_id=8ecc9808e153ffd3 trace_flags=01  INFO 9 --- [nio-9000-exec-2] o.s.web.servlet.DispatcherServlet        : Initializing Servlet 'dispatcherServlet'
2022-10-25 14:48:13.168 trace_id=01a513385a33cf9d8c07afab3d707e78 span_id=8ecc9808e153ffd3 trace_flags=01  INFO 9 --- [nio-9000-exec-2] o.s.web.servlet.DispatcherServlet        : Completed initialization in 41 ms
...
===========================================
HttpHeaders: [host:"animal-name-service:9000", accept:"*/*", x-request-id:"b8c28b7f-3ad9-9dd6-97ce-cbc7a2b9e44b", x-custom-id:"7890", x-custom-name:"Custom Name", user-agent:"Java/1.8.0_202", x-forwarded-proto:"http", x-envoy-attempt-count:"1", x-forwarded-client-cert:"By=spiffe://cluster.local/ns/allen/sa/default;Hash=ac2cb568c47df0c109cb112827fcc992ab1442aba81f8b67b4cdc90e126fcea0;Subject="";URI=spiffe://cluster.local/ns/allen/sa/default", x-b3-traceid:"01a513385a33cf9d8c07afab3d707e78", x-b3-spanid:"6270e30413e9d029", x-b3-parentspanid:"f2bc20636cac4328", x-b3-sampled:"1"]
===========================================
```