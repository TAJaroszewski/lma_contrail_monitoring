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

notice('fuel-plugin-lma-contrail: etc_check_api_conf')

class lma_contrail_monitoring::etc_check_api_conf (
  $ensure      = present
) inherits lma_contrail_monitoring::params {

  $neutron_user = $lma_contrail_monitoring::params::neutron_user
  $service_tenant = $lma_contrail_monitoring::params::service_tenant
  $service_token = $lma_contrail_monitoring::params::service_token
  $auth_url = $lma_contrail_monitoring::params::auth_url

  file{ "/etc/check_api.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '640',
    content => template('lma_contrail_monitoring/etc_check_api.erb')
  }

}