#!/bin/bash
sudo docker run --detach \
	  --hostname 'gitlab' \
      	  --publish 443:443 --publish 8080:80 --publish 32769:22 \
	      --name gitlab \
	        --restart always \
		  --volume $GITLAB_HOME/config:/etc/gitlab \
		    --volume $GITLAB_HOME/logs:/var/log/gitlab \
		      --volume $GITLAB_HOME/data:/var/opt/gitlab \
		        gitlab/gitlab-ce:latest
