#!/bin/bash
set -x
set -e

PLUGIN_NAME='lma_infrastructure_alerting'

MANIFEST=nagios.pp
CONFIG_DIR=/etc/nagios3/conf.d
PREFIX_FILENAMES=lma_
EXTENSION_FILENAMES=.cfg
PUPPET=$(which puppet)
PLUGIN_PUPPET_DIR=$(ls -d /etc/fuel/plugins/"$PLUGIN_NAME"*/puppet)
LAST_CHECK=/var/cache/lma_last_nodes_yaml.md5sum
CURRENT_CHECK=/var/cache/lma_current_nodes_yaml.md5sum
NODES=/etc/hiera/nodes.yaml

rm -f /etc/hiera/override/{contrail_alarming.yaml,contrail_gse_filters.yaml}
rm -f /etc/nagios3/conf.d/{lma_hosts.cfg,lma_hostgroups.cfg,lma_services.cfg,lma_tpl_host_node-8_custom_vars.cfg,lma_services_commands.cfg}

if [ ! -f "$NODES" ]; then
    echo "missing $NODES file!"
    exit 1
fi

if [ ! -f $LAST_CHECK ]; then
    # First run
    md5sum $NODES 2>/dev/null > $LAST_CHECK
    exit 0
fi

  if [ -d "$CONFIG_DIR" ]; then
    rm -f "$CONFIG_DIR"/"$PREFIX_FILENAMES"*"$EXTENSION_FILENAMES"
  fi
  $PUPPET apply --modulepath="$PLUGIN_PUPPET_DIR/modules/:/etc/puppet/modules" "$PLUGIN_PUPPET_DIR/manifests/$MANIFEST" --debug -v
  set +e
  md5sum --status -c $CURRENT_CHECK
  result=$?
