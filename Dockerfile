FROM ubuntu

ENV CARDANO_NODE_HOME=/cardano
ENV PATH="${CARDANO_NODE_HOME}:${PATH}"

WORKDIR ${CARDANO_NODE_HOME}

RUN apt-get update && \
    apt-get install -y wget netbase jq curl

RUN wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest/download-by-type/file/binary-dist

RUN tar -xf binary-dist

# Using GC parameters from https://forum.cardano.org/t/solving-the-cardano-node-huge-memory-usage-done/67032
CMD ["/cardano/cardano-node", "run", \
    "+RTS", "-N2", "--disable-delayed-os-memory-return", "-I0.3", \
    "-Iw600", "-A16m", "-F1.5", "-H2500M", "-T", "-S", "-RTS", \
    "--topology", "/node-topology/mainnet-topology.json", \
    "--config", "/node-config/mainnet-config.json", \
    "--database-path", "/node-db", \
    "--socket-path", "/node-ipc/node.socket", \
    "--port", "6666"]
