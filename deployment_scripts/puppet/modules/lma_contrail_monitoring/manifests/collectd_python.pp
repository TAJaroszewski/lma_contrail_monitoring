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

notice('fuel-plugin-lma-contrail: collectd_python')

class lma_contrail_monitoring::collectd_python (
  $ensure      = present,
  $modules     = { },

) inherits lma_contrail_monitoring::params {

  if empty($lma_contrail_monitoring::params::collectd_contrail_path) {
    notice("collectd_plugin variable was not set")
  }

  if empty($lma_contrail_monitoring::params::collectd_modules_path) {
    fatal("Collectd_Python_ModulePath: variable was not set")
  } else {
    $module_dirs = [$lma_contrail_monitoring::params::collectd_modules_path]
    notice("Collectd_Python_ModulePath: $module_dirs ")
  }

  concat{ $lma_contrail_monitoring::params::collectd_contrail_path:
    ensure         => 'present',
    mode           => '0640',
    owner          => 'root',
    group          => $collectd::params::root_group,
    notify         => Service['collectd'],
    ensure_newline => true
  }


  concat::fragment{ "${lma_contrail_monitoring::params::collectd_contrail_path}_header":
    order   => '00',
    content => template('lma_contrail_monitoring/collectd-module-header.conf.erb'),
    target  => $lma_contrail_monitoring::params::collectd_contrail_path,
  }

  concat::fragment{ "${lma_contrail_monitoring::params::collectd_contrail_path}_footer":
    order   => '99',
    content => '</Plugin>',
    target  => $lma_contrail_monitoring::params::collectd_contrail_path,
  }

  create_resources(lma_contrail_monitoring::collectd_plugin, $modules)

}