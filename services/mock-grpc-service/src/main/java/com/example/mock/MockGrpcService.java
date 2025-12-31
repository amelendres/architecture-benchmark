package com.example.mock;

import com.example.mock.proto.MockRequest;
import com.example.mock.proto.MockResponse;
import com.example.mock.proto.MockServiceGrpc;
import io.grpc.stub.StreamObserver;
import org.springframework.grpc.server.service.GrpcService;

@GrpcService
public class MockGrpcService extends MockServiceGrpc.MockServiceImplBase {

    @Override
    public void get(MockRequest request,
                    StreamObserver<MockResponse> observer) {
        // Simulate downstream latency
        try { Thread.sleep(5); } catch (InterruptedException ignored) {}

        observer.onNext(
                MockResponse.newBuilder().setPayload("ok").build()
        );
        observer.onCompleted();
    }
}
