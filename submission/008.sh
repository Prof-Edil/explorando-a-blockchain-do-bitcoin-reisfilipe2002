#!/bin/bash

RPC_CONNECT="84.247.182.145"
RPC_USER="user_222"
RPC_PASSWORD="oHUfdkZMEmJM"

TXID="e5969add849689854ac7f28e45628b89f7454b83e9699e551ce14b6f90c86163"

# Retrieve the raw transaction in decoded format
TRANSACTION=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getrawtransaction "$TXID" 1 2>/dev/null)

if [[ -z "$TRANSACTION" ]]; then
    echo "Error: Failed to retrieve transaction details for TXID: $TXID."
    exit 1
fi

# Extract input 0
INPUT=$(echo "$TRANSACTION" | jq -c ".vin[0]")

if [[ -z "$INPUT" || "$INPUT" == "null" ]]; then
    echo "Error: No input 0 found in transaction $TXID."
    exit 1
fi

# Check if the transaction is SegWit (witness data exists)
WITNESS=$(echo "$INPUT" | jq -c '.txinwitness // empty')

if [[ -n "$WITNESS" && "$WITNESS" != "null" ]]; then
    # Extract the last element from the witness array (assumed to be the public key)
    PUBKEY=$(echo "$WITNESS" | jq -r '.[2][4:70] // empty')
else
    # Extract scriptSig for non-SegWit transactions
    SCRIPT_SIG=$(echo "$INPUT" | jq -r '.scriptSig.asm // empty')

    if [[ -z "$SCRIPT_SIG" || "$SCRIPT_SIG" == "null" ]]; then
        echo "Error: No scriptSig or witness data found for input 0."
        exit 1
    fi

    # The public key is usually the last element in scriptSig
    PUBKEY=$(echo "$SCRIPT_SIG" | awk '{print $NF}')
fi

# Validate extracted public key
if [[ -n "$PUBKEY" && "$PUBKEY" != "null" && "$PUBKEY" != "01" ]]; then
    echo "$PUBKEY"
else
    echo "Error: Could not extract a valid public key from input 0."
    exit 1
fi
