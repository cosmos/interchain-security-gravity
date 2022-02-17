#!/bin/bash
# generate validators final json using py script

# run authz tx commands for doing delegation
# execute the output of gen.py as a payload for authz tx

# redelegation for the same validators (0.45 version does not auto adjust delegations) redelegation.sh


# gravity does not use config command use `--output json` flag for all commands where required

BINARY=simd
DENOM=stake
USER=alice
# get account balance
BALANCE=$($BINARY q bank balances $($BINARY keys show $USER -a) --output json | jq --arg DENOM $DENOM -r '.balances | map(select(.denom==$DENOM))[0].amount')
echo "Balance: $BALANCE"

# get total validators
TOTALVALS=$(jq '.validators | length' validators.json)
echo "TOTALVALS: $TOTALVALS"

DELEGATION_AMOUNT=$(($BALANCE/$TOTALVALS))
echo "DELEGATION_AMOUNT: $DELEGATION_AMOUNT"
