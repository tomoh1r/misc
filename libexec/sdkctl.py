#!/usr/bin/env python3
# coding: utf-8
import argparse
import sys
from importlib import import_module
from pathlib import Path


def main():
    args = parse_args()
    args.func(args)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--force", action="store_true")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("-v", "--verbose", action="store_true")
    group.add_argument("-q", "--quiet", action="store_true")

    parser.set_defaults(func=lambda args: parser.print_help())

    subp = parser.add_subparsers()
    for module_name in get_module("sdkctl").list_module_names():
        mapping = get_module("sdkctl.helper").get_dl_src_mapping(module_name)
        get_module("sdkctl." + module_name).parse_args(subp, mapping)
    return parser.parse_args()


def get_module(name):
    _lib_dpath = Path(__file__).absolute().parent / "sdkctl"
    if _lib_dpath not in sys.path:
        sys.path.append(_lib_dpath)
    return import_module(name)


if __name__ == "__main__":
    main()
