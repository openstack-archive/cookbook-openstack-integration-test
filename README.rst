OpenStack Chef Cookbook - integration-test
==========================================

.. image:: https://governance.openstack.org/badges/cookbook-openstack-integration-test.svg
    :target: https://governance.openstack.org/reference/tags/index.html

Description
===========

This cookbook installs the OpenStack Integration Test Suite **Tempest**
as part of an OpenStack reference deployment Chef for OpenStack.  The
`OpenStack chef-repo`_ contains documentation for using this cookbook in
the context of a full OpenStack deployment. Tempest is currently
installed from git and pip.

.. _OpenStack chef-repo: https://opendev.org/openstack/openstack-chef

https://docs.openstack.org/tempest/latest/

Requirements
============

- Chef 16 or higher
- Chef Workstation 21.10.640 for testing (also includes Berkshelf for
  cookbook dependency resolution)

Cookbooks
---------

The following cookbooks are dependencies:

- 'bind', '~> 3.0'
- 'openstackclient'
- 'openstack-common', '>= 20.0.0'
- 'openstack-dns', '>= 20.0.0'
- 'openstack-image', '>= 20.0.0'
- 'resolver', '>= 3.0'

Recipes
=======

create_network
--------------

- Create a test network and subnet for use in kitchen tests

dns
---

- Setup environment for testing designate

orchestration
-------------

- Setup environment for testing heat

run_tempest
-----------

- Run tempest for use in kitchen tests

setup
-----

-  Install and configure Tempest

Attributes
==========

Please refer to the ``attributes/default.rb`` for attribute details.

Testing
=======

Please refer to the `TESTING.md`_ for instructions for testing the
cookbook.

.. _TESTING.md: cookbook-openstack-integration-test/src/branch/master/TESTING.md

License and Author
==================

+-----------------+-------------------------------------------------+
| **Author**      | Matt Thompson (matt.thompson@rackspace.co.uk)   |
+-----------------+-------------------------------------------------+
| **Author**      | Lance Albertson (lance.osuosl.org)              |
+-----------------+-------------------------------------------------+

+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2014, Rackspace US, Inc.           |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2017-2021, Oregon State University |
+-----------------+--------------------------------------------------+

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at

::

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
