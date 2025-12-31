
package com.example.bffwebflux;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Map;

@RestController
public class DashboardController {

  private final WebClient client = WebClient.create();

  @GetMapping("/dashboard")
  public Mono<Map<String,String>> dashboard() {
    Mono<String> user = client.get().uri("http://user:8080/get").retrieve().bodyToMono(String.class);
    Mono<String> order = client.get().uri("http://order:8080/get").retrieve().bodyToMono(String.class);
    Mono<String> notification = client.get().uri("http://notification:8080/get").retrieve().bodyToMono(String.class);

    return Mono.zip(user, order, notification)
        .map(t -> Map.of(
            "user", t.getT1(),
            "orders", t.getT2(),
            "notifications", t.getT3()
        ));
  }
}
