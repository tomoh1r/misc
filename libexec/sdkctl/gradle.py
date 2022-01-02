# coding: utf-8


def main(args):
    print("gradle")
    print(args)


def parse_args(parent, dl_src_mapping):
    parser = parent.add_parser("gradle", help="Manage Gradle")
    parser.set_defaults(func=main)
