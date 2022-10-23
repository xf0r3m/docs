#!/usr/bin/env python3

import json

username = 'xf0r3m'

with open('filename.json', 'w') as f:
  json.dump(username,f)

with open('filename.json') as f:
  username = json.load(f)

print(username)
