#!/bin/bash

# RPC connection details
RPC_CONNECT="84.247.182.145"
RPC_USER="user_222"
RPC_PASSWORD="oHUfdkZMEmJM"

# Transaction ID
TXID="37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517"

# Get full transaction details
TX_DATA=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getrawtransaction $TXID true)



# Extract the first 4 public keys from the inputs
PUB_KEYS=$(echo "$TX_DATA" | jq -r '.vin[].txinwitness[1]' | head -4)

# Extract the individual public keys
PUBKEY_0=$(echo "$PUB_KEYS" | head -1)
PUBKEY_1=$(echo "$PUB_KEYS" | head -2 | tail -1)
PUBKEY_2=$(echo "$PUB_KEYS" | head -3 | tail -1)
PUBKEY_3=$(echo "$PUB_KEYS" | head -4 | tail -1)

PUB_KEYS_JSON=$(jq -n --arg pk0 "$PUBKEY_0" --arg pk1 "$PUBKEY_1" --arg pk2 "$PUBKEY_2" --arg pk3 "$PUBKEY_3" \
  '$pk0, $pk1, $pk2, $pk3 | select(length > 0)' | jq -s .)
PP2SH_ADDRESS=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD createmultisig 1 "$PUB_KEYS_JSON" "legacy" | jq -r .address)

echo $PP2SH_ADDRESS




