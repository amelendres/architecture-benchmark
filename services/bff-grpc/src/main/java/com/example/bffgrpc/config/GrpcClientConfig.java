package com.example.bffgrpc.config;

import com.example.mock.proto.MockServiceGrpc;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.grpc.client.GrpcChannelFactory;

@Configuration
public class GrpcClientConfig {

    @Bean MockServiceGrpc.MockServiceFutureStub user(GrpcChannelFactory channels){
        return MockServiceGrpc.newFutureStub(channels.createChannel("user"));
    }
    @Bean MockServiceGrpc.MockServiceFutureStub order(GrpcChannelFactory channels){
        return MockServiceGrpc.newFutureStub(channels.createChannel("order"));
    }
    @Bean MockServiceGrpc.MockServiceFutureStub notification(GrpcChannelFactory channels){
        return MockServiceGrpc.newFutureStub(channels.createChannel("notification"));
    }
}
