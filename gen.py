#!/usr/bin/env python3

import json
import os
import errno
import argparse
from datetime import datetime
from pathlib import Path

now = datetime.now() # current date and time

parser = argparse.ArgumentParser(description = 'Delegate to Cosmos Hub validators')
# parser.add_argument('month', type = int, nargs = 1, help = 'Month to create transaction for')
parser.add_argument('--amount', type = int, default = 1, help = 'Amount to delegate to each')
parser.add_argument('--from-address', type = str, default = 'gravity1zk4uwzygs4k2k5cz7y759sxcnv6qt3pd4g3pqq', help = 'Address to send grav from (default new-new-bom)')
parser.add_argument('--output-file', type = str, default = now.strftime("%d-%m-%Y/unsigned") + '.json', help = 'Filename to write')
args = parser.parse_args()
# month = args.month[0]
# months = {
#   'jan': 0,
#   'january': 0,
#   '1': 0,
#   'feb': 1,
#   'february': 1,
#   '2': 1,
#   'mar': 2,
#   'march': 2,
#   '3': 2,
# }
# offset = args.month_offset
# index = month - offset - 1
from_address = args.from_address


data = json.load(open('validators.json'))


msgs = []

validators = data['validators']
for val in validators:
    name = list(val.keys())[0]

    try:

      val = val[name]
      print('validator {}'.format(name))
      print('address {}'.format(val))
      # addr = list(val.keys())[0]
      # if addr == '' or val == '':
      #   raise IndexError()


      # amount = val[addr]
      # if "uatom" not in amount: 
      #   raise ValueError('valoyee {} has INVALID token amount {}'.format(name, amount))
      # amountInAtom = (float(amount.replace("uatom", "")) / 1_000_000) 
      # print('Sending {} to {} at address (vesting)'.format(amountInAtom, name, addr))
      # amt_amt = amount[:-5]
      # amt_dnm = amount[-5:]
      msg = {
          "@type": "/cosmos.staking.v1beta1.MsgDelegate",
          "delegator_address": "gravity1zk4uwzygs4k2k5cz7y759sxcnv6qt3pd4g3pqq", # new-new-bom
          "validator_address": val,
          'amount': {
            'denom': 'ugraviton',
            'amount': str(args.amount)
          }
      }
      msgs.append(msg)
    except ValueError as err:
      print('{}'.format(err))
    except:
      print('{}'.format(val))

final = {
  'body': {
    'messages': msgs,
    'memo': '',
    'timeout_height': '0',
    'extension_options': [],
    'non_critical_extension_options': []
  },
  'auth_info': {
    'signer_infos': [],
    'fee': {
      'amount': [],
      'gas_limit': '2000000',
      'payer': '',
      'granter': ''
    }
  },
  'signatures': []
}

if not os.path.exists(os.path.dirname(args.output_file)):
    try:
        os.makedirs(os.path.dirname(args.output_file))
    except OSError as exc: # Guard against race condition
        if exc.errno != errno.EEXIST:
            raise

open(args.output_file, 'w').write(json.dumps(final))