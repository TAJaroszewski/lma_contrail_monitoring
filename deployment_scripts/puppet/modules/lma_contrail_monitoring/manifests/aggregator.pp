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

notice('fuel-plugin-lma-contrail: aggregator')

class lma_contrail_monitoring::aggregator inherits lma_contrail_monitoring::params {

  prepare_network_config(hiera_hash('network_scheme', { }))
  $mgmt_address    = get_network_role_property('management', 'ipaddr')
  $lma_collector   = hiera_hash('lma_collector')

  $node_profiles   = hiera_hash('lma::collector::node_profiles')
  $is_controller   = $node_profiles['controller']
  $is_mysql_server = $node_profiles['mysql']
  $is_rabbitmq     = $node_profiles['rabbitmq']

  $network_metadata = hiera_hash('network_metadata')
  $controllers      = get_nodes_hash_by_roles($network_metadata, ['primary-controller', 'controller'])

  $aggregator_address = hiera('management_vip')
  $management_network = hiera('management_network_range')
  $aggregator_port    = 5565
  $check_port         = 5566

  if $is_controller or $is_rabbitmq or $is_mysql_server {
    # On nodes where pacemaker is deployed, make sure the Log and Metric collector services
    # are configured with the "pacemaker" provider
    Service<| title == 'log_collector' |> {
      provider => 'pacemaker'
    }
    Service<| title == 'metric_collector' |> {
      provider => 'pacemaker'
    }
  }

  # Configure the GSE filters emitting the status metrics for:
  # - service clusters
  # - node clusters
  # - global clusters

  if $lma_collector_contrail['gse_cluster_service'] and $lma['gse_cluster_service'] {
    $gse_cluster_service_top = merge($lma['gse_cluster_service'], $lma_collector_contrail['gse_cluster_service'])
    $gse_cluster_service_bottom = { clusters => merge($lma['gse_cluster_service']['clusters'], $lma_collector_contrail['gse_cluster_service']['clusters']) }
    $gse_cluster_service = merge($gse_cluster_service_top, $gse_cluster_service_bottom)
  } else {
    $gse_cluster_service = $lma['gse_cluster_service']
  }
  validate_hash($gse_cluster_service)
  info "gse_cluster_service: $gse_cluster_service"

  if $lma_collector_contrail['gse_cluster_node'] and $lma['gse_cluster_node'] {
    $gse_cluster_node_top = merge($lma['gse_cluster_node'], $lma_collector_contrail['gse_cluster_node'])
    $gse_cluster_node_bottom = { clusters => merge($lma['gse_cluster_node']['clusters'], $lma_collector_contrail['gse_cluster_node']['clusters']) }
    $gse_cluster_node = merge($gse_cluster_node_top, $gse_cluster_node_bottom)
  } else {
    $gse_cluster_node =  $lma['gse_cluster_node']
  }
  validate_hash($gse_cluster_node)
  info "gse_cluster_node: $gse_cluster_node"

  if $lma_collector_contrail['gse_cluster_global'] and $lma['gse_cluster_global'] {
    $gse_cluster_global_top = merge($lma['gse_cluster_global'], $lma_collector_contrail['gse_cluster_global'])
    $gse_cluster_global_bottom = { clusters => merge($lma['gse_cluster_global']['clusters'], $lma_collector_contrail['gse_cluster_global']['clusters']) }
    $gse_cluster_global = merge($gse_cluster_global_top, $gse_cluster_global_bottom)
  } else {
    $gse_cluster_global = $lma['gse_cluster_global']
  }
  validate_hash($gse_cluster_global)
  info "gse_cluster_global: $gse_cluster_global"

  if $lma_collector_contrail['gse_policies'] and $lma['gse_policies'] {
    $gse_policies_top = merge($lma['gse_policies'], $lma_collector_contrail['gse_policies'])
    $gse_policies_bottom = { clusters => merge($lma['gse_policies']['clusters'], $lma_collector_contrail['gse_policies']['clusters']) }
    $gse_policies = merge($gse_policies_top, $gse_policies_bottom)
  } else {
    $gse_policies = $lma['gse_policies']
  }
  validate_hash($gse_policies)
  info "gse_policies: $gse_policies"

  create_resources(lma_collector::gse_cluster_filter, {
    'service' => $gse_cluster_service,
    'node'    => $gse_cluster_node,
    'global'  => $gse_cluster_global,
  }, {
    require => Class['lma_collector::gse_policies']
  })

  class { 'lma_collector::gse_policies':
    policies => $gse_policies,
  }


  # ToDo: Notify crm/pcs about change in configuration

}