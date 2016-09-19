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


notice('fuel-plugin-lma-contrail: lma_contrail_monitoring')


class lma_contrail_monitoring inherits lma_contrail_monitoring::config
{
  include lma_contrail_monitoring::params
  include lma_contrail_monitoring::services

  # Configure processes monitoring using collectd -> client
  # Check: contrail-status -d  | tr "," " "  | awk '/pid/{print$1" "$4}' | while read r1 r2; do echo $r1; netstat -ntpl | grep $r2; done
  # Contrail Config Node

  info "contrail_config_nodes:  $contrail_config_nodes"
  info "contrail_control_nodes:  $contrail_control_nodes"
  info "contrail_db_nodes:  $contrail_db_nodes"

  # Contrail Config Node
  validate_bool($is_contrail_config_node)
  if $is_contrail_config_node {

    validate_hash($process_matches_config_node)
    lma_contrail_monitoring::collectd_processes { $process_matches_config_node:
      process_hash => $process_matches_config_node
    }

    validate_hash($process_matcher_analytics)
    lma_contrail_monitoring::collectd_processes { $process_matcher_analytics:
      process_hash => $process_matcher_analytics
    }

    validate_hash($process_matcher_web_ui)
    lma_contrail_monitoring::collectd_processes { $process_matcher_web_ui:
      process_hash => $process_matcher_web_ui
    }
  }

  # Contrail Control Node
  validate_bool($is_contrail_control_node)
  if $is_contrail_control_node {
    validate_hash($process_matches_control_node)
    lma_contrail_monitoring::collectd_processes { $process_matches_control_node:
      process_hash => $process_matches_control_node
    }

  }

  # Contrail DB Node
  validate_bool($is_contrail_db_node)
  if $is_contrail_db_node {
    validate_hash($process_matches_db_node)
    lma_contrail_monitoring::collectd_processes { $process_matches_db_node:
      process_hash => $process_matches_db_node
    }

    validate_hash($process_matcher_supervisor_database)
    lma_contrail_monitoring::collectd_processes { $process_matcher_supervisor_database:
      process_hash => $process_matcher_supervisor_database
    }

  }

  # Contrail Controller Node
  validate_bool($is_controller_node)

  if $is_controller_node {
    validate_hash($process_matches_ops_controller)
    lma_contrail_monitoring::collectd_processes { $process_matches_ops_controller:
      process_hash => $process_matches_ops_controller
    }

  }

  if ($is_contrail_db_node or $is_contrail_control_node or $is_contrail_config_node) {
    # CollectD TCPConns module - network service performance data
    class {
      'lma_contrail_monitoring::collectd_tcpconns': }

    # Custom Contrail modules
    class {
      'lma_contrail_monitoring::collectd_python':
        modules => $colletd_control_python_modules
    }
    class {
      'lma_contrail_monitoring::etc_check_api_conf':
    }

  } elsif $is_contrail_compute_node {
    # Custom Contrail modules
    class {
      'lma_contrail_monitoring::collectd_python':
        modules => $collectd_compute_python_modules
    }

    lma_contrail_monitoring::collectd_processes { $process_matches_compute_node:
      process_hash => $process_matches_compute_node
    }

  }

  # Configure alerting -> server
  if $is_intrastructure_alerting_node {

  }


  # Generic services to monit
  lma_contrail_monitoring::collectd_processes { $process_matcher_various:
    process_hash => $process_matcher_various
  }

  $contrail_plugin = hiera('contrail', false)

  if ! $contrail_plugin {
    fatal("Cannot find contrail's hiera information")
  }

  if $lma_collector['node_cluster_roles'] {
    $node_cluster_roles = $lma_collector['node_cluster_roles']
  } else {
    $node_cluster_roles = { }
  }

  if $lma_collector['node_cluster_alarms'] {
    $node_cluster_alarms = $lma_collector['node_cluster_alarms']
  } else {
    $node_cluster_alarms = { }
  }

  info "New roles: $node_cluster_roles"
  info "New alarms: $node_cluster_alarms"

  if $is_intrastructure_alerting_node {

    include nagios::params
    include nagios::server_service

    class { 'lma_contrail_monitoring::hosts':
      hosts                  => values($network_metadata['nodes']),
      host_name_key          => 'name',
      network_role_key       => 'infrastructure_alerting',
      role_key               => 'node_roles',
      host_display_name_keys => ['name', 'user_node_name'],
      host_custom_vars_keys  => ['fqdn', 'node_roles'],
      node_cluster_roles     => $node_cluster_roles,
      node_cluster_alarms    => $node_cluster_alarms
    }
  }

  info "Node Cluster Roles:  $lma['node_cluster_roles']"
  info "Service Cluster Roles: $lma['service_cluster_roles']"
  info "Node Cluster Alarms: $lma['node_cluster_alarms']"
  info "Service Cluster Alarms: $lma['service_cluster_alarms']"

  # Apply new checks into client
  class { 'fuel_lma_collector::afds':
    roles                  => hiera('roles'),
    node_cluster_roles     => $lma['node_cluster_roles'],
    service_cluster_roles  => $lma['service_cluster_roles'],
    node_cluster_alarms    => $lma['node_cluster_alarms'],
    service_cluster_alarms => $lma['service_cluster_alarms'],
    alarms                 => $alarms_definitions
  }
}




