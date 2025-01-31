#!/bin/bash

# RPC connection details
RPC_CONNECT="84.247.182.145"
RPC_USER="user_222"
RPC_PASSWORD="oHUfdkZMEmJM"

# Block height
BLOCK_HEIGHT=123456

# Get the block hash for the given height
BLOCK_HASH=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getblockhash $BLOCK_HEIGHT)

# Get the full block data
BLOCK_DATA=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getblock $BLOCK_HASH 2)

# Extract all transaction IDs in the block
TX_IDS=$(echo "$BLOCK_DATA" | jq -r '.tx[].txid')

# Initialize output counter
TOTAL_OUTPUTS=0

# Iterate over each transaction to count the number of outputs
for TXID in $TX_IDS; do
    OUTPUT_COUNT=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getrawtransaction $TXID true | jq '.vout | length')
    TOTAL_OUTPUTS=$((TOTAL_OUTPUTS + OUTPUT_COUNT))
done

# Print the total number of new outputs
echo "Total new outputs in block $BLOCK_HEIGHT: $TOTAL_OUTPUTS"
# How many new outputs were created by block 123,456?
