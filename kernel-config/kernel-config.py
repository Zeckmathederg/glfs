#!/usr/bin/env python3

# SPDX-License-Identifier: MIT
# Copyright 2023 The LFS Editors

# Stupid script to render "mconf"-style kernel configuration
# Usage: kernel-config.py [path to kernel tree] [needed config].toml
# The toml file should be like:
#   for bool and tristate:
#     EXT4="*"
#     DRM="*M"
#     EXPERT=" "
#     DRM_I915="*M"
#   for choice:
#     HIGHMEM64G="X"
#   an entry with comment:
#     DRM_I915 = { value = " *M", comment = "for i915, crocus, or iris" }

choice_bit = 1 << 30
ind0 = 0
ind1 = 0
menu_id = 1
stack = []
if_stack = []

expand_var_mp = { 'SRCARCH': 'x86' }

def expand_var(s):
    for k in expand_var_mp:
        s = s.replace('$(' + k + ')', expand_var_mp[k])
    return s

def pop_stack(cond):
    global ind0, ind1, stack
    assert(cond(stack[-1][0]))
    s, i0, i1, _ = stack[-1]
    stack = stack[:-1]
    ind0 -= i0
    ind1 -= i1

def pop_stack_while(cond):
    while len(stack) and cond(stack[-1][0]):
        pop_stack(cond)

def cur_menu():
    global stack
    return stack[-1][3] if len(stack) else 0

def cur_if():
    global if_stack
    return if_stack[-1] if len(if_stack) else []

def parse_config(buf):
    global ind0, ind1, stack, menu_id
    is_menu = buf[0].startswith('menu')
    key = buf[0].split()[1].strip()

    deps = ['menu'] + cur_if()
    title = None
    klass = None
    for line in buf[1:]:
        line = line.strip()
        if line.startswith('depends on '):
            new_deps = line[len('depends on '):].split('&&')
            deps += [x.strip() for x in new_deps]
        else:
            for prefix in ['tristate', 'bool', 'string']:
                if line.startswith(prefix + ' '):
                    title = line[len(prefix) + 1:]
                    klass = prefix
                elif line.startswith('def_' + prefix + ' '):
                    klass = prefix
                elif line.startswith('prompt '):
                    title = line[len('prompt '):]

    pop_stack_while(lambda x: x not in deps)

    if key not in known_config:
        return []
    val = known_config[key]
    comment = None
    forced = None

    if type(val) == dict:
        comment = val.get('comment')
        forced = val.get('forced')
        val = val['value']

    assert(title and klass)
    title = title.strip().lstrip('"')
    title = title[:title.find('"')]

    if klass == 'string':
        val = '(' + val + ')'
    else:
        assert((val == 'X') == bool(cur_menu() & choice_bit))
        if (val == 'X'):
            val = '(X)'
        else:
            val = list(val)
            val.sort()
            for c in val:
                if c not in 'M* ' or (c == 'M' and klass != 'tristate'):
                    raise Exception('unknown setting %s for %s' % (c, key))
            bracket = None
            if klass == 'tristate':
                if forced and 'M' not in val:
                    # render this "as-is" a forced bool
                    klass = 'bool'
                else:
                    bracket = '{}' if forced else '<>'

            if klass == 'bool':
                bracket = '--' if forced else '[]'

            if not bracket:
                raise Exception('should not reach here')
            val = bracket[0] + '/'.join(val) + bracket[1]

    arrow = ' --->' if is_menu else ''
    r = [(ind0, val, ind1, title, arrow, key, cur_menu(), comment)]
    menu_id += is_menu
    stack_ent = (key, 2, 0, menu_id) if is_menu else (key, 0, 2, cur_menu())
    ind0 += stack_ent[1]
    ind1 += stack_ent[2]
    stack += [stack_ent]
    return r

def parse_choice(buf):
    global ind0, ind1, stack, menu_id
    assert(buf[0] == 'choice\n')
    title = ''
    for line in buf:
        line = line.strip()
        if line.startswith('prompt '):
            title = line[len('prompt '):].strip().strip('"')
    r = [(ind0, "", ind1, title, ' --->', '', cur_menu(), None)]
    menu_id += 1
    stack += [('menu', 2, 0, menu_id | choice_bit)]
    ind0 += 2
    return r

def load_kconfig(file):
    global ind0, ind1, stack, path, menu_id, if_stack
    r = []
    config_buf = []
    with open(path + file) as f:
        for line in f:
            if len(config_buf):
                if not line.startswith('\t'):
                    if config_buf[0] == 'choice\n':
                        r += parse_choice(config_buf)
                    else:
                        r += parse_config(config_buf)
                    config_buf = []
                else:
                    config_buf += [line]
                    continue
            if line.startswith('source') or line.startswith('\tsource'):
                sub = expand_var(line.strip().split()[1].strip('"'))
                r += load_kconfig(sub)
            elif line.startswith('config') or line.startswith('menuconfig'):
                config_buf = [line]
            elif line.startswith('choice'):
                config_buf = [line]
            elif line.startswith("menu"):
                title = expand_var(line[4:].strip().strip('"'))
                r += [(ind0, "", ind1, title, ' --->', '', cur_menu(), None)]
                menu_id += 1
                stack += [('menu', 2, 0, menu_id)]
                ind0 += 2
            elif line.startswith('endmenu') or line.startswith('endchoice'):
                pop_stack_while(lambda x: x != 'menu')
                pop_stack(lambda x: x == 'menu')
                if r[-1][1] == "":
                    # prune empty menu
                    r = r[:-1]
            elif line.startswith('if '):
                line = line[3:]
                top = cur_if()
                top += [x.strip() for x in line.split("&&")]
                if_stack += [top]
            elif line.startswith('endif'):
                if_stack = if_stack[:-1]
    return r

known_config = {}

from sys import argv
import tomllib

path = argv[1]
if path[-1] != '/':
    path += '/'
with open(argv[2], 'rb') as f:
    known_config = tomllib.load(f)

r = load_kconfig("Kconfig")

# Now we are going to pretty-print r

## Calculate the maximum value length for each menu
max_val_len = {}
for _, val, _, _, _, _, menu, _ in r:
    x = max_val_len[menu] if menu in max_val_len else 0
    max_val_len[menu] = max(x, len(val))

## Output

max_line = 80
buf = []

done = [x[5] for x in r]
for i in known_config:
    if i not in done:
        raise Exception("%s seems not exist" % i)

for i0, val, i1, title, arrow, key, menu, comment in r:
    if val:
        val += (max_val_len[menu] - len(val)) * ' '
    line = i0 * ' ' + val + (i1 + bool(val)) * ' '

    rem = max_line - len(line) - len(arrow)

    if len(title) > rem:
        title = title[:rem - 3] + '...'

    line += title + arrow
    rem = max_line - len(line)

    if key:
        key = ' [' + key + ']'

    if len(key) <= rem:
        line += (rem - len(key)) * ' ' + key
    else:
        key = '... ' + key
        line += '\n' + ' ' * (max_line - len(key)) + key
    if comment:
        line = ' ' * i0 + '# ' + comment + ':\n' + line
    buf += [line.replace('<', '&lt;').replace('>', '&gt;').rstrip()]

import kernel_version
kver = kernel_version.kernel_version(path)

print('''<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE note PUBLIC "-//OASIS//DTD DocBook XML V4.5//EN"
  "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd">''')
print('<!-- Automatically generated by kernel-config.py for Linux', kver)
print('     DO NOT EDIT! -->')
print('<screen><literal>' + '\n'.join(buf) + '</literal></screen>')
