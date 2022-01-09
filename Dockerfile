FROM ubuntu

WORKDIR /cardano

RUN apt-get update && \
    apt-get install -y wget netbase

RUN wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest/download-by-type/file/binary-dist

RUN tar -xf binary-dist

# Set Prometheus address to 0.0.0.0
RUN sed -i 's/127.0.0.1/0.0.0.0/g' /cardano/configuration/cardano/mainnet-config.json

# Using GC parameters from https://forum.cardano.org/t/solving-the-cardano-node-huge-memory-usage-done/67032
CMD ["/cardano/cardano-node", "run", \
    "+RTS", "-N2", "--disable-delayed-os-memory-return", \
    "-I0.3", "-Iw600", "-A16m", "-F1.5", "-H2500M", "-T", "-S", "-RTS", \
    "--database-path", "/cardano/node-db", \
    "--socket-path", "/cardano/node-db/node.socket"]
