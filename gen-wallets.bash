#!/bin/bash
TREASURY=testnet-launch.treasury.wallets.txt
AIRDROP=testnet-launch.wallets.txt
RCHAIN_TREASURY=testnet-launch.rchain-treasury.wallets.txt
PROPOSE=testnet-launch.propose.wallets.txt
wget https://raw.githubusercontent.com/r-publishing/rdrive-testnet-launch/master/$RCHAIN_TREASURY
wget https://raw.githubusercontent.com/r-publishing/rdrive-testnet-launch/master/$TREASURY
wget https://raw.githubusercontent.com/r-publishing/rdrive-testnet-launch/master/$AIRDROP
#wget https://raw.githubusercontent.com/r-publishing/rdrive-testnet-launch/master/$PROPOSE

cat $TREASURY $AIRDROP $RCHAIN_TREASURY > wallets.txt
