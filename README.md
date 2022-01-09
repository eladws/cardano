# cardano
my Cardano setup

Build a cardano-node container, running the [latest pre-compiled executable](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest/)

```docker build -t [owner/repo] .```

Run the container
```docker volume create node-db```
```docker run -d -p 12798:12798 --mount source=node-db,target=/cardano/node-db [owner/repo]```

Run Prometheus container for monitoring
(Requires a prometheus.yml file containing the node's container address)
```docker run -d -p 9090:9090 -v [path-to-prometheus.yml]:/etc/prometheus/prometheus.yml prom/prometheus```
