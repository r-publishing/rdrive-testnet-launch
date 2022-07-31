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


## Run your rnode with appropriate genesis arguments
These are the settings in our docker `.env`
```bash
TNL_DOMAIN=testnet-launch.r-publishing.com
RNODE_JAVA_CONFIG=-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/lib/rnode/heapdump_OOM.hprof -XX:+ExitOnOutOfMemoryError -XX:ErrorFile=/var/lib/rnode/hs_err.log -Dlogback.configurationFile=/var/lib/rnode/logback.xml -XX:MaxDirectMemorySize=1g -J-Xmx24g
TNL_RNODE_RUN_CONFIG=run -c /var/lib/rnode/rnode.conf --network-id rdrive-testnet --shard-name rdrive-testnet-launch --fault-tolerance-threshold -1 --synchrony-constraint-threshold 0.99 --no-upnp --finalization-rate 1  --max-number-of-parents 1
```
And these are the settings from of docker-compose.yml
```
command:
$RNODE_JAVA_CONFIG
$TNL_RNODE_RUN_CONFIG --api-max-blocks-limit=3
      --host node0.$TNL_DOMAIN   --protocol-port 40440 --discovery-port 40444
```
