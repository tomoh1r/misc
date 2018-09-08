#
# Create flake8.pyz.
#
# Usage:
# 		make -f share/sandbox/python-flake8-zipappize/Makefile
#

ROOT=~

.PHONY: all build clean

all: build

build:
	python3 -m venv --clear venv
	./venv/bin/python3 $(ROOT)/misc/lib/get-pip.py
	./venv/bin/python3 -m pip install -t flake8 flake8 setuptools
	cp $(ROOT)/misc/share/sandbox/python-flake8-zipappize/__main__.py flake8/
	python3 -m zipapp -p '/usr/bin/env python3' flake8/
	mv flake8.pyz $(ROOT)/misc/bin/

clean:
	rm -r flake8
	rm -r venv
