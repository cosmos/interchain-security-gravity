#!/bin/bash
# generate validators final json using py script

# run authz tx commands for doing delegation
# execute the output of gen.py as a payload for authz tx

# redelegation for the same validators (0.45 version does not auto adjust delegations) redelegation.sh

# gravity does not use config command use `--output json` flag for all commands where required

GRANTEE=bob
BINARY=simd
DENOM=stake
#USER=alice
# MEMONIC="plunge hundred health electric victory foil marine elite shiver tonight away verify vacuum giant pencil ocean nest pledge okay endless try spirit special start"
USER=alice
MEMONIC="shuffle oppose diagram wire rubber apart blame entire thought firm carry swim old head police panther lyrics road must silly sting dirt hard organ"
CHAIN_ID=toka-test

# TODO add condition to check if user exists then create
# add user if not exists
# echo $MEMONIC | $BINARY keys add $GRANTEE --recover

FROM_ADDRESS=$($BINARY keys show $USER -a) # delegator address
echo From Address $FROM_ADDRESS

# add user to keyring

# withdraw rewards for delegator if exists
# TODO check if this errors out if nothing is staked for the first time
# best would be to create new delegator and try from that account
$BINARY tx distribution withdraw-all-rewards --from $USER -y

# get account balance
BALANCE=$($BINARY q bank balances $FROM_ADDRESS --output json | jq --arg DENOM $DENOM -r '.balances | map(select(.denom==$DENOM))[0].amount')
echo "Balance: $BALANCE"

# get total validators
TOTALVALS=$(jq '.validators | length' validators.json)
echo "Totalvals: $TOTALVALS"

DELEGATION_AMOUNT=$(($BALANCE / $TOTALVALS))
echo Delegation Amount: $DELEGATION_AMOUNT

python3 gen.py --denom $DENOM --amount $DELEGATION_AMOUNT --output-file output/unsigned.json --from-address $FROM_ADDRESS

echo Validators to be \(re\)staked
jq '.validators' output/unsigned.json

# sign the tx generated by gen.py
echo executing authz from grantee account: $GRANTEE
$BINARY tx authz exec output/unsigned.json --from $GRANTEE
