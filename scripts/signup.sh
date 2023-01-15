#!/bin/bash

curl -X POST http://localhost:8091/api/auth/signup \
   -H 'Content-Type: application/json' \
   -d '{"username":"kgex_1","password":"kgex_1", "email":"kgex_1@gmail.com", "role":["user"]}'
