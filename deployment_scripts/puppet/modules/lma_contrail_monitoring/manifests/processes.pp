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

notice('fuel-plugin-lma-contrail: processes')

class lma_contrail_monitoring::processes (
  $process_hash,
  $process_ensure = 'running',
  $process_enable = true,
  $process_manage = true
) inherits lma_contrail_monitoring::params {

  validate_bool($process_enable)
  validate_bool($process_manage)

  validate_hash($process_hash)

  if $process_hash {
    create_resources(collectd::plugin::processes::processmatch, $process_hash)
  }
}