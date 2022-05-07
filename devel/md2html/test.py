#!/usr/bin/env python3

import re

line="3. Ściągamy z `snap` najnowsze `LXD`"

if re.search('\`', line):
	match_count=0
	while re.search('\`', line):
		if match_count % 2 == 0:
			line = line.replace('`', '<code>', 1)
		else:
			line = line.replace('`', '</code>', 1)
		match_count += 1
			
print(f"{line}")
