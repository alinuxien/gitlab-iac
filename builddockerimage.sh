#!/bin/bash
# utilisation : ./builddockerimage.sh "mon mot de passe" 
docker build -t nodes --build-arg ROOT_PASS="$1" .
