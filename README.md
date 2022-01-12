# cardano
My Cardano node setup, happily shared for the greater good 🍻

My goal was to try to make the process as simple as possible, and after a significant amount of time spent reading and experimenting, I mangaged to put everything in a <strong><em>single setup script</em></strong>, that will install everything you need and start a healthy and good-looking cardano node 🥳 

<h2>Full node deployment</h2>
For a full setup on a fresh server (e.g, an AWS EC2 instance), all you have to do is run the <strong>setup.sh</strong> script.

It will install all required packages, start a <strong>docker-compose</strong> application running a relay node alongside a prometheus instance, and setup several other required tasks such as a topolgy updater, etc.

<h4>Deploying on a fresh Linux instance</h4>
To run on a fresh Linux instance, log-in to the instance, and copy <strong>setup.sh</strong> into the root folder (using <strong>scp</strong> or similar software).

You can choose the `official-iohk-image/setup.sh` if you want to run the node using IOHKs official docker image, or `custom-image/setup.sh` if you want to run the node using a custom build docker image (you can of course use my image, and check out the `Dockerfile` for more details). 

Give `setup.sh` run permissions, and execute it with sudo.

If all is good, you should be able to see metrics updated on port 9090, and the topology file gets updated once per hour.

<h2>Just run the containers</h2>
Alternatively, you can build and run the containers yourself:

Build a cardano-node container, running the [latest pre-compiled executable](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest/)

```docker build -t [owner/repo] .```

Run the container

```docker volume create node-db```

```docker run -d -p 12798:12798 --mount source=node-db,target=/node-db [owner/repo]```

Run Prometheus container for monitoring

(Requires a prometheus.yml file containing the node's container address as a target)

```docker run -d -p 9090:9090 -v [path-to-prometheus.yml]:/etc/prometheus/prometheus.yml prom/prometheus```
