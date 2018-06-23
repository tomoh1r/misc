#! /usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function, unicode_literals

import argparse
import os
import shlex
import subprocess


_ROOT_DIR = os.path.relpath(os.path.dirname(os.path.abspath(__file__)))


class ProvisionCaller(object):
    def __call__(self):
        proc = subprocess.Popen(shlex.split(self.build_cmds()))
        proc.communicate()

    def parse_args(self):
        parser = argparse.ArgumentParser(
            description='Wrapper for ansible-playbook.')
        parser.add_argument(
            '--temp',
            action='store_true',
            help='target to temp host')
        parser.add_argument(
            '--check', '-C',
            action='store_true',
            help='add opts -C to ansible-playbook')
        parser.add_argument(
            '--diff', '-D',
            action='store_true',
            help='add opts -D to ansible-playbook')
        parser.add_argument(
            '--verbose', '-v',
            action='store_true',
            help='verbose output')
        parser.add_argument(
            'tags', nargs='*', help='tags')
        return parser.parse_args()

    def build_cmds(self):
        args = self.parse_args()
        cmds = ['ansible-playbook -K -i {inventory_fpath}']
        if args.check:
            cmds.append('--check')
        if args.diff:
            cmds.append('--diff')
        if args.verbose:
            cmds.append('--verbose')
        cmds.append('-t "{tags}" {playbook_fpath}')
        cmds = ' '.join(cmds)

        return cmds.format(
            inventory_fpath=os.path.join(
                _ROOT_DIR, 'inventories',
                'temp' if args.temp else 'localhost'),
            playbook_fpath=os.path.join(_ROOT_DIR, 'playbook.yml'),
            tags=','.join(args.tags or ['setup']))


if __name__ == '__main__':
    ProvisionCaller()()
