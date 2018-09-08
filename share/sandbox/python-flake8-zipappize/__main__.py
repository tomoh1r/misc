import sys
sys.path = [x for x in sys.path if 'dist-packages' not in x]

import pkg_resources
pkg_resources.get_distribution('flake8')

__import__('flake8.main', globals(), locals(), ['cli'], 0).cli.main()
