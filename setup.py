#!/usr/bin/env python
from setuptools import setup
from ptvfdw._version import __version__

setup(
    name="ptvfdw",
    version=__version__,
    url="https://github.com/GispoCoding/ptv_fdw",
    # license="", # TODO: add license
    author="Pauliina Mäkinen",
    tests_require=["pytest"],
    author_email="pauliina@gispo.fi",
    description="PostgreSQL foreign data wrapper for json data from PTV",
    long_description="PostgreSQL foreign data wrapper for json data from PTV",
    packages=["ptvfdw"],
    include_package_data=True,
    platforms="any",
    classifiers=[
    ],
    install_requires=[
        "multicorn>=2.3",
        "requests>=2.22.0",
        "plpygis>=0.1.0"
    ],
    keywords='gis geographical postgis fdw ptv postgresql'
)
