# mainnet-dust-generation-scripts
1) update datum json with your 28-byte stake key hash and 33-byte dust public key
2) run mkHashes.sh to create mapping_validator hash and address files
3) edit mkCollateral.sh with proper UTXO to be used for collateral
4) run mkCollateral.sh
5) edit register.sh with created collateral UTXO and another UTXO with enough ADA to cover transaction cost of minting, etc.
6) if signing offline then perform the build-transaction step in register.sh from ONLINE machine and transfer built transaction to OFFLINE machine to sign, then transfer signed TX back
    to ONLINE machine to submit to mainnet node, else run register.sh from ONLINE machine
7) once registraton lands on mainnet then generation starts once that stake key actually moves cNIGHT. Either send cNIGHT to wallet in order to trigger the generation 
    or if cNIGHT already in wallet then perform a self-send (send it to yourself).
8) Dust should begin to get generated roughly 12 hours afterwards 
