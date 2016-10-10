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

notice('fuel-plugin-lma-contrail: lma_contrail_monitoring::grafana')

class lma_contrail_monitoring::grafana (
)  {
  include lma_monitoring_analytics::params

  $local_address = hiera('lma::influxdb::listen_address')
  $local_port = hiera('lma::influxdb::influxdb_port')
  $influxdb_url = "http://${local_address}:${local_port}"

  $admin_user = hiera('lma::influxdb::admin_username')
  $admin_password = hiera('lma::influxdb::admin_password')

  $influx_cgs_create = "/tmp/influx_cgs.sh"

  $dashboard_defaults = {
    ensure           => present,
    grafana_url      => "${lma_monitoring_analytics::params::protocol}://${lma_monitoring_analytics::params::grafana_domain}:${lma_monitoring_analytics::params::grafana_port}",
    grafana_user     => hiera('lma::grafana::mysql::admin_username'),
    grafana_password => hiera('lma::grafana::mysql::admin_password'),
  }

  $dashboards = {
    'SDN_Contrail'  => {
      content => template('lma_contrail_monitoring/SDN_Contrail_Dashboard.json.erb'),
    },
    'Cassandra'     => {
      content => template('lma_contrail_monitoring/Cassandra_Dashboard.json.erb')
    }
  }

  create_resources(
    grafana_dashboard, merge($dashboards), $dashboard_defaults
  )

  # Create CGs
  file { $influx_cgs_create:
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('lma_contrail_monitoring/influx_cgs.sh.erb'),
  }

  exec { "run_${influx_cgs_create}":
    command => $influx_cgs_create,
    require => File[$influx_cgs_create],
  }

  #  exec { "remove_${influx_cgs_create}":
  #    command => "/bin/rm -f ${influx_cgs_create}",
  #    require => Exec["run_${influx_cgs_create}"],
  #  }


}
