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

notice('fuel-plugin-lma-contrail: collectd_plugin')

define lma_contrail_monitoring::collectd_plugin (
  $config = { },
  $module = $title
)  {

  include lma_contrail_monitoring::params
  include lma_collector::collectd::python_base

  info "collectd_plugin config: $config"

  validate_hash($config)


  $real_config = adapt_collectd_python_plugin_config($config)

  # Copy plugin into collectd plugin directory
  collectd::plugin::python::module { "module_${title}":
    module        => $title,
    modulepath    => $lma_contrail_monitoring::params::collectd_modules_path,
    script_source => "puppet:///modules/lma_contrail_monitoring/scripts/${title}.py",
    config        => $real_config
  }

  concat::fragment{ "collectd_contrail_network_check_python_${title}":
    ensure  => 'present',
    order   => '50',
    target  => $lma_contrail_monitoring::params::collectd_contrail_path,
    content => template('lma_contrail_monitoring/collectd-module-custom.erb')
  }

}
