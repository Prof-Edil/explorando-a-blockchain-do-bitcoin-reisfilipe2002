#!/bin/bash

# RPC connection details
RPC_CONNECT="84.247.182.145"
RPC_USER="user_222"
RPC_PASSWORD="oHUfdkZMEmJM"
# Extended Public Key (XPUB)
XPUB="xpub6Cx5tvq6nACSLJdra1A6WjqTo1SgeUZRFqsX5ysEtVBMwhCCRa4kfgFqaT2o1kwL3esB1PsYr3CUdfRZYfLHJunNWUABKftK2NjHUtzDms2"

# Get descriptor checksum
DESCRIPTOR_CHECKSUM=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD  getdescriptorinfo "tr($XPUB/100)" | jq -r '.descriptor')

# Get derived Taproot address
ADDRESS=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD deriveaddresses "$DESCRIPTOR_CHECKSUM" | jq -r '.[0]')

# Output the Taproot address
echo "$ADDRESS"
