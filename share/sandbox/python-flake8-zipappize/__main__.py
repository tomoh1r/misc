import sys
sys.path = [x for x in sys.path if 'dist-packages' not in x]

import pkg_resources
pkg_resources.get_distribution('flake8')

from flake8.main import cli
cli.main()
