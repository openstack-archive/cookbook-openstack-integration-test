Team and repository tags
========================

[![Team and repository tags](http://governance.openstack.org/badges/cookbook-openstack-integration-test.svg)](http://governance.openstack.org/reference/tags/index.html)

<!-- Change things from this point on -->

![Chef OpenStack Logo](https://www.openstack.org/themes/openstack/images/project-mascots/Chef%20OpenStack/OpenStack_Project_Chef_horizontal.png)

Description
===========

This cookbook installs the OpenStack Integration Test Suite **Tempest** as part of an OpenStack reference deployment Chef for OpenStack.

Requirements
============

- Chef 12 or higher
- chefdk 0.9.0 or higher for testing

Cookbooks
---------

The following cookbooks are dependencies:

* 'openstack-common', '>= 14.0.0'
* 'openstack-identity', '>= 14.0.0'
* 'openstack-image', '>= 14.0.0'
* 'openstack-compute', '>= 14.0.0'
* 'openstack-block-storage', '>= 14.0.0'

Usage
=====

setup
-----
* Install and configure Tempest

Attributes
==========

Please refer to the [attributes/default.rb](attributes/default.rb) for attribute details.

Testing
=======

Please refer to the [TESTING.md](TESTING.md) for instructions for testing the cookbook.

License and Author
==================

|                      |                                                    |
|:---------------------|:---------------------------------------------------|
| **Author**           |  Matt Thompson (<matt.thompson@rackspace.co.uk>)   |
|                      |                                                    |
| **Copyright**        |  Copyright (c) 2014, Rackspace US, Inc.            |

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
