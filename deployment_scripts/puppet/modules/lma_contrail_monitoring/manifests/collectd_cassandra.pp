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

notice('fuel-plugin-lma-contrail: lma_contrail_monitoring::collectd_cassandra')

class lma_contrail_monitoring::collectd_cassandra (
)  {
  include lma_contrail_monitoring::params
  include lma_contrail_monitoring::config
  include collectd::plugin::java

  $jmx_host = $lma_contrail_monitoring::params::jmx_host
  $jmx_port = $lma_contrail_monitoring::params::jmx_port
  $config_file = $lma_contrail_monitoring::params::config_file
  $class_path = $lma_contrail_monitoring::params::class_path
  $collectd_default_file = $lma_contrail_monitoring::params::collectd_default_file
  $java_libjvm_dir = $lma_contrail_monitoring::params::java_libjvm_dir
  $cassandra_hash = $lma_contrail_monitoring::config::cassandra_hash
  $collect = $lma_contrail_monitoring::config::cassandra_collect

  $host            = $::hostname
  $service_url     = "service:jmx:rmi:///jndi/rmi://${jmx_host}:${jmx_port}/jmxrmi"
  $user            = undef
  $password        = undef
  $instance_prefix = undef

  # FIX "missing" libjvm.so

  file { $collectd_default_file:
    mode           => 644,
    owner          => 'root',
    group          => 'root',
    notify         => Service['collectd'],
    ensure         => present,
  } -> file_line { '${collectd_default_file}_footer':
    path    => $collectd_default_file,
    line    => "export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:${java_libjvm_dir} #Setting correct LD_LIBRARY_PATH: libjvm.so issue\n",
    match   => "^export LD_LIBRARY_PATH.*",
  }

  # Setup GenericJMX plugin
  concat { $config_file:
    mode           => '0640',
    owner          => 'root',
    group          => $collectd::params::root_group,
    notify         => Service['collectd'],
  }

  # Setup Connection to local management inteface
  concat::fragment {
    'collectd_plugin_genericjmx_conf_header':
      order   => '00',
      content => template('collectd/plugin/genericjmx.conf.header.erb'),
      target  => $config_file;
    'collectd_plugin_genericjmx_conf_mbeans':
      order   => '10',
      content => template('lma_contrail_monitoring/collectd_15-genericjmx.conf.erb'),
      target  => $config_file;
    'collectd_plugin_genericjmx_conf_connection':
      order   => '20',
      content => template('collectd/plugin/genericjmx/connection.conf.erb'),
      target  => $config_file;
    'collectd_plugin_genericjmx_conf_footer':
      order   => '99',
      content => "  </Plugin>\n</Plugin>\n",
      target  => $config_file;
  }

}
