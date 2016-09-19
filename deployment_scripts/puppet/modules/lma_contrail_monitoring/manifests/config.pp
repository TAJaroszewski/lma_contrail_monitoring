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

notice('fuel-plugin-lma-contrail: lma_contrail_monitoring::config')

class lma_contrail_monitoring::config inherits lma_contrail_monitoring::params
{

  $colletd_control_python_modules = {
    xmpp-number-of-sessions                           => { config => { } },
    xmpp-number-of-sessions-up                        => { config => { } },
    xmpp-number-of-sessions-down                      => { config => { } },
    bgp-session-number                                => { config => { } },
    bgp-session-number-up                             => { config => { } },
    bgp-session-number-down                           => { config => { } },
    system-uptime                                     => { config => { } },
    ntp-time-drift                                    => { config => { } },
    #ToDo: Combine them into one script with different parameter
    # Contrail WebUI
    check-api-contrail-8080                           => { config => { } },
    check-api-contrail-8143                           => { config => { } },
    # Contrail Discovery
    check-api-contrail-9110                           => { config => { } },
    check-api-contrail-5997                           => { config => { } },
    # Contrail API
    check-api-contrail-8084                           => { config => { } },
    check-api-contrail-9100                           => { config => { } },
    # Contrail Collector
    check-api-contrail-8089                           => { config => { } },
    # Contrail Analytics
    check-api-contrail-9081                           => { config => { } },
    check-api-contrail-8090                           => { config => { } },
    # Contrail Control
    check-api-contrail-8083                           => { config => { } },
    # Contrail IFMAP
    ifmap-num-elements                                => { config => { } },
    #ToDo: Implement proper check for multiple contrail GWs
    compute-ping-gw                                   => { config => {
      host            => $contrail_gateways,
      timeout         => '5',
      type_instance   => 'ping_avg_gateway',
    }
    }
  }

  $collectd_compute_python_modules = {
    vrouter-xmpp                                            => { config => { } },
    vrouter-dns-xmpp                                        => { config => { } },
    vrouter-lls                                             => { config => { } },
    vrouter-openedsockets                                   => { config => { } },
    #ToDo: Combine them into one script
    vrouter-flows-active                                    => { config => { } },
    vrouter-flows-aged                                      => { config => { } },
    vrouter-flows-created                                   => { config => { } },
    vrouter-flows-discard                                   => { config => { } },
    vrouter-flows-drop                                      => { config => { } },
    vrouter-flows-frag-err                                  => { config => { } },
    vrouter-flows-invalid-nh                                => { config => { } },
    vrouter-flows-flow-queue-limit-exceeded                 => { config => { } },
    vrouter-flows-flow-table-full                           => { config => { } },
    vrouter-flows-composite-invalid-interface               => { config => { } },
    vrouter-flows-invalid-label                             => { config => { } },
    system-uptime                                           => { config => { } },
    ntp-time-drift                                          => { config => { } }
  }

  # ToDo: User hiera for such structure
  $process_matches_control_node = {
    contrail-control                  => { name => 'contrail-control', regex => '/usr/bin/contrail-control' },
    contrail-control-nodemgr          => { name => 'contrail-control-nodemgr', regex => 'python /usr/bin/contrail-nodemgr --nodetype=contrail-control' },
    contrail-dns                      => { name => 'contrail-dns', regex => '/usr/bin/contrail-dns' },
    contrail-named                    => { name => 'contrail-named', regex => '/usr/bin/contrail-named -f -c /etc/contrail/dns/contrail-named.conf' },
    haproxy                           => { name => 'haproxy', regex => '/usr/sbin/haproxy' }
  }

  $network_matcher_control = {
    contrail-named          => { name => 'contrail-named', type => 'listen', interface => 'localhost', query => 'dns', port => '53' },
    contrail-named-8094     => { name => 'contrail-named-8094', type => 'listen', interface => 'localhost', query => 'dns', port => '8094' },
    contrail-dns-8092       => { name => 'contrail-dns-8092', type => 'listen', interface => 'localhost', query => 'dns', port => '8092' },
    contrail-dns-8093       => { name => 'contrail-dns-8093', type => 'listen', interface => 'localhost', query => 'dns', port => '8093' }
  }

  $process_matcher_analytics = {
    contrail-alarm-gen         => { name => 'contrail-alarm-gen', regex => '/usr/bin/python /usr/bin/contrail-alarm-gen -c /etc/contrail/contrail-alarm-gen.conf' },
    contrail-analytics-api     => { name => 'contrail-analytics-api', regex => '/usr/bin/python /usr/bin/contrail-analytics-api -c /etc/contrail/contrail-analytics-api.conf' },
    contrail-analytics-nodemgr => { name => 'contrail-analytics-nodemgr', regex => '/usr/bin/python /usr/bin/contrail-nodemgr' },
    contrail-collector         => { name => 'contrail-collector', regex => '/usr/bin/contrail-collector' },
    contrail-query-engine      => { name => 'contrail-query-engine', regex => '/usr/bin/contrail-query-engine' },
    contrail-snmp-collector    => { name => 'contrail-snmp-collector', regex => '/usr/bin/python /usr/bin/contrail-snmp-collector --device-config-file /etc/contrail/device.ini' },
    contrail-topology          => { name => 'contrail-topology', regex => '/usr/bin/python /usr/bin/contrail-topology' }
  }

  $network_matcher_analytics = {
    contrail-analytics-api-time     => { name => 'contrail-analytics-api-time', type => 'api', interface => 'localhost', query => 'time', port => '9081', module => 'http_check' },
    contrail-analytics-api-status   => { name => 'contrail-analytics-api-status', type => 'api', interface => 'localhost', query => 'status', port => '9081', module => 'http_check' },
    contrail-collector-listen       => { name => 'contrail-collector-listen', type => 'listen', interface => 'localhost', query => 'status', port => '8086', module => 'http_check' }
  }

