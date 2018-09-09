# coding: utf-8


def includeme(config):
    from . import dao
    dao.TEST_DATA = config.registry.settings.get('test_data', dao.TEST_DATA)
