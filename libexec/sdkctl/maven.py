# coding: utf-8


def main(args):
    print("maven")
    print(args)


def parse_args(parent, dl_src_mapping):
    parser = parent.add_parser("maven", help="Manage Maven")
    parser.set_defaults(func=main)
