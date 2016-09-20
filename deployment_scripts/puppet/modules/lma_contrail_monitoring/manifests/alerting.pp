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

notice('fuel-plugin-lma_contrail_monitoring: lma_contrail_alerting')

class lma_contrail_monitoring::alerting  (
  $ensure = present,
  $hosts = [],
  $host_name_key = undef,
  $network_role_key = undef,
  $host_display_name_keys = [],
  $host_custom_vars_keys = [],
  $role_key = undef,
  $node_cluster_roles = { },
  $node_cluster_alarms = { },
)  inherits lma_contrail_monitoring::params {


  $nagios_config_filename_prefix = 'lma_'
  $nagios_contactgroup = 'openstack'
  $nagios_generic_host_template = 'generic-host'
  $nagios_generic_service_template = 'generic-service'
  $nagios_default_max_check_attempts_host = 3

  info "host_name_key $host_name_key"
  info "network_role_key $network_role_key"

  validate_string($host_name_key, $network_role_key)
  validate_array($hosts, $host_display_name_keys, $host_custom_vars_keys)
  validate_hash($node_cluster_roles, $node_cluster_alarms)

  if $alarms_definitions == undef {
    fail('Alarms definitions not found. Check files in /etc/hiera/override.')
  }

  $nagios_hosts = nodes_to_nagios_hosts($hosts,
    $host_name_key,
    $network_role_key,
    $host_display_name_keys,
    $host_custom_vars_keys)
  $host_defaults = {
    ensure   => $ensure,
    prefix   => $nagios_config_filename_prefix,
    defaults => {
      contact_groups         => $nagios_contactgroup,
      active_checks_enabled  => 1,
      passive_checks_enabled => 0,
      max_check_attempts     => $nagios_default_max_check_attempts_host,
      use                    => $nagios_generic_host_template,
    }
  }

  create_resources(nagios::host, $nagios_hosts, $host_defaults)

  $nagios_hostgroups = nodes_to_nagios_hostgroups($hosts,
    $host_name_key,
    $role_key)
  $hostgroup_defaults = {
    prefix => $nagios_config_filename_prefix,
    ensure => $ensure,
  }

  create_resources(nagios::hostgroup, $nagios_hostgroups, $hostgroup_defaults)
  info "INFO -> hosts: $hosts; host_name_key: $host_name_key; role_key: $role_key; node_cluster_roles: $node_cluster_roles; node_cluster_alarms: $node_cluster_alarms"
  # Configure AFD-based service checks
  $afd_services = afds_to_nagios_services($hosts,
    $host_name_key,
    $role_key,
    $node_cluster_roles,
    $node_cluster_alarms)
  $afd_service_defaults = { 'notifications_enabled' => 1 }
  info "afd_services: $afd_services"

  create_resources(lma_infra_alerting::nagios::services, $afd_services, $afd_service_defaults)

}

