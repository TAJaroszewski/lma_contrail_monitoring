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

notice('fuel-plugin-lma-contrail: services')

class lma_contrail_monitoring::services inherits lma_contrail_monitoring::params {

  include lma_collector::params
  #include lma_collector::collectd::python_base

  package { $lma_contrail_monitoring::params::collectd_package:
    ensure   => 'installed',
    name     => $lma_contrail_monitoring::params::collectd_package,
    provider => $collectd_provider
  }

  service { "collectd":
    ensure  => "running",
    enable  => "true",
    require => Package[$lma_contrail_monitoring::params::collectd_package]
  }

  if $is_intrastructure_alerting_node {
    # ToDo: RH/CentOS specific packages/services
    package { 'nagios3':
      ensure   => 'installed',
      name     => 'nagios3'
    }

    service { 'apache2-nagios':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}