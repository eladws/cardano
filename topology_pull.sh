#!/bin/bash

# this script downloads the latest list of validated peers, and restarts the node if neccesary

my_block_producing_ip="127.0.0.1" # TODO: CHANGE ME IF CONNECTED TO A CORE NODE
my_block_producing_port="5555"
topology_file="cardano/topology-updates/mainnet-topology.json"
curl -s -o ${topology_file}.new "https://api.clio.one/htopology/v1/fetch/?max=20&customPeers=${my_block_producing_ip}:${my_block_producing_port}:1|relays-new.cardano-mainnet.iohk.io:3001:2"

if grep -q "IP is not (yet) allowed to fetch this list" ${topology_file}.new; then
    echo "still not allowed to pull topology"
elif cmp --silent -- ${topology_file}.new ${topology_file}; then
  echo "no change in topology"
else
  echo "topology got updated"
  echo $(date) > cardano/topology-updates/TOPOLOGY_UPDATED
  cp ${topology_file}.new ${topology_file}
fi
rm ${topology_file}.new
