FROM ubuntu

WORKDIR /cardano

RUN apt-get update && \
    apt-get install -y wget

RUN wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest/download-by-type/file/binary-dist

RUN tar -xf binary-dist

RUN mkdir node-

CMD ["/cardano/cardano-node", "run"]
