from setuptools import setup, find_packages
#
# Note: This file does not really serve any purpose
# it just keeps some tools happy
# 
import os

version = '1.0'

setup(name='collective.developermanual',
      version=version,
      description="Plone Developer Documentation",
      classifiers=[
        "Programming Language :: Python",
        "Topic :: Software Development :: Libraries :: Python Modules",
        ],
      keywords='',
      author='Mikko Ohtamaa & Plone community contributors',
      author_email='mikko@opensourcehacker.com',
      url='http://plone.org',
      license='GPL',
      packages=find_packages(exclude=['ez_setup']),
      include_package_data=True,
      zip_safe=False,
      install_requires=[
          'setuptools',
          # -*- Extra requirements: -*-
      ],
      entry_points="""
      # -*- Entry points: -*-
      """,
      )
