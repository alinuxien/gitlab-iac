#!/bin/bash
# utilisation : ./rundockernode.sh
docker run -d --restart always --ip 172.17.0.2 --hostname gitlabserver -p 32768:22 -p 8000:80 --name gitlabserver nodes

