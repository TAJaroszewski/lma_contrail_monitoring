#    Copyright 2016 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
notice('fuel-plugin-lma-contrail: python_base')

class lma_contrail_monitoring::python_base {
  include collectd::params
  #include lma_collector::params

  # variable is exposed for classes/defines including that class
  $modulepath = $lma_collector::params::python_module_path

  class { 'collectd::plugin::python':
    modulepaths => [$modulepath],
    modules     => {},
  }

  # The collectd module does not provide a way to add a Python file to Python
  # directory without declaring a corresponding module in the collectd Python
  # configuration file. For that reason we need to use a "file" resource and
  # notify the "collectd" service resource ourselves. The "collectd" service
  # resource is private to the "collectd" module, but we have no choice.

  file { 'base.script':
    ensure  => 'present',
    path    => "${modulepath}/collectd_base.py",
    owner   => 'root',
    group   => $collectd::params::root_group,
    mode    => '0640',
    source  => 'puppet:///modules/lma_collector/collectd/collectd_base.py',
    require => Class['collectd::plugin::python'],
    notify  => Service['collectd'],
  }

}
