#!/bin/bash

RPC_CONNECT="84.247.182.145"
RPC_USER="user_222"
RPC_PASSWORD="oHUfdkZMEmJM"

# Get the block hash of block 123321
BLOCK_HASH=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getblockhash 123321 2>/dev/null)




# Get block data
BLOCK_DATA=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getblock "$BLOCK_HASH" 2>/dev/null)



# Extract all transaction IDs from the block
TXIDS=$(echo "$BLOCK_DATA" | jq -r '.tx[]')

# Loop through each transaction
for TXID in $TXIDS
do
    # Fetch raw transaction details
    RAW_TX=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD getrawtransaction "$TXID" 1 2>/dev/null)



    # Extract outputs from transaction
    OUTPUTS=$(echo "$RAW_TX" | jq -c '.vout[]')

    # Loop through each output
    while read -r OUTPUT; do
        VOUT_INDEX=$(echo "$OUTPUT" | jq -r '.n')

        # Check if this output is unspent
        UNSPENT=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD gettxout "$TXID" "$VOUT_INDEX" 2>/dev/null)

        if [[ -n "$UNSPENT" ]]; then
            ADDRESS=$(echo "$UNSPENT" | jq -r '.scriptPubKey.address')
            if [[ -n "$ADDRESS" ]]; then
                echo "$ADDRESS"
                exit 0
            fi
        fi
    done <<< "$OUTPUTS"

done

echo "No unspent outputs found in block 123321."
exit 1

