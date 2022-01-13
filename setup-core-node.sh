#!/bin/bash

# install useful packages
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release wget git jq

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# clone git repo if it is not present
if [ ! -d "cardano" ] 
then
    echo "Cloning repo..."
    sudo apt-get install -y git
    git clone https://github.com/eladws/cardano.git cardano
fi
chmod +x cardano/*.sh

# check files required to run a core-node
if [ ! -d "cardano/node-keys" ] 
then
    echo "Cannot run without node-keys folder!"
    exit 1
fi

if [ ! -f "cardano/node-keys/kes.skey" ]; then
    echo "Missing kes.skey!"
fi

if [ ! -f "cardano/node-keys/vrf.skey" ]; then
    echo "Missing vrf.skey!"
fi

if [ ! -f "cardano/node-keys/node.cert" ]; then
    echo "Missing node.cert!"
fi

# start node
sudo docker-compose -f cardano/docker-compose-core-node.yaml up -d
