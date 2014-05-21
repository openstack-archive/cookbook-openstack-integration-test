Description
===========

This cookbook installs the OpenStack Integration Test Suite **Tempest** as part of an OpenStack reference deployment Chef for OpenStack.

Requirements
============

Chef 11 or higher required (for Chef environment use).

Cookbooks
---------

The following cookbooks are dependencies:

* openstack-common
* openstack-identity
* openstack-image
* openstack-compute
* openstack-block-storage

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
