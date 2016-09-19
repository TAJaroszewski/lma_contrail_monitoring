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

notice('fuel-plugin-lma-contrail: params')

class lma_contrail_monitoring::params  {

  include collectd::params
  include lma_collector::params

  # Contrail variables
  $collectd_package = $collectd::params::package
  $collectd_provider = $collectd::params::provider
  $plugin_conf_dir = $collectd::params::plugin_conf_dir
  $collectd_modules_path = "/usr/lib/collectd"
  $collectd_contrail_file = '10-contrail.conf'
  $collectd_contrail_dir = "${collectd::params::plugin_conf_dir}"
  $collectd_contrail_path = "${collectd::params::plugin_conf_dir}/${collectd_contrail_file}"

  $contrail_alarming_definition = 'contrail_alarming'
  $contrail_gse_filter_definition = 'contrail_gse_filters'

  $pacemaker_master_resource = 'vip__management'

  $lma = hiera_hash('lma_collector_contrail', { })
  $lma_contrail = hiera_hash('lma_collector_contrail', { })
  $master_ip = hiera('master_ip')
  $network_metadata = hiera_hash('network_metadata')
  $lma_plugin_data = hiera_hash('lma_collector_contrail', undef)
  $lma_collector = hiera_hash('lma_collector_contrail', { })
  $alarms_definitions = $lma['alarms']
  $alarms_definitions_contrail = $lma_contrail['alarms']
  $cluster_id = hiera('deployment_id')
  $os_public_vip = $network_metadata['vips']['public']['ipaddr']

  # General contail configuration
  $settings = hiera('contrail', { })


  # VIPs
  $mos_mgmt_vip   = $network_metadata['vips']['management']['ipaddr']
  $mos_public_vip = $network_metadata['vips']['public']['ipaddr']

  $contrail_private_vip = $network_metadata['vips']['contrail_priv']['ipaddr']
  $contrail_mgmt_vip    = $contrail_private_vip

  $contrail_api_public_port  = $settings['contrail_api_public_port']

  # Public SSL for Contrail WebUI
  $public_ssl_hash    = hiera_hash('public_ssl', { })
  $ssl_hash           = hiera_hash('use_ssl', { })
  $public_ssl         = get_ssl_property($ssl_hash, $public_ssl_hash, 'horizon', 'public', 'usage', false)
  $public_ssl_path    = get_ssl_property($ssl_hash, $public_ssl_hash, 'horizon', 'public', 'path', [''])

  # Internal SSL for keystone connections
  $keystone_ssl       = get_ssl_property($ssl_hash, { }, 'keystone', 'admin', 'usage', false)
  $keystone_protocol  = get_ssl_property($ssl_hash, { }, 'keystone', 'admin', 'protocol', 'http')
  $keystone_address   = get_ssl_property($ssl_hash, { }, 'keystone', 'admin', 'hostname', [$mos_mgmt_vip])
  $auth_url           = "${keystone_protocol}://${keystone_address}:35357/v2.0"

  # Nova variables
  #include nova::params
  #$nova           = hiera_hash('nova', { })

  # Network variables

  include neutron::params

  $neutron        = hiera_hash('quantum_settings', { })

  $neutron_config   = hiera_hash('neutron_config', { })
  $floating_net     = try_get_value($neutron_config, 'default_floating_net', 'net04_ext')
  $private_net      = try_get_value($neutron_config, 'default_private_net', 'net04')
  $default_router   = try_get_value($neutron_config, 'default_router', 'router04')
  $nets             = $neutron_config['predefined_networks']
  $neutron_user     = pick($neutron_config['keystone']['admin_user'], 'neutron')
  $service_token    = $neutron_config['keystone']['admin_password']
  $service_tenant   = pick($neutron_config['keystone']['admin_tenant'], 'services')

  # Process monitoring

  $processes = []
  $process_matcher = []


  # Contrail settings

  prepare_network_config(hiera_hash('network_scheme', { }))

  $contrail_gateways         = split($settings['contrail_gateways'], ',')

  $is_intrastructure_alerting_node = roles_include(['infrastructure_alerting', 'primary-infrastructure_alerting'])
  $is_influxdb_grafana = roles_include(['influxdb_grafana','primary-influxdb_grafana'])
  $is_elasticsearch_kibana = roles_include(['elasticsearch_kibana','primary-elasticsearch_kibana'])

  $is_contrail_config_node = roles_include(['contrail-config', 'primary-contrail-config'])
  $is_contrail_control_node = roles_include(['contrail-control', 'primary-contrail-control'])
  $is_contrail_db_node = roles_include(['contrail-db', 'primary-contrail-db'])

  $is_contrail_compute_node = roles_include(['compute'])

  $has_contrail_config = count(get_nodes_hash_by_roles($network_metadata, ['primary-contrail-config'])) > 0
  $has_contrail_control = count(get_nodes_hash_by_roles($network_metadata, ['primary-contrail-control'])) > 0
  $has_contrail_db = count(get_nodes_hash_by_roles($network_metadata, ['primary-contrail-db'])) > 0
  $contrail_config_nodes = get_nodes_hash_by_roles($network_metadata, ['contrail-config', 'primary-contrail-config'])
  $contrail_control_nodes =  get_nodes_hash_by_roles($network_metadata, ['contrail-control', 'primary-contrail-control'])
  $contrail_db_nodes = get_nodes_hash_by_roles($network_metadata, ['contrail-db', 'primary-contrail-db'])

  $is_controller_node = roles_include(['controller', 'primary-controller'])

  $infra_contrail_config_nodes = count($contrail_config_nodes)
  validate_integer($infra_contrail_config_nodes)
  $infra_contrail_control_nodes = count($contrail_control_nodes)
  validate_integer($infra_contrail_control_nodes)
  $infra_contrail_db_nodes = count($contrail_db_nodes)
  validate_integer($infra_contrail_db_nodes)


}