  $process_matches_config_node = {
    contrail-api            => { name => 'contrail-api', regex => '/usr/bin/python /usr/bin/contrail-api --conf_file /etc/contrail/contrail-api.conf.+' },
    contrail-config-nodemgr => { name => 'contrail-config-nodemgr', regex => 'python /usr/bin/contrail-nodemgr --nodetype=contrail-config' },
    contrail-device-manager => { name => 'contrail-device-manager', regex => '/usr/bin/python /usr/bin/contrail-device-manager --conf_file /etc/contrail/contrail-device-manager.conf.+' },
    contrail-discovery      => { name => 'contrail-discovery', regex => '/usr/bin/python /usr/bin/contrail-discovery --conf_file /etc/contrail/contrail-discovery.conf' },
    contrail-schema         => { name => 'contrail-schema', regex => '/usr/bin/python /usr/bin/contrail-schema --conf_file /etc/contrail/contrail-schema.conf.+' },
    contrail-svc-monitor    => { name => 'contrail-svc-monitor', regex => '/usr/bin/python /usr/bin/contrail-svc-monitor --conf_file /etc/contrail/contrail-svc-monitor.conf.+' },
    contrail-ifmap          => { name => 'ifmap', regex => '/bin/sh /usr/bin/ifmap-server' }
  }

  $network_matcher_config = {
    ifmap-basic-auth                => { name => 'ifmap-basic-auth', type => 'basic', interface => 'localhost', query => 'status', port => '8443', module => 'http_check' },
    contrail-svc-monitor-api-time   => { name => 'contrail-svc-monitor-api-time', type => 'api', interface => 'localhost', query => 'time', port => '8088', module => 'http_check' },
    contrail-svc-monitor-api-status => { name => 'contrail-svc-monitor-api-status', type => 'api', interface => 'localhost', query => 'status', port => '8088', module => 'http_check' },
    contrail-discovery-api-time     => { name => 'contrail-discovery-api-time', type => 'api', interface => 'localhost', query => 'time', port => '5997', module => 'http_check' },
    contrail-discovery-api-status   => { name => 'contrail-discovery-api-status', type => 'api', interface => 'localhost', query => 'status', port => '5997', module => 'http_check' },
    contrail-config-api-time        => { name => 'contrail-config-api-time', type => 'api', interface => 'localhost', query => 'time', port => '8082', module => 'http_check' },
    contrail-config-api-status      => { name => 'contrail-config-api-status', type => 'api', interface => 'localhost', query => 'status', port => '8082', module => 'http_check' },
  }

  $process_matcher_web_ui = {
    contrail-webui            => { name => 'contrail-webui', regex => '/usr/bin/node /usr/src/contrail/contrail-web-core/webServerStart.js' },
    contrail-webui-middleware => { name => 'contrail-webui-middleware', regex => 'node jobServerStart.js' }
  }

  $network_matcher_web_ui = {
    contrail-webui-api-time         => { name => 'contrail-webui-api-time', type => 'api', interface => 'localhost', query => 'time', port => '8143', module => 'http_check' },
    contrail-webui-api-status       => { name => 'contrail-webui-api-status', type => 'api', interface => 'localhost', query => 'status', port => '8143', module => 'http_check' }

  }

  $process_matches_db_node = {
    cassandra => { name => 'cassandra', regex => 'java.+org.apache.cassandra.service.CassandraDaemon' },
    zookeeper => { name => 'zookeeper', regex => 'java.+/etc/zookeeper/conf/zoo.cfg' }
  }

  $process_matcher_supervisor_database = {
    contrail-database-nodemgr => { name => 'contrail-database-nodemgr', regex => 'python /usr/bin/contrail-nodemgr --nodetype=contrail-database' },
    kafka                     => { name => 'kafka', regex => 'java.+/usr/share/kafka/config/server.properties' }
  }

  $process_matcher_vrouter_node = {
    contrail-nodemgr       => { name => 'contrail-nodemgr', regex => 'python.+contrail-nodemgr$' },
    contrail-vrouter-agent => { name => 'contrail-vrouter-agent', regex => '.+contrail-vrouter-agent$' }
  }

  $process_matcher_various = {
    ntpd => { name => 'ntpd', regex => '/usr/sbin/ntpd -p /var/run/ntpd.pid' }
  }

  $process_matches_ops_controller = {
    neutron-server => { name => 'neutron-server', regex => '.+/usr/bin/neutron-server' }
  }

  $network_services = {
    neutron-api-status              => { name => 'neutron-api-status', type => 'api', interface => 'neutron_server', query => 'status', port => '9697' },
    neutron-api-time                => { name => 'neutron-api-time', type => 'api', interface => 'neutron_server', query => 'time', port => '9697' },
  }

  $process_matches_compute_node = {
    contrail-vrouter-agent            => { name => 'contrail-vrouter-agent', regex => '/usr/bin/contrail-vrouter-agent' },
    contrail-vrouter-nodemgr          => { name => 'contrail-nodemgr', regex => 'python /usr/bin/contrail-nodemgr --nodetype=contrail-vrouter' },
    libvirtd                          => { name => 'libvirtd', regex => '/usr/sbin/libvirtd -d' },
    haproxy                           => { name => 'haproxy', regex => '/usr/sbin/haproxy' },
    nova-compute                      => { name => 'nova-compute', regex => '/usr/bin/python /usr/bin/nova-compute --config-file=/etc/nova/nova.conf' }
  }


}