#! /usr/bin/env python
# -*- coding: utf8 -*-

from __future__ import print_function

import os
import io
from setuptools import setup


def getreadme():
    for fname in ('README.rst','README.md', 'README'):
        if os.path.exists(fname):
            return io.open(os.path.join(os.path.dirname(__file__), fname),'r',encoding='utf-8').read()
    return ""

setup(
    name = "g2pservice",
    version = "0.3.4",
    author = "Louis ten Bosch",
    description = ("Grapheme to Phoneme converter. Input is a list of words (utf8). Choose one of the language options."),
    license = "GPL-3.0-only",
    keywords = "speech, transcription",
    url = "https://gitlab.science.ru.nl/clst-asr/g2p-service", #update this!
    packages=['g2pservice'],
    long_description=getreadme(),
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        "Topic :: Text Processing :: Linguistic",
        "Programming Language :: Python :: 3.6", 
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Operating System :: POSIX",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
    ],
    package_data = {'g2pservice':['*.wsgi','*.yml','*.fst','*.perl'] },
    include_package_data=True,
    zip_safe=False,
    install_requires=['CLAM >= 3.1']
)
