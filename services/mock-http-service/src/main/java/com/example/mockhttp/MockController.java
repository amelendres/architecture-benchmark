package com.example.mockhttp;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
public class MockController {

    @GetMapping("/get")
    public Mono<String> get() {
        return Mono.fromCallable(() -> {
            Thread.sleep(5);   // fixed latency
            return "ok";
        });
    }
}
