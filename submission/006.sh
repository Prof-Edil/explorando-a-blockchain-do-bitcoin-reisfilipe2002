#!/bin/bash

RPC_CONNECT="84.247.182.145"
RPC_USER="user_222"
RPC_PASSWORD="oHUfdkZMEmJM"

# Get the block hash of block 256128
BLOCK_HASH256128=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getblockhash 256128 2>/dev/null)



# Get block data and extract the coinbase transaction ID
BLOCK_DATA=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getblock $BLOCK_HASH256128 2>/dev/null)



COINBASE_TXID=$(echo "$BLOCK_DATA" | jq -r '.tx[0]' 2>/dev/null)



COINBASE_VOUT=0  # Always 0 for coinbase transactions

# Get the block hash of block 257343
BLOCK_HASH257343=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getblockhash 257343 2>/dev/null)



# Get transactions in block 257343
BLOCK_DATA257343=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getblock $BLOCK_HASH257343 2>/dev/null)


TRANSACTIONS=$(echo "$BLOCK_DATA257343" | jq -r '.tx[]' 2>/dev/null)


# Loop through each transaction and check if it spends the coinbase output
for TXID in $TRANSACTIONS
do
    # Fetch raw transaction details
    RAW_TX=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getrawtransaction $TXID 1 2>/dev/null)

    if [[ -z "$RAW_TX" ]]; then
        echo "Error: Failed to retrieve raw transaction for TXID: $TXID."
        continue
    fi

    # Extract inputs
    INPUTS=$(echo "$RAW_TX" | jq -c '.vin[]' 2>/dev/null)

    if [[ -z "$INPUTS" ]]; then
        continue
    fi

    # Check if any input references the coinbase transaction
    while IFS= read -r INPUT; do
        CANDIDATE_PREVOUT=$(echo "$INPUT" | jq -r '.txid' 2>/dev/null)
        CANDIDATE_VOUT=$(echo "$INPUT" | jq -r '.vout' 2>/dev/null)

        if [[ "$CANDIDATE_PREVOUT" == "$COINBASE_TXID" && "$CANDIDATE_VOUT" == "$COINBASE_VOUT" ]]; then
            echo "$TXID"
            exit 0
        fi
    done <<< "$INPUTS"
done

echo "No transaction in block 257,343 spends the coinbase output of block 256,128."
exit 1

