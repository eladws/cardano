FROM ubuntu

ENV CARDANO_NODE_HOME=/cardano
ENV CARDANO_NODE_CONFIG_FILE=${CARDANO_NODE_HOME}/configuration/cardano/mainnet-config.json
ENV CARDANO_NODE_DB=${CARDANO_NODE_HOME}/node-db
ENV CARDANO_NODE_SOCKET_PATH=${CARDANO_NODE_DB}/node.socket

WORKDIR ${CARDANO_NODE_HOME}

RUN apt-get update && \
    apt-get install -y wget netbase jq curl

RUN wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest/download-by-type/file/binary-dist

RUN tar -xf binary-dist

# Customize configuration
RUN sed -i 's/127.0.0.1/0.0.0.0/g' ${CARDANO_NODE_CONFIG_FILE}
RUN sed -i 's/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g' ${CARDANO_NODE_CONFIG_FILE}

CMD ["/cardano/cardano-node", "run", \
    "--topology", "/cardano/topology-updates/mainnet-topology.json", \
    "--database-path", "/cardano/node-db", \
    "--socket-path", "/cardano/node-db/node.socket"]
