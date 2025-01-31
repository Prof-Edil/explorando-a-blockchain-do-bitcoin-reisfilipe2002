#!/bin/bash

# RPC connection details

# Extended Public Key (XPUB)
XPUB="xpub6Cx5tvq6nACSLJdra1A6WjqTo1SgeUZRFqsX5ysEtVBMwhCCRa4kfgFqaT2o1kwL3esB1PsYr3CUdfRZYfLHJunNWUABKftK2NjHUtzDms2"

# Derivation path for index 100 (BIP-86 Taproot standard)
DERIVATION_PATH="/100"

# Descriptor for Taproot (BIP-86)
DESCRIPTOR="tr($XPUB/$DERIVATION_PATH)"

# Get descriptor checksum
DESCRIPTOR_CHECKSUM=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD  getdescriptorinfo "$DESCRIPTOR" | jq -r '.descriptor')

# Get derived Taproot address
ADDRESS=$(bitcoin-cli -rpcconnect=$RPC_CONNECT -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD deriveaddresses "$DESCRIPTOR_CHECKSUM" | jq -r '.[0]')

# Output the Taproot address
echo "$ADDRESS"
