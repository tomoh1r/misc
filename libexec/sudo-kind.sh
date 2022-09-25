#!/bin/bash
PROG=$(basename "$0")
_dir=$(dirname "$0")

sudo `which kind` "${@}"
