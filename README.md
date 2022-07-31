# rdrive-testnet-launch

## This will create the required genesis files
The shell variable `$GENESIS_NODE` should be set to the rnode directory for whatever rnodew your doing genesis on

```bash
mkdir -p $GENESIS_NODE/genesis
cd $GENESIS_NODE
wget https://raw.githubusercontent.com/r-publishing/rdrive-testnet-launch/master/gen-wallets.bash
bash gen-wallets.bash
```

## Check wallets.txt
Quick `wc -l wallets.txt` and `sort -u wallets.txt|wc -l` should produce the same number of lines.
```bash
wc -l wallets.txt
13942 wallets.txt
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
wget https://raw.githubusercontent.com/r-publishing/rdrive-testnet-launch/master/testnet-launch.escrow.conf
mv testnet-launch.escrow.conf
```

## Update rnode.conf for genesis
Add `casper.genesis-ceremony.ceremony-master-mode = true`
Add `casper.validator-private-key = <Your genesis private key for node0 here>`

## Run your rnode with appropriate genesis arguments
These are the settings in our docker `.env`
```bash
TNL_DOMAIN=testnet-launch.r-publishing.com
RNODE_JAVA_CONFIG=-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/lib/rnode/heapdump_OOM.hprof -XX:+ExitOnOutOfMemoryError -XX:ErrorFile=/var/lib/rnode/hs_err.log -Dlogback.configurationFile=/var/lib/rnode/logback.xml -XX:MaxDirectMemorySize=1g -J-Xmx24g
TNL_RNODE_RUN_CONFIG=run -c /var/lib/rnode/rnode.conf --network-id rdrive-testnet --shard-name rdrive-testnet-launch --fault-tolerance-threshold -1 --synchrony-constraint-threshold 0.99 --no-upnp --finalization-rate 1  --max-number-of-parents 1
```
And these are the settings from docker-compose.yml
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
