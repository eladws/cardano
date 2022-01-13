FROM ubuntu

ENV CARDANO_NODE_HOME=/cardano
ENV CARDANO_NODE_CONFIG_FILE=${CARDANO_NODE_HOME}/configuration/cardano/mainnet-config.json
ENV PATH="${CARDANO_NODE_HOME}:${PATH}"

WORKDIR ${CARDANO_NODE_HOME}

RUN apt-get update && \
    apt-get install -y wget netbase jq curl

RUN wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest/download-by-type/file/binary-dist

RUN tar -xf binary-dist

# Customize configuration
RUN sed -i 's/127.0.0.1/0.0.0.0/g' ${CARDANO_NODE_CONFIG_FILE}
RUN sed -i 's/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g' ${CARDANO_NODE_CONFIG_FILE}

# Using GC parameters from https://forum.cardano.org/t/solving-the-cardano-node-huge-memory-usage-done/67032
CMD ["/cardano/cardano-node", "run", \
    "+RTS", "-N2", "--disable-delayed-os-memory-return", "-I0.3", \
    "-Iw600", "-A16m", "-F1.5", "-H2500M", "-T", "-S", "-RTS", \
    "--topology", "/node-topology/mainnet-topology.json", \
    "--database-path", "/node-db", \
    "--socket-path", "/node-ipc/node.socket", \
    "--port", "6666"]
