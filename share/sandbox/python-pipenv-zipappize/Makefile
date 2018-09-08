#
# Create pipenv.pyz.
#
# Usage:
# 		make -f share/sandbox/python-pipenv-zipappize/Makefile
#

NAME=pipenv
ROOT=~

.PHONY: all build clean

all: build

build:
	python3 -m venv --clear venv
	./venv/bin/python3 $(ROOT)/misc/lib/get-pip.py
	./venv/bin/python3 -m pip install -t $(NAME) pipenv
	cp $(ROOT)/misc/share/sandbox/python-$(NAME)-zipappize/__main__.py $(NAME)/
	find $(NAME) -name '__pycache__' -print0 | xargs -0r rm -fr
	python3 -m zipapp -p '/usr/bin/env python3' $(NAME)/
	mv $(NAME).pyz $(ROOT)/misc/bin/$(NAME)

clean:
	[ -e $(NAME) ] && rm -r $(NAME)
	[ -e venv ] && rm -r venv
