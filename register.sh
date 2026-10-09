#!/usr/bin/env bash

# This file is part of midnight-node.
# Copyright (C) Midnight Foundation
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Network = testnet
#export CARDANO_NODE_NETWORK_ID=1
#export SOCKET_PATH=/ada/preprod/db/node.socket

# Network = mainnet
export CARDANO_NODE_NETWORK_ID=mainnet
export SOCKET_PATH=/ada/mainnet/db/node.socket

# pass "carl" or "bob" as parameter to this script
NAME="${1:-carl}"

# Get the collateral UTxO. This should be entered manually
COLLATERAL=1a972d6ad9a1b101e6438522b3b29ec28b2344e4a942b4c17a88737ff50c682a#0
# Pick the first UTxO on the wallet that is not a collateral. This should be entered manually
UTXO=1a972d6ad9a1b101e6438522b3b29ec28b2344e4a942b4c17a88737ff50c682a#1
USER_PKH=$(cardano-cli address key-hash --payment-verification-key-file stake-$NAME.vkey)

rm register-$NAME.tx 2>/dev/null
rm register-$NAME-signed.tx 2>/dev/null

# Build transaction body, fees included
cardano-cli conway transaction build \
  --tx-in $UTXO \
  --tx-out $(< mapping_validator.addr)+"2000000 lovelace + 1 $(< mapping_validator.hash)" \
  --tx-out-inline-datum-file datum-$NAME.json \
  --tx-in-collateral $COLLATERAL \
  --mint="1 $(< mapping_validator.hash)" \
  --mint-script-file mapping_validator.plutus \
  --mint-redeemer-file register_red.json  \
  --change-address $(< payment-$NAME.addr) \
  --required-signer-hash $USER_PKH \
  --socket-path  $SOCKET_PATH \
  --out-file register-$NAME.tx

# Sign and submit
cardano-cli conway transaction sign \
  --tx-file register-$NAME.tx \
  --signing-key-file payment-$NAME.skey \
  --signing-key-file stake-$NAME.skey \
  --out-file register-$NAME-signed.tx

cardano-cli conway transaction submit \
  --socket-path  $SOCKET_PATH \
  --tx-file register-$NAME-signed.tx

# Print hash of submitted transaction
cardano-cli conway transaction txid \
  --tx-file register-$NAME-signed.tx > > register-$NAME-signed-tx.hash
