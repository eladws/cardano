# cardano
My Cardano node setup

For a full setup on a fresh server (i.e, an AWS EC2 instance), all you have to do is run the *setup.sh* script.

It will start a *docker-compose* application running a relay node alongside a prometheus instance, and will setup several other required tasks such as topolgy updates, etc.

Alternatively, you can build and run the containers yourself:

Build a cardano-node container, running the [latest pre-compiled executable](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest/)

```docker build -t [owner/repo] .```

Run the container

```docker volume create node-db```

```docker run -d -p 12798:12798 --mount source=node-db,target=/cardano/node-db [owner/repo]```

Run Prometheus container for monitoring

(Requires a prometheus.yml file containing the node's container address as a target)

```docker run -d -p 9090:9090 -v [path-to-prometheus.yml]:/etc/prometheus/prometheus.yml prom/prometheus```
