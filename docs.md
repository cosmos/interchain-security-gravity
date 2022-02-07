# Scripts for managing grav tokens

## Authz

We need to use authz with our multisig accounts so that we don't compromoise the security of our accounts while still being able to automate functions around delegations and redelegations.

First we need to provide authorization from the following two accounts:
```bash
Community Pool
  address: gravity1c4t4aqe74yyz624dm44u6xhfz9p8rx4f90jxjl
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"ApXjgNBcgMxFfjbdQK3EO3p1KbOCbSKqSvBsffAxxXrX"}'
> gravity q bank balances gravity1c4t4aqe74yyz624dm44u6xhfz9p8rx4f90jxjl  --node https://gravitychain.io:26657
balances:
- amount: "110000000000000"
  denom: ugraviton

ICF Multisig
  address: gravity1zk4uwzygs4k2k5cz7y759sxcnv6qt3pd4g3pqq
  pubkey: '{"@type":"/cosmos.crypto.multisig.LegacyAminoPubKey","threshold":2,"public_keys":[{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AkxVt5r4fB3UTVbJ4TISdYbM5pNNvlpvCBpBQqiMpgd0"},{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AgdeV0yd7E99TJiyZnXSSrr0bKhZh3oQD8ILkXKC6cSO"},{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"ApXjgNBcgMxFfjbdQK3EO3p1KbOCbSKqSvBsffAxxXrX"}]}'
> gravity q bank balances gravity1zk4uwzygs4k2k5cz7y759sxcnv6qt3pd4g3pqq  --node https://gravitychain.io:26657
balances:
- amount: "54882881411600"
  denom: ugraviton
```

The messages we need to authorize are as follows:
```
    /cosmos.staking.v1beta1.MsgDelegate
    /cosmos.staking.v1beta1.MsgBeginRedelegate
```

I've created a new bot account `gravity13l3ayc20q3vg9ncez3je9jp5dnqkwyew6436v8`. The mnemonic is in 1password to be shared by relevant parties. 

The commands to grant authorization to this account for the `Community Pool` account are simple enough because it is a single key singer and are as follows:
```
gravity tx authz grant gravity13l3ayc20q3vg9ncez3je9jp5dnqkwyew6436v8 generic --msg-type /cosmos.staking.v1beta1.MsgDelegate --from gravity1c4t4aqe74yyz624dm44u6xhfz9p8rx4f90jxjl --node https://gravitychain.io:26657 --chain-id gravity-bridge-3


gravity tx authz grant gravity13l3ayc20q3vg9ncez3je9jp5dnqkwyew6436v8 generic --msg-type /cosmos.staking.v1beta1.MsgBeginRedelegate --from gravity1c4t4aqe74yyz624dm44u6xhfz9p8rx4f90jxjl --node https://gravitychain.io:26657 --chain-id gravity-bridge-3

```
The commands for the `ICF Multisig` are more complicated because these need to be signed by multiple parties:
```
gravity tx authz grant gravity13l3ayc20q3vg9ncez3je9jp5dnqkwyew6436v8 generic --msg-type /cosmos.staking.v1beta1.MsgDelegate --from gravity1zk4uwzygs4k2k5cz7y759sxcnv6qt3pd4g3pqq --node https://gravitychain.io:26657 --chain-id gravity-bridge-3 --generate-only > unsigned-delegate-authz.json


gravity tx authz grant gravity13l3ayc20q3vg9ncez3je9jp5dnqkwyew6436v8 generic --msg-type /cosmos.staking.v1beta1.MsgBeginRedelegate --from gravity1zk4uwzygs4k2k5cz7y759sxcnv6qt3pd4g3pqq --node https://gravitychain.io:26657 --chain-id gravity-bridge-3--generate-only > unsigned-redelegate-authz.json
```





