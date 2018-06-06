#! /usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function, unicode_literals

import argparse
import os
import shlex
import subprocess


class ProvisionCaller(object):
    def __call__(self):
        here = os.path.dirname(os.path.abspath(__file__))
        self.rootdir = os.path.relpath(here)

        proc = subprocess.Popen(shlex.split(self.build_cmds()))
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
            '--verbose', '-v',
            action='store_true',
            help='verbose output')
        parser.add_argument(
            'tags', nargs='*', help='tags')
        return parser.parse_args()

    def build_cmds(self):
        args = self.parse_args()
        cmds = ['ansible-playbook -K -i {rootdir}/hosts']
        if args.check:
            cmds.append('--check')
        if args.diff:
            cmds.append('--diff')
        if args.verbose:
            cmds.append('--verbose')
        cmds.append('-t "{tags}" {rootdir}/playbook.yml')
        cmds = ' '.join(cmds)

        return cmds.format(
            rootdir=self.rootdir,
            tags=','.join(args.tags or ['setup']))


if __name__ == '__main__':
    ProvisionCaller()()
