#!/usr/bin/env sh

MODULE_PATH='/etc/puppet/modules:/etc/puppet/modules/lma_contrail_monitoring/modules'
COLLECTD_FILE="/usr/share/lma_collector/decoders/collectd.lua"

# Pre-Tasks
echo lma_contrail_monitoring > /tmp/lma_contrail_monitoring

if [ -f ${FILE} ]; then
	LUA_CHECK=$(grep -c lma-contrail-extension ${COLLECTD_FILE})
	if [ ${LUA_CHECK} -eq 0 ]; then
		echo "MD5SUM OF ${COLLECTD_FILE} BEFORE CHANGE:"
	    md5sum ${COLLECTD_FILE}
        	sed -i "/elseif metric_source == .mysql. then/i\            elseif sample['plugin_instance'] == 'lma-contrail-extension'\n\t\tthen msg['Fields']['name'] = sample['type_instance']" ${COLLECTD_FILE}
    	echo "MD5SUM OF ${COLLECTD_FILE} AFTER CHANGE:"
	    md5sum ${COLLECTD_FILE}
	fi
fi

if [ -d /etc/fuel/plugins/lma_collector* ]; then
	LATEST_LMA=$(ls /etc/fuel/plugins/lma_collector*/puppet/modules -d | head -1)
	if [ -d ${LATEST_LMA} ]; then
    	MODULE_PATH=${MODULE_PATH}:${LATEST_LMA}
	fi
fi

if [ -d /etc/fuel/plugins/lma_infrastructure_alerting-* ]; then
	LATEST_LMA_A=$(ls /etc/fuel/plugins/lma_infrastructure_alerting-*/puppet/modules -d | head -1)
	if [ -d ${LATEST_LMA_A} ]; then
    	MODULE_PATH=${MODULE_PATH}:${LATEST_LMA_A}
	fi
fi

echo "Puppet -> Module PATH: ${MODULE_PATH}"

LATEST_PLUGIN=$(ls /etc/fuel/plugins/lma_contrail_monitoring-*/puppet -d | head -1)
MODULE_PATH=${MODULE_PATH}:${LATEST_PLUGIN}/modules/

if ! [ -d ${LATEST_PLUGIN} ]; then
    echo "No LMA contrail plugin directory found"
fi

echo "Stage: BASE -> hiera"
/usr/bin/puppet apply --modulepath=${MODULE_PATH} ${LATEST_PLUGIN}/manifests/base.pp #--debug -v

echo "Stage: INIT -> lma_contrail_monitoring"
/usr/bin/puppet apply --modulepath=${MODULE_PATH} ${LATEST_PLUGIN}/manifests/init.pp #--debug -v

if [ -f /etc/init.d/collectd ]; then
    service collectd restart
fi
if [ -f /etc/init/log_collector.conf ]; then
    service log_collector restart
fi
if [ -f /etc/init/metric_collector.conf ]; then
    service metric_collector restart
fi

if [ -f /usr/lib/ocf/resource.d/fuel/ocf-metric_collector ]; then
    crm resource restart clone_metric_collector
fi
if [ -f /usr/lib/ocf/resource.d/fuel/ocf-log_collector ]; then
    crm resource restart clone_log_collector
fi

exit 0

#EOF
