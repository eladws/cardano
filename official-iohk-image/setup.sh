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

# download initial topology, and set topology update processes
mkdir cardano/topology-updates
wget -O cardano/topology-updates/mainnet-topology.json https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-topology.json

echo "55 * * * * ./cardano/topology_push.sh" > crontab.txt
echo "5 5 * * * ./cardano/topology_pull.sh" >> crontab.txt
crontab crontab.txt

# downlaod default configuration
mkdir cardano/node-config
wget -O cardano/node-config/mainnet-config.json https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-config.json
wget -O cardano/node-config/mainnet-byron-genesis.json https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-byron-genesis.json
wget -O cardano/node-config/mainnet-shelley-genesis.json https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-shelley-genesis.json
wget -O cardano/node-config/mainnet-alonzo-genesis.json https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-alonzo-genesis.json

sed -i 's/127.0.0.1/0.0.0.0/g' cardano/node-config/mainnet-config.json
sed -i 's/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g' cardano/node-config/mainnet-config.json

# start node
sudo docker-compose -f cardano/official-iohk-image/docker-compose.yaml up -d
