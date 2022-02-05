#!/bin/bash
node_image="official"
node_mode="relay"
while getopts i:m: flag
do
    case "${flag}" in
        i) node_image=${OPTARG};;
        m) node_mode=${OPTARG};;
    esac
done

# install useful packages
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release wget git jq

# install docker
if ! command -v docker
then
    echo "docker does not exist. installing docker..."

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
else
    echo "docker is already installed"
fi

# install docker-compose
if ! command -v docker-compose
then
    echo "docker-compose does not exist. installing docker-compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "docker is already installed"
fi

# clone git repo if it is not present
if [ ! -d "cardano" ] 
then
    echo "Cloning repo..."
    apt-get install -y git
    git clone https://github.com/eladws/cardano.git cardano
    chmod +x cardano/*.sh
fi

# downlaod default configuration
mkdir cardano/node-config
wget -O cardano/node-config/mainnet-config.json https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-config.json
wget -O cardano/node-config/mainnet-byron-genesis.json https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-byron-genesis.json
wget -O cardano/node-config/mainnet-shelley-genesis.json https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-shelley-genesis.json
wget -O cardano/node-config/mainnet-alonzo-genesis.json https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-alonzo-genesis.json

# make required changes to configuration file
sed -i 's/127.0.0.1/0.0.0.0/g' cardano/node-config/mainnet-config.json
sed -i 's/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g' cardano/node-config/mainnet-config.json
# TODO: check if ports should also be changed for core node

if [ $node_mode == "relay" ]; then
    # set topology updates and daily restarts as cron jobs
    echo "55 * * * * ./cardano/topology_push.sh" > crontab.txt
    echo "5 5 * * * ./cardano/topology_pull.sh" >> crontab.txt
    echo "* 6 * * * docker-compose -f cardano/docker-compose-custom-image.yaml restart relay-node" >> crontab.txt
    crontab crontab.txt
elif [ $node_mode == "core" ]; then
    # check required keys exist
    if [ ! -d "cardano/node-keys" ] 
    then
        echo "Cannot run without node-keys folder!"
        exit 1
    fi

    if [ ! -f "cardano/node-keys/kes.skey" ]; then
        echo "Missing kes.skey!"
        exit 1
    fi

    if [ ! -f "cardano/node-keys/vrf.skey" ]; then
        echo "Missing vrf.skey!"
        exit 1
    fi

    if [ ! -f "cardano/node-keys/node.cert" ]; then
        echo "Missing node.cert!"
        exit 1
    fi
    # check required topology was set
    if grep -q "RELAY IP ADDRESS" "cardano/block-producer-topology/block-producing-topology.json"; then
        echo "You need to explicitly set your relay public IP address and port in cardano/block-producer-topology/block-producing-topology.json !"
        exit 1
    fi
else
    echo "Unknown node mode $node_mode. Please specify relay (default) or core."
    exit 1
fi

# TODO: make a single docker compose with all components, with configurable image, and optional core-node !
echo "Starting docker $node_mode node using $node_image image..."
compose_file = cardano/docker-compose-official.yaml
if [ $node_image != "official" ] 
    compose_file = cardano/docker-compose-custom.yaml
fi

if [ $node_mode == "relay" ];
    CARDANO_NODE_IMAGE=$node_image cardano/docker-compose -f $compose_file up -d
elif [ $node_mode == "core" ];
    # TODO: core node should have custom \ official compose files too
    CARDANO_NODE_IMAGE=$node_image docker-compose -f cardano/docker-compose-core-node.yaml up -d
fi
