#!/bin/bash

#wrk -t8 -c200 -d30s -R1000 -s export.lua http://localhost:8081/dashboard
#wrk -t8 -c200 -d30s -R1000 -s export.lua http://bff-webflux:8080/dashboard
wrk -t4 -c100 -d30s -R1000 -s export.lua http://bff-webflux:8080/dashboard

