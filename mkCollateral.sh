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

NAME="${1:-carl}"

# Network = preprod
#export CARDANO_NODE_NETWORK_ID=1
#export SOCKET_PATH=/ada/preprod/db/node.socket

# Network = mainnet
export CARDANO_NODE_NETWORK_ID=mainnet
export SOCKET_PATH=/ada/mainnet/db/node.socket

UTXO=46600ce8fb556e1008d6f1412e6d998d4a00516e6c4b236a7241a8ddbdf39cd9#0
rm collateral-$NAME.tx 2>/dev/null
rm collateral-$NAME-signed.tx 2>/dev/null

# Build transaction body, fees included
cardano-cli conway transaction build \
  --tx-in $UTXO \
  --tx-out $(< payment-$NAME.addr)+"5000000 lovelace" \
  --change-address $(< payment-$NAME.addr) \
  --socket-path  $SOCKET_PATH \
  --out-file collateral-$NAME.tx

cardano-cli conway transaction sign \
  --tx-file collateral-$NAME.tx \
  --signing-key-file payment-$NAME.skey \
  --out-file collateral-$NAME-signed.tx

cardano-cli conway transaction submit \
  --socket-path  $SOCKET_PATH \
  --tx-file collateral-$NAME-signed.tx

# Save collateral to a file
COLLATERAL=$(cardano-cli conway transaction txid \
  --tx-file collateral-$NAME-signed.tx)"#0"
echo $COLLATERAL > collateral-$NAME.utxo
