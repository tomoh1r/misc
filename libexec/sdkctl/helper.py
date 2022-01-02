# coding: utf-8
import configparser
from pathlib import Path

cfg = None


_here = Path(__file__).absolute().parent


def get_settings(section, option):
    global cfg
    if not cfg:
        cfg = configparser.ConfigParser()
        cfg.read(_here / "file" / "settings.ini")
    return cfg.get(section, option)


def get_dl_src_mapping(section):
    mapping = {}
    for ver in get_settings(section, "versions").split(","):
        ver = str(ver)
        mapping[ver] = {
            "url": get_settings(section, ver + " url"),
            "name": get_settings(section, ver + " name"),
        }
    return mapping


def download(src, dst):
    pass


def extract(src, infile_fpath, dst_fpath):
    pass
