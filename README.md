# cardano
My Cardano node setup, happily shared for the greater good 🍻

(If you like it, please Stake some of your $ADA with me by delegating to the [TRAIL](https://pooltool.io/pool/2191a50e38d946f0980fce56cd338d6d74781b6ee03e491bcb8cdaa2) pool! 🙏🏻)

My goal was to try to make the process as simple as possible, and after a significant amount of time spent reading and experimenting, I mangaged to put everything in a <strong><em>single setup script</em></strong>, that will install everything you need and start a healthy and good-looking cardano node 🥳 

<h2>Full node deployment</h2>
For a full setup on a fresh server (e.g, an AWS EC2 instance), all you have to do is run the relevant setup script.

It will install all required packages, start a docker-compose application running a relay node alongside a prometheus instance, and setup several other required tasks such as a topolgy updater, etc.

Just log-in to your instance, copy the relevant setup script into the root folder (using <strong>scp</strong> or similar software) and run it.
Alternatively, you can `git clone` this repo into your server's home folder, and run the setup script from there.

You can choose `setup-official-image.sh` if you want to run the node using [IOHK's official docker image](https://hub.docker.com/r/inputoutput/cardano-node), or `setup-custom-image.sh` if you want to run the node using a custom built docker image (you can of course use my image, and check out the `Dockerfile` I used to build it for more details). 

If you want to run a block producer (core) node - use `setup-core-node.sh`, but make sure you copy your topology, keys and certificate to the right place before running the script (see [here](https://developers.cardano.org/docs/stake-pool-course/handbook/register-stake-pool-metadata) for details). 

All you have to do is run the script. (<em>important:</em> the script is using `sudo` whenever required, so DO NOT run the script itself with `sudo` !)

If all is good, you should be able to see metrics updated on port 9090, and the topology file gets updated once per hour.

<h4>What is a topology updater?</h4>

In short, it is a process you have to run in order for your node to be known to other peers, and have a list of updated valid peers. This is highly recommended until Cardano will implement its peer-to-peer mechanism.

You can find a comprehensive discussion [here](https://forum.cardano.org/t/is-running-topology-updater-a-must/91494).

<h4>Addresses and ports</h4>

This setup is using port `6666` as an incoming port for a regular (relay) node, and port `5555` for the block producing (core) node.
The host addresses are remained untouched, and need to be set manually if neccessary.

<h2>Just run the containers</h2>
Alternatively, you can build and run the containers yourself:

Build a cardano-node container, running the [latest pre-compiled executable](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest/)

```docker build -t [owner/repo] .```

Run the container 

It uses the default configuration, but requires a topology file (you can get one [here](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-topology.json)) and a local path for ipc (just an empty local foder).

```docker volume create node-db```

```docker run -d -p 12798:12798 -v [path-to-topology-file]:/node-topology/mainnet-topology.json -v [path-to-put-ipc]:/node-ipc --mount source=node-db,target=/node-db [owner/repo]```

Run Prometheus container for monitoring

(Requires a prometheus.yml file containing the node's container address as a target)

```docker run -d -p 9090:9090 -v [path-to-prometheus.yml]:/etc/prometheus/prometheus.yml prom/prometheus```

<h2>Run a block producing (core) node</h2>

To run a block producer you will need two signing keys (`kes.skey`, `vrf.skey`) and a certificate (`node.cert`).

After generating all required keys, put them in some folder, and mount it onto the node at `/node-keys`.

```docker run -d -p 12798:12798 -v [path-to-topology-file]:/node-topology/block-producer-topology.json -v [path-to-put-ipc]:/node-ipc --mount source=node-db,target=/node-db -v [path-to-keys-folder]:/node-keys [owner/repo]```
