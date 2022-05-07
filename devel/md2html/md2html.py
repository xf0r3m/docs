#!/usr/bin/env python3

import argparse
import re

parser = argparse.ArgumentParser(description='Podaj ścieżkę do pliku')
parser.add_argument('path', metavar='/home/example/file.md', help='Ścieżka do pliku MD')

args = parser.parse_args()
filepath = args.path

newfile = []

def conv(line,old,new,close_mark):
	line = line.replace(old, new)
	l = f"{line}{close_mark}"
	return l
	
code_block_marker = 0

#zagnieżdzanie znaczników

with open(filepath) as f:
	for line in f:
		if (len(newfile) > 0) and (newfile[-1] == '<code>'):
			print('Dodaje linie 1')
			newfile.append(line)
		else:
			if (len(newfile) > 0) and (code_block_marker % 2 == 1):
				
				if re.search('\`\`\`$', line):
					if code_block_marker % 2 == 0:
						newfile.append(line.replace('```', '<code>'))
					else:
						newfile.append(line.replace('```', '</code>'))
				
					code_block_marker += 1
				else:
					newfile.append(line)
			else:
				
				line = line.rstrip()
				if line.find("######") >= 0:
					newfile.append(conv(line,'######','<h6>','</h6>'))
				elif line.find("#####") >= 0:
					newfile.append(conv(line,'#####','<h5>','</h5>'))
				elif line.find("####") >= 0:
					newfile.append(conv(line,'####','<h4>','</h4>'))
				elif line.find("###") >= 0:
					newfile.append(conv(line,'###','<h3>','</h3>'))
				elif line.find("##") >= 0:
					newfile.append(conv(line,'##','<h2>','</h2>'))
				elif line.find("#") >= 0:
					newfile.append(conv(line,'#','<h1>','</h1>'))
				elif line.find("**") >= 0:
					l = line[2:-2]
					newfile.append(f"<strong>{l}</strong>")
				elif re.search('\*.*\*', line):
					l = line[1:-1]
					newfile.append(f"<em>{l}</em>")
				elif line.find("__") >= 0:
					l = line[2:-2]
					newfile.append(f"<em>{l}</em>")
				elif re.search('\!\[.*\]', line):
					image_title_part = re.search('\!\[.*\]', line)
					image_title = line[(image_title_part.span(0)[0] + 2):(image_title_part.span(0)[1] - 1)]
					image_url_part = re.search('\(.*\)', line)
					image_url = line[(image_url_part.span(0)[0] + 1):(image_url_part.span(0)[1] - 1)]
					newfile.append(f'<img src="{image_url}" title="{image_title}" />')
				elif re.search('\[.*\]\(.*\)', line):
					m = re.search('\[.*\]\(.*\)', line);
					link_name_part = re.search('\[.*\]', line)
					link_name = line[(link_name_part.span(0)[0] + 1):(link_name_part.span(0)[1] - 1)]
					link_url_part = re.search('\(.*\)', line)
					link_url = line[(link_url_part.span(0)[0] + 1):(link_url_part.span(0)[1] - 1)]
					line = line.replace(m.group(), f'<a href="{link_url}">{link_name}</a>')
					newfile.append(line)
				elif line.find('> ') >= 0:
					newfile.append(conv(line,'> ','<blockquote>','</blockquote>'))
				elif re.search('\`\`\`$', line):
					if code_block_marker % 2 == 0:
						newfile.append(line.replace('```', '<code>'))
					else:
						newfile.append(line.replace('```', '</code>'))
				
					code_block_marker += 1
				elif re.search('\`.*\`', line):
					match_count=0
					while re.search('\`', line):
						if match_count % 2 == 0:
							line = line.replace('`', '<code>', 1)
						else:
							line = line.replace('`', '</code>', 1)
						match_count += 1
					newfile.append(line)
				else:
					print('Dodaje linie 3')
					newfile.append(line)
				
			
	

#newfile.reverse()

with open('file.html', 'w') as f:
	for newline in newfile:
		f.write(f"{newline}\n")
