# coding: utf-8
from pyramid.config import Configurator


def main(global_config, **settings):
    config = Configurator(settings=settings)
    config.include('dev_app')
    config.include('dev_common')
    config.add_route('hello', '/')
    return config.make_wsgi_app()


def includeme(config):
    config.include('dev_app.view')
