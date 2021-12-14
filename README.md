# Gravity Delegations Tool
Make sure the file is executable
```bash
chmod +x gen.py
```
Use the command as follows:
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
* `--amount` = 1
* `--from-address` = `gravity1zk4uwzygs4k2k5cz7y759sxcnv6qt3pd4g3pqq` (new-new-bom)
* `--output-file` = today's date in format `%d-%m-%Y/unsigned.json`

Examples:
```bash
python gen.py --amount 1000000000000
python gen.py --amount 1000000000000 --from $(gravity keys show new-new-bom -a)
python gen.py --amount 1000000000000 --output-file output/unsigned.json
```

