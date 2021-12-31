#!/usr/bin/env python3
# coding: utf-8
import argparse
import sys
from importlib import import_module
from pathlib import Path

_root = Path(__file__).absolute().parent
_lib_dpath = _root / "sdkctl"


def main():
    args = parse_args()
    args.func(args)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.set_defaults(func=lambda args: parser.print_help())
    group = parser.add_mutually_exclusive_group()
    group.add_argument("-v", "--verbose", action="store_true")
    group.add_argument("-q", "--quiet", action="store_true")

    subp = parser.add_subparsers()
    jdkp = subp.add_parser("jdk", help="Manage JDK")
    jdkp.set_defaults(func=get_module("sdkctl.jdk").main)

    gradlep = subp.add_parser("gradle", help="Manage Gradle")
    gradlep.set_defaults(func=get_module("sdkctl.gradle").main)

    mvnp = subp.add_parser("maven", help="Manage Maven")
    mvnp.set_defaults(func=get_module("sdkctl.maven").main)

    return parser.parse_args()


def get_module(name):
    if _lib_dpath not in sys.path:
        sys.path.append(_lib_dpath)
    return import_module(name)


if __name__ == "__main__":
    main()
