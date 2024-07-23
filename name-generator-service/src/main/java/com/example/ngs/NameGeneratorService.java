package com.example.ngs;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.HttpHeaders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static strman.Strman.toKebabCase;

@SpringBootApplication
@EnableFeignClients
public class NameGeneratorService {

    public static void main(String[] args) {
        SpringApplication.run(NameGeneratorService.class, args);
    }

}


@FeignClient(name = "scientist-service-client", url = "${scientist.service.prefix.url}")
interface ScientistServiceClient {

    @GetMapping("/api/v1/scientists/random")
    String randomScientistName();

}

@FeignClient(name = "animal-service-client", url = "${animal.service.prefix.url}")
interface AnimalServiceClient {

    @GetMapping("/api/v1/animals/random")
    String randomAnimalName();

    @GetMapping("/api/v1/animals/error")
    String animalError();

    @GetMapping("/api/v1/animals/latency")
    String animalLatency();
}


@RestController
@RequestMapping("/api/v1/names")
class NameResource {
    private final Logger LOGGER = LoggerFactory.getLogger(NameResource.class);

    @Autowired
    private AnimalServiceClient animalServiceClient;
    @Autowired
    private ScientistServiceClient scientistServiceClient;

    @GetMapping(path = "/random")
    public String name(@RequestHeader HttpHeaders headers) throws Exception {
        String animal = animalServiceClient.randomAnimalName();
        String name = animal;
        // String scientist = scientistServiceClient.randomScientistName();
        // String name = toKebabCase(scientist) + "-" + toKebabCase(animal);
        System.out.println("===========================================");
        System.out.println("HttpHeaders: " + headers);
        System.out.println("===========================================");
        return name;
    }

    @GetMapping(path = "/error")
    public String error(@RequestHeader HttpHeaders headers) throws Exception {
        String animal = animalServiceClient.animalError();
        String name = animal;
        System.out.println("===========================================");
        System.out.println("HttpHeaders: " + headers);
        System.out.println("===========================================");
        return name;
    }

    @GetMapping(path = "/latency")
    public String latency(@RequestHeader HttpHeaders headers) throws Exception {
        String animal = animalServiceClient.animalLatency();
        String name = animal;
        System.out.println("===========================================");
        System.out.println("HttpHeaders: " + headers);
        System.out.println("===========================================");
        return name;
    }

}