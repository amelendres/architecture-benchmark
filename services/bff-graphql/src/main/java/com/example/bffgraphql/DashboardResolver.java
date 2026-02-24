
package com.example.bffgraphql;

import java.util.List;

import javax.sound.midi.Track;

import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.stereotype.Controller;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Controller
public class DashboardResolver {

  private final WebClient client = WebClient.create();

  @QueryMapping
  public Mono<Dashboard> dashboard() {
    Mono<String> user = call("http://user:8080/get");
    Mono<String> order = call("http://order:8080/get");
    Mono<String> notification = call("http://notification:8080/get");

    return Mono.zip(user, order, notification)
        .map(t -> new Dashboard(t.getT1(), t.getT2(), t.getT3()));
  }

  	// @SchemaMapping
    // public Mono<Dashboard> dashboard(Dashboard dashboard) {
    //   return dashboard();
    // }


  private Mono<String> call(String url) {
    return client.get().uri(url).retrieve().bodyToMono(String.class);
  }
}
