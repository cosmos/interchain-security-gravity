#!/bin/bash

# env vars
GRANTER=${GRANTER:-alice}
GRANTEE=${GRANTEE:-bob}
BINARY=${BINARY:-simd}
DENOM=${DENOM:-stake}
NODE=${NODE:-'http://localhost:26657'}
CHAIN_ID=${CHAIN_ID:-test-chain-id}
NODE='--node='"$NODE"
CHAIN_ID='--chain-id='"$CHAIN_ID"

if [[ -z $FROM_ADDRESS ]]; then
	FROM_ADDRESS=$("$BINARY" keys show "$GRANTER" -a "$NODE" --keyring-backend test) # delegator address
fi

echo From Address "$FROM_ADDRESS"

# withdraw rewards for delegator if exists
"$BINARY" tx distribution withdraw-all-rewards "$NODE" "$CHAIN_ID" --keyring-backend test --from "$FROM_ADDRESS" --generate-only >./output/withdraw.json
"$BINARY" tx authz exec output/withdraw.json --from "$GRANTEE" --gas 5000000 --fees 0"$DENOM" "$NODE" "$CHAIN_ID" --keyring-backend test -y

echo "Sleeping so as to allow withdrawal tx to be confirmed"
sleep 60

# get account balance
BALANCE=$("$BINARY" q bank balances "$FROM_ADDRESS" --output json "$CHAIN_ID" "$NODE" | jq --arg DENOM "$DENOM" -r '.balances | map(select(.denom==$DENOM))[0].amount')
echo "Balance: $BALANCE"

# get total validators
TOTALVALS=$(jq '.validators | length' validators.json)
echo "Totalvals: $TOTALVALS"

DELEGATION_AMOUNT=$((BALANCE / TOTALVALS))
echo Delegation Amount: "$DELEGATION_AMOUNT"

if [[ $MAX_AMOUNT ]] && [[ $DELEGATION_AMOUNT > $MAX_AMOUNT ]]; then
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
"$BINARY" tx authz exec output/unsigned.json --from "$GRANTEE" --gas 5000000 --fees 0"$DENOM" "$NODE" "$CHAIN_ID" --keyring-backend test -y
