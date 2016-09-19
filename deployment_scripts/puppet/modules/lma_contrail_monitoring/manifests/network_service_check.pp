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

notice('fuel-plugin-lma-contrail: network_service_check')

define lma_contrail_monitoring::network_service_check (
  $type = 'basic',
  $interface = 'localhost',
  $query = 'status',
  $port = 80,
  $timeout = 5,
  $module = undef,
  $max_retries = 3,
) {

  require lma_contrail_monitoring::params

  include collectd::plugin::processes
  include collectd::params


  $url = "\"${name}\" \"http://${interface}:${port}\""

  $config = {
    'Url'           => $url,
    'ExpectedCode'  => '200',
    'Timeout'       => "\"${timeout}\"",
    'MaxRetries'    => "\"${max_retries}\"",
  }

  concat::fragment{ "collectd_contrail_network_check_${name}":
    ensure  => 'present',
    order   => '50',
    target  => $lma_contrail_monitoring::params::collectd_contrail_path,
    content => template('lma_contrail_monitoring/10-contrail.conf.erb')
  }

}

