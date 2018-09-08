import sys
sys.path = [x for x in sys.path if 'dist-packages' not in x]

__import__('pipenv.cli', globals(), locals(), ['cli'], 0).cli()
