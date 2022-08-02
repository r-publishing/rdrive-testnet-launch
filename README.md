# rdrive-testnet-launch

## This will create the required genesis files
The shell variable `$GENESIS_NODE` should be set to the rnode directory for whatever rnodew your doing genesis on

```bash
mkdir -p $GENESIS_NODE/genesis
cd $GENESIS_NODE/genesis
wget https://raw.githubusercontent.com/r-publishing/rdrive-testnet-launch/master/gen-wallets.bash
bash gen-wallets.bash
```

## Check wallets.txt
The following two commands should output the same number
```bash
cat wallets.txt|wc -l
13942
```
```bash
sort -u wallets.txt|wc -l
13942
```

## Get validators bonds.txt
```bash
wget https://raw.githubusercontent.com/r-publishing/rdrive-testnet-launch/master/testnet-launch.validator.bonds.txt
mv testnet-launch.validator.bonds.txt bonds.txt
```

## Get escrow public keys
```bash
cd ..
wget https://raw.githubusercontent.com/r-publishing/rdrive-testnet-launch/master/testnet-launch.escrow.conf
mv testnet-launch.escrow.conf rnode.conf
```

## Update rnode.conf for genesis
```bash
echo "casper.genesis-ceremony.ceremony-master-mode = true" >> rnode.conf
echo "standalone = true" >> rnode.conf
echo "casper.validator-private-key = <Your private key for node0 here>" >>rnode.conf
```

## Run your rnode with appropriate genesis arguments

These are the settings in docker `.env`
```bash
TNL_DOMAIN=testnet-launch.r-publishing.com
RNODE_JAVA_CONFIG=-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/lib/rnode/heapdump_OOM.hprof -XX:+ExitOnOutOfMemoryError -XX:ErrorFile=/var/lib/rnode/hs_err.log -Dlogback.configurationFile=/var/lib/rnode/logback.xml -XX:MaxDirectMemorySize=1g -J-Xmx24g
TNL_RNODE_RUN_CONFIG=run -c /var/lib/rnode/rnode.conf --network-id rdrive-testnet --shard-name rdrive-testnet-launch --fault-tolerance-threshold -1 --synchrony-constraint-threshold 0.99 --no-upnp --finalization-rate 1  --max-number-of-parents 1
```

These are the settings in `docker-compose.yml`
```YAML
version: '2.3'

x-rnode:
  &default-rnode
  image: rchain/rnode:v0.13.0-alpha3
  user: root

services:
########################################################################
#
  node0:
    << : *default-rnode
    container_name: node0
    ports:
      - 40440:40440
      - 40442:40402
      - 40444:40444
    volumes:
      - $RNODE_DIR/node0/rnode/:/var/lib/rnode/
    command:
      $RNODE_JAVA_CONFIG
      $TNL_RNODE_RUN_CONFIG      --api-max-blocks-limit=3
      --host node0.$TNL_DOMAIN   --protocol-port 40440 --discovery-port 40444
```

## When am I done?
Genesis time is dependant on the size of your `wallets.txt`.
The current `testnet-launch` uses a `wallets.txt` that is ~13,000 entries and takes ~11 minutes to complete.

Use `docker logs node0 -f`, to view the rnode log.
When genesis is finished you should see this message.
```
Making a transition to Running state. Approved Block #0 (4bc51d1fad...) with empty parents (supposedly genesis)
```

# Run other validators

# Run observer node

# Run reverse proxy

# Running automated propose
`cd /rchain/scripts/propose`

## install autoconf
`apt install autoconf python3-pip3`

## get python dependencies
`wget https://raw.githubusercontent.com/rchain/rchain-testnet-node/dev/scripts/requirements.txt`

remove `pyjq` from `requirements.txt` -- it should be the last line

`pip3 install -r requirements.txt`

## get latest python script
`wget https://raw.githubusercontent.com/rchain/rchain-testnet-node/dev/scripts/propose_in_turnv1.py`

## Use the config from the top of `propose_in_turnv1.py` to create `propose.yml`
```yml
servers:
  - node0:
      host: node0.testnet-launch.r-publishing.com
      grpc_port: 40441
      http_port: 40443
valid_offset: -1
waitTimeout: 300000
waitInterval: 2
proposeInterval: 10
error_node_records: /var/log/propose-script-error.txt
error_logs: /var/log/propose-script-error.log
pause_path: /rchain/scripts/propose/PAUSE-PROPOSE-SCRIPT
keepalive: 10
keepalive_timeout: 10
max_propose_retry: 3
deploy:
    contract: /rchain/scripts/propose/coop.rho
    phlo_limit: 100000
    phlo_price: 1
    deploy_key: <Your propose private key here>
    shardID: rdrive-testnet-launch
```

```bash
mv propose_in_turnv1.py propose_in_turn.py
cp propose-orchestrator.service /etc/systemd/system
systemctl enable propose-orchestrator.service
systemctl start propose-orchestrator.service
```
