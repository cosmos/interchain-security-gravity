#!/bin/bash

# TODO gravity does not use config command use `--output json` flag for all commands where required

# env vars
GRANTER=${GRANTER:-alice}
GRANTEE=${GRANTEE:-bob}
BINARY=${BINARY:-simd}
DENOM=${DENOM:-stake}
MAX_AMOUNT=${MAX_AMOUNT}

FROM_ADDRESS=$($BINARY keys show $GRANTER -a) # delegator address
echo From Address $FROM_ADDRESS
# add user to keyring

# withdraw rewards for delegator if exists
$BINARY tx distribution withdraw-all-rewards --from $GRANTER -y

# get account balance
BALANCE=$($BINARY q bank balances $FROM_ADDRESS --output json | jq --arg DENOM $DENOM -r '.balances | map(select(.denom==$DENOM))[0].amount')
echo "Balance: $BALANCE"

# get total validators
TOTALVALS=$(jq '.validators | length' validators.json)
echo "Totalvals: $TOTALVALS"

DELEGATION_AMOUNT=$(($BALANCE / $TOTALVALS))
echo Delegation Amount: $DELEGATION_AMOUNT

if [[ ! -z $MAX_AMOUNT ]] && [[ $DELEGATION_AMOUNT > $MAX_AMOUNT ]]; then
	DELEGATION_AMOUNT=$MAX_AMOUNT
fi

# generate validators final json using py script
python3 gen.py --denom $DENOM --amount $DELEGATION_AMOUNT --output-file output/unsigned.json --from-address $FROM_ADDRESS

echo Validators to be \(re\)staked
jq '.validators' output/unsigned.json

# run authz tx commands for doing delegation
# execute the output of gen.py as a payload for authz tx
echo executing authz from grantee account: $GRANTEE
$BINARY tx authz exec output/unsigned.json --from $GRANTEE --fees 200$DENOM --fee-account $FROM_ADDRESS -y
