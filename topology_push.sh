#!/bin/bash

# periodically executing this script will make sure the node is known to other network participants
# and will enable the node to pull a list of peers using `topology_pull.sh`
my_block_no=$(sudo docker exec -e CARDANO_NODE_SOCKET_PATH=/node-ipc/node.socket relay-node cardano-cli query tip --mainnet | jq -r .block)

curl -s "https://api.clio.one/htopology/v1/?port=3001&blockNo=${my_block_no}" | tee -a cardano/topology-updates/topology_updater_result.json
