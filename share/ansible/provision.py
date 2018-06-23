#! /usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function, unicode_literals

import argparse
import os
import shlex
import subprocess


_ROOT_DIR = os.path.dirname(os.path.abspath(__file__))


class ProvisionCaller(object):
    def __call__(self):
        proc = subprocess.Popen(
            shlex.split(self.build_cmds()),
            cwd=_ROOT_DIR)
        proc.communicate()

    def parse_args(self):
        parser = argparse.ArgumentParser(
            description='Wrapper for ansible-playbook.')
        parser.add_argument(
            '--check', '-C',
            action='store_true',
            help='add opts -C to ansible-playbook')
        parser.add_argument(
            '--diff', '-D',
            action='store_true',
            help='add opts -D to ansible-playbook')
        parser.add_argument(
            '--limit', '-l',
            default='localhost',
            help='further limit selected hosts to an additional pattern')
        parser.add_argument(
            '--verbose', '-v',
            action='store_true',
            help='verbose output')
        parser.add_argument(
            'tags', nargs='*', help='tags')
        return parser.parse_args()

    def build_cmds(self):
        args = self.parse_args()
        cmds = ['ansible-playbook']
        if args.check:
            cmds.append('--check')
        if args.diff:
            cmds.append('--diff')
        cmds.append('--inventory=hosts')
        cmds.append('--limit="{}"'.format(args.limit))
        cmds.append('--tags="{}"'.format(','.join(args.tags or ['setup'])))
        if args.verbose:
            cmds.append('--verbose')
        cmds.append('--ask-become-pass playbook.yml')
        return ' '.join(cmds)


if __name__ == '__main__':
    ProvisionCaller()()
