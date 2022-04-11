#!/bin/bash

# env vars
GRANTER=${GRANTER:-alice}
GRANTEE=${GRANTEE:-bob}
BINARY=${BINARY:-simd}
DENOM=${DENOM:-stake}
NODE=${NODE:-'http://localhost:26657'}
CHAIN_ID=${CHAIN_ID:-test-chain-id}
DEFAULT_FLAGS='--chain-id '$CHAIN_ID' --node '$NODE

if [[ -z $FROM_ADDRESS ]]; then
	FROM_ADDRESS=$("$BINARY" keys show "$GRANTER" -a --node "$NODE") # delegator address
fi

echo From Address "$FROM_ADDRESS"

# withdraw rewards for delegator if exists
"$BINARY" tx distribution withdraw-all-rewards --from "$FROM_ADDRESS" --generate-only "$DEFAULT_FLAGS" >./output/withdraw.json
"$BINARY" tx authz exec output/withdraw.json --from "$GRANTEE" --fees 0"$DENOM" "$DEFAULT_FLAGS" --keyring-backend test -y

# get account balance
BALANCE=$("$BINARY" q bank balances "$FROM_ADDRESS" --output json "$DEFAULT_FLAGS" | jq --arg DENOM "$DENOM" -r '.balances | map(select(.denom==$DENOM))[0].amount')
echo "Balance: $BALANCE"

# get total validators
TOTALVALS=$(jq '.validators | length' validators.json)
echo "Totalvals: $TOTALVALS"

DELEGATION_AMOUNT=$("$BALANCE" / "$TOTALVALS")
echo Delegation Amount: "$DELEGATION_AMOUNT"

if [[ -n $MAX_AMOUNT ]] && [[ $DELEGATION_AMOUNT > $MAX_AMOUNT ]]; then
	DELEGATION_AMOUNT=$MAX_AMOUNT
	echo DELEGATION_AMOUNT after MAX_AMOUNT check: "$DELEGATION_AMOUNT"
fi

# generate validators final json using py script
python3 gen.py --denom "$DENOM" --amount "$DELEGATION_AMOUNT" --output-file output/unsigned.json --from-address "$FROM_ADDRESS"

echo Validators to be \(re\)staked
jq '.validators' output/unsigned.json

# run authz tx commands for doing delegation
# execute the output of gen.py as a payload for authz tx
echo executing authz from grantee account: "$GRANTEE"
"$BINARY" tx authz exec output/unsigned.json --from "$GRANTEE" --gas 2000000 --fees 0"$DENOM" "$DEFAULT_FLAGS" --keyring-backend test -y
