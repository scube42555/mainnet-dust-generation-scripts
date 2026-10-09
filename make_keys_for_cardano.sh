#!/bin/sh
# Network = testnet
#export CARDANO_NODE_NETWORK_ID=1

# Network = mainnet
export CARDANO_NODE_NETWORK_ID=mainnet

# pass name to create keys for (e.g. "carl" or "bob")

NAME="${1:-NAME}"

mkdir $NAME-keys
echo '24 word mnemonic ... ' > ./$NAME-keys/phrase-$NAME.prv
echo '<passphrase goes here, if no passphrase then leave this blank but still echo it>' >> ./$NAME-keys/phrase-$NAME.prv
cardano-wallet key from-recovery-phrase Shelley --passphrase from-utf8 --sensitive < ./$NAME-keys/phrase-$NAME.prv > ./$NAME-keys/root-$NAME.xsk
cat ./$NAME-keys/root-$NAME.xsk | cardano-wallet key child 1852H/1815H/0H/0/0 > ./$NAME-keys/payment-$NAME.prv
cat ./$NAME-keys/root-$NAME.xsk | cardano-wallet key child 1852H/1815H/0H/2/0 > ./$NAME-keys/stake-$NAME.prv
cardano-cli key convert-cardano-address-key --signing-key-file ./$NAME-keys/payment-$NAME.prv --shelley-payment-key --out-file ./$NAME-keys/payment-$NAME.skey
cardano-cli key convert-cardano-address-key --signing-key-file ./$NAME-keys/stake-$NAME.prv --shelley-stake-key --out-file ./$NAME-keys/stake-$NAME.skey
cardano-cli key verification-key --signing-key-file ./$NAME-keys/payment-$NAME.skey --verification-key-file ./$NAME-keys/Ext_ShelleyPay-$NAME.vkey
cardano-cli key verification-key --signing-key-file ./$NAME-keys/stake-$NAME.skey --verification-key-file ./$NAME-keys/Ext_ShelleyStake-$NAME.vkey
cardano-cli key non-extended-key --extended-verification-key-file ./$NAME-keys/Ext_ShelleyPay-$NAME.vkey --verification-key-file ./$NAME-keys/payment-$NAME.vkey
cardano-cli key non-extended-key --extended-verification-key-file ./$NAME-keys/Ext_ShelleyStake-$NAME.vkey --verification-key-file ./$NAME-keys/stake-$NAME.vkey
cardano-cli conway address build \
  --payment-verification-key-file ./$NAME-keys/payment-$NAME.vkey \
  --stake-verification-key-file ./$NAME-keys/stake-$NAME.vkey \
  --out-file ./$NAME-keys/payment-$NAME.addr
cardano-cli conway stake-address build \
  --stake-verification-key-file ./$NAME-keys/stake-$NAME.vkey \
  --out-file ./$NAME-keys/stake-$NAME.addr
