#!/bin/bash
sudo /usr/local/scripts/install-docker.sh
sudo /usr/local/scripts/allow-despegar-edit-docker-opts.sh
sudo /usr/local/scripts/restart-docker.sh
sudo /usr/local/scripts/install_pip.sh
sudo /usr/local/scripts/config-redis-memory.sh
#sudo /usr/local/scripts/install-docker-compose.sh
./scripts/pip-install-redis-client.sh