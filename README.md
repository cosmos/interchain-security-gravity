# Gravity Delegations Tool

A convenience tool designed to periodically run delegations for a wallet.
the script can execute via cli or github actions.
Please refer to the `.github/workflows/automation.yml` for details.

### Github actions

Configured to run at 12 noon on every 1st and 15th.

### [Act](https://github.com/nektos/act)

```bash
# Install `act`
brew install act

# arch
yay -S act
```

create .secrets file in repo root
add following variables as secrets in file. e.g.

```bash
...
NODE='https://localhost:26657'
CHAIN_ID=chain-id-1
AUTHZ_PHRASES='key key key'
...
```

run on local:

```bash
act
```

### Development

Follow local setup, run following command to get a live reloading runner

```bash
act -w
```

### Environment Variables

| Key              | Default | Description                                                                                                | Required |
| ---------------- | ------- | ---------------------------------------------------------------------------------------------------------- | -------- |
| SLACK_WEBHOOK_UR |         | Bot webhook url. Refer [slack roles](https://slack.com/help/articles/360018112273-Types-of-roles-in-Slack) | [x]      |
| BINARY           | simd    | binary of undrelying chain                                                                                 | [x]      |
| NODE             |         | address of mainnet node of target chain                                                                    | [x]      |
| DENOM            | stake   | Denomination of chain currency                                                                             | [x]      |
| CHAIN_ID         |         | current chain id of target chain                                                                           | [x]      |
| FROM_ADDRESS     | alice   | the complete address of the wallet holding the tokens                                                      | [x]      |
| AUTHZ_PHRASES    |         | memonic of authz enabled wallet                                                                            | [x]      |
| GRANTEE          | bob     | Human readable authz wallet name as registered on the server                                               | [x]      |
| GRANTER          | alice   | the human readable wallet name as registered on the server                                                 | []       |
| MAX_AMOUNT       |         | if set the delegation amount will be                                                                       | []       |

NOTE: if using github actions please set variables as secrets in settings
the script requires for the `FROM_ADDRESS` to be set or the `GRANTER` to be passed. Future update would extend the same functionality to `AUTHZ_PHRASES` and `GRANTEE`
if MAX_AMOUNT is not set the total amount held by the granter will get delegated

### Executables

Make sure the file is executable

```bash
chmod +x gen.py
```

Make sure the delegation script is executable

```bash
chmod +x delegate.sh
```

### Prerequisites

- Ensure a list of validators can be found at the root dir named `validators.json`
- In order to allow for smooth functioning of this script an authz GRANTEE needs to be configured

This key requires the following permissions

- MsgDelegation

```bash
$BINARY tx authz grant $($BINARY keys show $GRANTEE -a) generic --msg-type=/cosmos.gov.v1beta1.MsgDelegation --from $GRANTER --fees 200$DENOM
```

- MsgWithdrawAll

```bash
$BINARY tx authz grant $($BINARY keys show $GRANTEE -a) generic --msg-type=/cosmos.gov.v1beta1.MsgWithdrawAll --from $GRANTER --fees 200$DENOM
```

### Github actions

The script executes at a fixed interval via github actions refer `.github/workflows/automation.yml`

### Manual Configuration

#### Running the delegation script

Use the command as follows:

```bash
./delegate.sh
```

The script should withdraw all rewards for the GRANTER
Divide the current balance of the Delegator by the number of validators they plan to delegate to
Generate the message for this TX
Make an authz tx sing the GRANTEE to sign the transaction

#### Running python script

NOTE `delegate.sh` is a wrapper for gen.py, thus if you use it there is no need to run the script directly

```bash
python3 gen.py
```

For help try the `--help` flag:

```bash
> python3 gen.py --help
usage: gen.py [-h] [--amount AMOUNT] [--from-address FROM_ADDRESS] [--output-file OUTPUT_FILE]

Delegate to Cosmos Hub validators

optional arguments:
  -h, --help            show this help message and exit
  --amount AMOUNT       Amount to delegate to each
  --from-address FROM_ADDRESS*
                        Address to send grav from (default new-new-bom)
  --output-file OUTPUT_FILE
                        Filename to write
```

Default values for the flags are as follows:

- `--amount` = 1
- `--from-address` = `gravity1zk4uwzygs4k2k5cz7y759sxcnv6qt3pd4g3pqq` (new-new-bom)
- `--output-file` = today's date in format `%d-%m-%Y/unsigned.json`

Examples:

```bash
python gen.py --amount 1000000000000
python gen.py --amount 1000000000000 --from $(gravity keys show new-new-bom -a)
python gen.py --amount 1000000000000 --output-file output/unsigned.json
```
