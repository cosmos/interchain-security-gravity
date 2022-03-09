#!/bin/bash

# importing env vars for delegation
# TODO create another env file and source it on another run so that we can delegate via 2 wallets using authz
source ./env.sh

echo $FROM_ADDRESS

# env vars
GRANTER=${GRANTER:-alice}
GRANTEE=${GRANTEE:-bob}
BINARY=${BINARY:-simd}
DENOM=${DENOM:-stake}
MAX_AMOUNT=${MAX_AMOUNT}
FROM_ADDRESS=${FROM_ADDRESS}
DEFAULT_FLAGS='--chain-id gravity-bridge-3 --node https://gravitychain.io:26657'

if [[ -z $FROM_ADDRESS ]]; then
	FROM_ADDRESS=$($BINARY keys show $GRANTER -a $DEFAULT_FLAGS) # delegator address
fi

echo From Address $FROM_ADDRESS

# withdraw rewards for delegator if exists
$BINARY tx distribution withdraw-all-rewards --from $FROM_ADDRESS --generate-only $DEFAULT_FLAGS >./output/withdraw.json
$BINARY tx authz exec output/withdraw.json --from $GRANTEE --fees 0$DENOM $DEFAULT_FLAGS --keyring-backend test -y

# get account balance
BALANCE=$($BINARY q bank balances $FROM_ADDRESS --output json $DEFAULT_FLAGS | jq --arg DENOM $DENOM -r '.balances | map(select(.denom==$DENOM))[0].amount')
echo "Balance: $BALANCE"

# get total validators
TOTALVALS=$(jq '.validators | length' validators.json)
echo "Totalvals: $TOTALVALS"

DELEGATION_AMOUNT=$(($BALANCE / $TOTALVALS))
echo Delegation Amount: $DELEGATION_AMOUNT

if [[ ! -z $MAX_AMOUNT ]] && [[ $DELEGATION_AMOUNT > $MAX_AMOUNT ]]; then
	DELEGATION_AMOUNT=$MAX_AMOUNT
	echo DELEGATION_AMOUNT after MAX_AMOUNT check: $DELEGATION_AMOUNT
fi

# generate validators final json using py script
python3 gen.py --denom $DENOM --amount $DELEGATION_AMOUNT --output-file output/unsigned.json --from-address $FROM_ADDRESS

echo Validators to be \(re\)staked
jq '.validators' output/unsigned.json

# run authz tx commands for doing delegation
# execute the output of gen.py as a payload for authz tx
echo executing authz from grantee account: $GRANTEE
$BINARY tx authz exec output/unsigned.json --from $GRANTEE --gas auto --fees 0$DENOM $DEFAULT_FLAGS --keyring-backend test -y
