# cardano
My Cardano node setup, happily shared for the greater good 🍻

My goal was to try and make the process as simple as possible, and after a significant amount of time spent reading and experimenting, I mangaged to put everything in a <strong><em>single setup script</em></strong>, that will install everything you need and start a healthy and good-looking cardano node 🥳 

There's also a script for a complete Staking pool setup. 

*** If you find it helpful, please support me by staking with the <em>TRAIL</em> pool 🙏🏻 ***

<h2>Simple node deployment</h2>

First, give your user the required permissions to run all required commands. Depends on your opearating system, it should e something like:

```usermod -aG admin [your-user]```

You might need to login again for it to affect.

Then, all you have to do is copy `setup.sh` into your home directory (using <strong>scp</strong> or alike), and run it
(you can also clone this repo to your home dir, and run the script from there).

That's it 😎

The script will install all required packages, and start a docker-compose application running a relay node alongside a prometheus instance, and setup several other required tasks such as a topolgy updater, etc.

<h2>Deploy on Windows</h2>

Using docker, deploying on Windows is a piece of cake cake too 🍰

Install [Docker Desktop](https://docs.docker.com/desktop/windows/install/) on your windows machine, and follow the instruction to install and enable [WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install-manual) (see [this](https://docs.docker.com/desktop/windows/wsl/) for additional info).
Then, open the Linux shell (I used Ubuntu 20.04 LTS, from the Microsoft App Store), and follow the exact same instructions as above.

That's it 😎

<h2>Deploying a core (block-producing node)</h2>
 <!-- TODO: include in the smae setup using a flag ?-->
If you want to run a block producer (core) node - use `setup-core-node.sh`, but make sure you copy your topology, keys and certificate to the right place before running the script (see [here](https://developers.cardano.org/docs/stake-pool-course/handbook/register-stake-pool-metadata) for details). 

<h2>Script parameters</h2>

By using the `-i` flas, you can specify the docker image that will be used for the cardano node.

While the default is using [IOHK's official docker image](https://hub.docker.com/r/inputoutput/cardano-node), you can specify any other image as long as it respects the parameters defined in the `docker-compose.yaml` to specify some required configurations (i.e, topology file, port, etc.). 

You can of course use my image (`eladws/cardano-node`), and check out the `Dockerfile` I used to build it for more details. 

<h2>What is a topology updater?</h2>

In short, it is a process you have to run in order for your node to be known to other peers, and have a list of updated valid peers. This is highly recommended until Cardano will implement its peer-to-peer mechanism.

You can find a comprehensive discussion [here](https://forum.cardano.org/t/is-running-topology-updater-a-must/91494).

<h2>Addresses and ports</h2>

This setup is using port `6666` as an incoming port for a regular (relay) node, and port `5555` for the block producing (core) node.
The host addresses are remained untouched, and need to be set manually if neccessary.

<h2>Just run the containers</h2>

If you prefer running each contaier separately rather than deploying the full setup, you can build and run the containers yourself:

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
