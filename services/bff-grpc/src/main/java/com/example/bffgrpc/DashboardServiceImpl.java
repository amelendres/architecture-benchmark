
package com.example.bffgrpc;

import com.example.bffgrpc.config.GrpcClientConfig;
import com.example.bffgrpc.proto.DashboardRequest;
import com.example.bffgrpc.proto.DashboardResponse;
import com.example.bffgrpc.proto.DashboardServiceGrpc;

import com.example.mock.proto.MockRequest;
import com.example.mock.proto.MockServiceGrpc;
import io.grpc.stub.StreamObserver;
import org.springframework.context.annotation.Import;
import org.springframework.grpc.server.service.GrpcService;

import java.util.concurrent.CompletableFuture;

@GrpcService
@Import(GrpcClientConfig.class)
public class DashboardServiceImpl extends DashboardServiceGrpc.DashboardServiceImplBase {

  private MockServiceGrpc.MockServiceFutureStub user;
  private MockServiceGrpc.MockServiceFutureStub order;
  private MockServiceGrpc.MockServiceFutureStub notification;

    public DashboardServiceImpl(
            MockServiceGrpc.MockServiceFutureStub user,
            MockServiceGrpc.MockServiceFutureStub order,
            MockServiceGrpc.MockServiceFutureStub notification
    ) {
        this.user = user;
        this.order = order;
        this.notification = notification;
    }

    @Override
  public void getDashboard(DashboardRequest req, StreamObserver<DashboardResponse> obs) {

    CompletableFuture<String> u = call(user);
    CompletableFuture<String> o = call(order);
    CompletableFuture<String> n = call(notification);

    CompletableFuture.allOf(u,o,n).thenAccept(v -> {
      obs.onNext(DashboardResponse.newBuilder()
        .setUser(u.join())
        .setOrders(o.join())
        .setNotifications(n.join())
        .build());
      obs.onCompleted();
    });
  }

  private CompletableFuture<String> call(MockServiceGrpc.MockServiceFutureStub stub) {
    CompletableFuture<String> cf = new CompletableFuture<>();
    stub.get(MockRequest.newBuilder().setId("1").build())
      .addListener(() -> {
        try {
          cf.complete(stub.get(MockRequest.newBuilder().setId("1").build()).get().getPayload());
        } catch (Exception e) {
          cf.complete("err");
        }
      }, Runnable::run);
    return cf;
  }
}
